// Exercise: Collections - Bag (Multi-Asset Wallet)
//
// Build a multi-asset wallet using Bag to store different coin types.
// Bag allows heterogeneous storage with different value types.
//
// Stuck? Check out: https://move-book.com/programmability/collections.html

#[allow(duplicate_alias)]
module suilings::multi_wallet {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::bag::{Self, Bag};
use sui::coin::{Self, Coin};
use std::string::String;

// Error constants
const EAssetNotFound: u64 = 1;
const ENotOwner: u64 = 2;
const EInsufficientBalance: u64 = 3;
const EAssetAlreadyExists: u64 = 4;

/// A wallet that can hold multiple different coin types using Bag
public struct MultiWallet has key {
    id: UID,
    /// Bag storing different coin types by name (String -> Coin<T>)
    assets: Bag,
    /// Owner of the wallet
    owner: address,
}

/// Create your personal multi-asset wallet
///
/// Your DeFi portfolio manager needs to track multiple coin types in one place.
/// Bag allows storing different Coin<T> types (SUI, USDC, USDT) under string keys.
///
/// Implementation Requirements:
/// - Create an empty Bag using bag::new()
/// - Store the creator as owner using tx_context::sender()
/// - Create MultiWallet with: id, assets (empty bag), owner
/// - Transfer the wallet to owner using transfer::transfer()
public fun create_wallet(ctx: &mut TxContext) {
    // Your implementation here
}

/// Add a new coin type to your portfolio
///
/// When you receive a new type of token, deposit it into your multi-asset wallet.
/// Each asset type needs a unique identifier (like "SUI", "USDC", "WETH").
///
/// Security Validations:
/// - Only owner can deposit (abort with ENotOwner)
/// - Asset name must not already exist (abort with EAssetAlreadyExists)
///
/// Bag Operations:
/// - Verify sender is owner
/// - Check if asset_name exists using bag::contains()
/// - Add coin to bag using bag::add(&mut wallet.assets, asset_name, coin)
public fun deposit<T>(
    wallet: &mut MultiWallet,
    asset_name: String,
    coin: Coin<T>,
    ctx: &TxContext,
) {
    // Your implementation here
    // REMOVE this temporary line after implementation:
    transfer::public_transfer(coin, wallet.owner);
}

/// Withdraw some coins from your portfolio
///
/// When you need to spend or transfer coins, withdraw the desired amount.
/// The remaining balance stays in your wallet.
///
/// Security Requirements:
/// - Only owner can withdraw (abort with ENotOwner)
/// - Asset must exist (abort with EAssetNotFound)
/// - Amount must be <= balance (abort with EInsufficientBalance)
///
/// Bag Operations:
/// - Verify sender is owner
/// - Verify asset exists using bag::contains()
/// - Borrow mutable coin: bag::borrow_mut(&mut wallet.assets, asset_name)
/// - Split the amount: coin::split(coin_ref, amount, ctx)
/// - Transfer the split coin to owner
public fun withdraw<T>(
    wallet: &mut MultiWallet,
    asset_name: String,
    amount: u64,
    ctx: &mut TxContext,
) {
    // Your implementation here
}

/// Remove an entire asset from your wallet
///
/// When you want to completely move a coin type out of your portfolio,
/// remove it entirely and receive the full balance.
///
/// Security Requirements:
/// - Only owner can remove assets (abort with ENotOwner)
/// - Asset must exist (abort with EAssetNotFound)
///
/// Bag Operations:
/// - Verify sender is owner
/// - Verify asset exists
/// - Remove from bag: bag::remove(&mut wallet.assets, asset_name)
/// - Transfer the entire coin to owner
public fun remove_asset<T>(
    wallet: &mut MultiWallet,
    asset_name: String,
    ctx: &mut TxContext,
) {
    // Your implementation here
}

/// Check the balance of a specific asset in your wallet
///
/// View how much of a particular coin type you're holding.
/// Useful for portfolio dashboards and balance checks.
///
/// Security Requirements:
/// - Asset must exist (abort with EAssetNotFound)
///
/// Bag Operations:
/// - Verify asset exists using bag::contains()
/// - Borrow immutable coin: bag::borrow(&wallet.assets, asset_name)
/// - Return coin::value()
public fun get_balance<T>(wallet: &MultiWallet, asset_name: String): u64 {
    assert!(bag::contains(&wallet.assets, asset_name), EAssetNotFound);
    let coin_ref = bag::borrow<String, Coin<T>>(&wallet.assets, asset_name);
    coin::value(coin_ref)
}

// ==================== Getter Functions ====================

public fun owner(wallet: &MultiWallet): address {
    wallet.owner
}

public fun asset_count(wallet: &MultiWallet): u64 {
    bag::length(&wallet.assets)
}

public fun has_asset(wallet: &MultiWallet, asset_name: String): bool {
    bag::contains(&wallet.assets, asset_name)
}
}

#[test_only]
module suilings::multi_wallet_tests {
    use suilings::multi_wallet::{Self, MultiWallet};
    use sui::test_scenario;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use std::string;

    const OWNER: address = @0xA11CE;
    const OTHER: address = @0xB0B;
    const ONE_SUI: u64 = 1_000_000_000;

    // Mock coin types for testing
    public struct USD {}
    public struct EUR {}

    #[test]
    fun test_create_wallet() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            multi_wallet::create_wallet(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let wallet = test_scenario::take_from_sender<MultiWallet>(&scenario);
            assert!(multi_wallet::owner(&wallet) == OWNER, 0);
            assert!(multi_wallet::asset_count(&wallet) == 0, 1);
            test_scenario::return_to_sender(&scenario, wallet);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_deposit_and_balance() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            multi_wallet::create_wallet(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut wallet = test_scenario::take_from_sender<MultiWallet>(&scenario);
            let sui_coin = coin::mint_for_testing<SUI>(10 * ONE_SUI, test_scenario::ctx(&mut scenario));
            multi_wallet::deposit(&mut wallet, string::utf8(b"SUI"), sui_coin, test_scenario::ctx(&mut scenario));
            
            assert!(multi_wallet::asset_count(&wallet) == 1, 0);
            assert!(multi_wallet::get_balance<SUI>(&wallet, string::utf8(b"SUI")) == 10 * ONE_SUI, 1);
            test_scenario::return_to_sender(&scenario, wallet);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_multiple_assets() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            multi_wallet::create_wallet(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut wallet = test_scenario::take_from_sender<MultiWallet>(&scenario);
            let sui_coin = coin::mint_for_testing<SUI>(10 * ONE_SUI, test_scenario::ctx(&mut scenario));
            let usd_coin = coin::mint_for_testing<USD>(100, test_scenario::ctx(&mut scenario));
            
            multi_wallet::deposit(&mut wallet, string::utf8(b"SUI"), sui_coin, test_scenario::ctx(&mut scenario));
            multi_wallet::deposit(&mut wallet, string::utf8(b"USD"), usd_coin, test_scenario::ctx(&mut scenario));
            
            assert!(multi_wallet::asset_count(&wallet) == 2, 0);
            assert!(multi_wallet::has_asset(&wallet, string::utf8(b"SUI")), 1);
            assert!(multi_wallet::has_asset(&wallet, string::utf8(b"USD")), 2);
            test_scenario::return_to_sender(&scenario, wallet);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_withdraw() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            multi_wallet::create_wallet(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut wallet = test_scenario::take_from_sender<MultiWallet>(&scenario);
            let sui_coin = coin::mint_for_testing<SUI>(10 * ONE_SUI, test_scenario::ctx(&mut scenario));
            multi_wallet::deposit(&mut wallet, string::utf8(b"SUI"), sui_coin, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, wallet);
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut wallet = test_scenario::take_from_sender<MultiWallet>(&scenario);
            multi_wallet::withdraw<SUI>(&mut wallet, string::utf8(b"SUI"), 3 * ONE_SUI, test_scenario::ctx(&mut scenario));
            assert!(multi_wallet::get_balance<SUI>(&wallet, string::utf8(b"SUI")) == 7 * ONE_SUI, 0);
            test_scenario::return_to_sender(&scenario, wallet);
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let withdrawn = test_scenario::take_from_sender<Coin<SUI>>(&scenario);
            assert!(coin::value(&withdrawn) == 3 * ONE_SUI, 0);
            test_scenario::return_to_sender(&scenario, withdrawn);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_remove_asset() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            multi_wallet::create_wallet(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut wallet = test_scenario::take_from_sender<MultiWallet>(&scenario);
            let sui_coin = coin::mint_for_testing<SUI>(10 * ONE_SUI, test_scenario::ctx(&mut scenario));
            multi_wallet::deposit(&mut wallet, string::utf8(b"SUI"), sui_coin, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, wallet);
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut wallet = test_scenario::take_from_sender<MultiWallet>(&scenario);
            multi_wallet::remove_asset<SUI>(&mut wallet, string::utf8(b"SUI"), test_scenario::ctx(&mut scenario));
            assert!(multi_wallet::asset_count(&wallet) == 0, 0);
            test_scenario::return_to_sender(&scenario, wallet);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = multi_wallet::EAssetAlreadyExists)]
    fun test_duplicate_asset_fails() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            multi_wallet::create_wallet(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut wallet = test_scenario::take_from_sender<MultiWallet>(&scenario);
            let coin1 = coin::mint_for_testing<SUI>(10 * ONE_SUI, test_scenario::ctx(&mut scenario));
            let coin2 = coin::mint_for_testing<SUI>(5 * ONE_SUI, test_scenario::ctx(&mut scenario));
            
            multi_wallet::deposit(&mut wallet, string::utf8(b"SUI"), coin1, test_scenario::ctx(&mut scenario));
            multi_wallet::deposit(&mut wallet, string::utf8(b"SUI"), coin2, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, wallet);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = multi_wallet::ENotOwner)]
    fun test_non_owner_withdraw_fails() {
        let mut scenario = test_scenario::begin(OWNER);

        // OWNER creates wallet
        test_scenario::next_tx(&mut scenario, OWNER);
        {
            multi_wallet::create_wallet(test_scenario::ctx(&mut scenario));
        };

        // OWNER deposits
        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut wallet = test_scenario::take_from_sender<MultiWallet>(&scenario);
            let sui_coin = coin::mint_for_testing<SUI>(10 * ONE_SUI, test_scenario::ctx(&mut scenario));
            multi_wallet::deposit(&mut wallet, string::utf8(b"SUI"), sui_coin, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, wallet);
        };

        // OTHER tries to withdraw from OWNER's wallet (context is OTHER but wallet belongs to OWNER)
        test_scenario::next_tx(&mut scenario, OTHER);
        {
            let mut wallet = test_scenario::take_from_address<MultiWallet>(&scenario, OWNER);
            multi_wallet::withdraw<SUI>(&mut wallet, string::utf8(b"SUI"), 1 * ONE_SUI, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_address(OWNER, wallet);
        };

        test_scenario::end(scenario);
    }
}

