// Exercise: Dynamic Collections - Multi-Asset Portfolio
//
// Build a portfolio system using Bag to store heterogeneous assets (coins, NFTs, etc).
// Bag allows mixing different types of values in a single collection with dynamic field access.
//
// Stuck? Check out: https://move-book.com/programmability/dynamic-collections.html

module suilings::portfolio_manager {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::bag::{Self, Bag};
    use sui::dynamic_field as df;
    use std::string::{Self, String};

    // Error codes
    const EAssetNotFound: u64 = 1;
    const EAssetAlreadyExists: u64 = 2;
    const ENotOwner: u64 = 3;
    const ETagNotFound: u64 = 4;

    /// Portfolio holding heterogeneous assets
    /// Uses Bag for mixed-type storage + Dynamic Fields for tags/categories
    public struct Portfolio has key {
        id: UID,
        owner: address,
        assets: Bag,
        total_assets: u64,
    }

    /// Wrapper for any asset type with metadata
    public struct Asset<T: store> has store {
        value: T,
        added_at: u64,
    }

    /// Create your investment portfolio
    /// 
    /// You're building a personal asset manager for Web3 investors. They hold many
    /// different types of assets: NFTs, fungible tokens (SUI, USDC), game items, etc.
    /// A Bag lets you store ALL different types in ONE place - unlike Table which requires
    /// same value types. Perfect for "hold everything" portfolios!
    /// 
    /// Implementation Requirements:
    /// - Create Bag with bag::new() (can hold mixed types)
    /// - Initialize total_assets to 0 (track how many assets stored)
    /// - Transfer portfolio to sender (personal portfolio)
    public fun create_portfolio(ctx: &mut TxContext) {
        // Your implementation here
    }

    /// Add an asset to your portfolio
    /// 
    /// Investor bought SUI tokens and an NFT. They want to store both in their portfolio.
    /// First call: add_asset<Coin<SUI>>(portfolio, "my_sui", coin, ...)
    /// Second call: add_asset<ArtNFT>(portfolio, "my_art", nft, ...)
    /// Same portfolio holds DIFFERENT types - this is the power of Bag!
    /// 
    /// Implementation Requirements:
    /// - Check bag::contains() - abort with EAssetAlreadyExists if name taken
    /// - Wrap value in Asset<T> with current epoch (track when added)
    /// - Add Asset<T> to bag: bag::add(&mut portfolio.assets, name, wrapped_asset)
    /// - Increment total_assets counter
    public fun add_asset<T: store>(
        portfolio: &mut Portfolio,
        name: String,
        value: T,
        ctx: &TxContext
    ) {
        // Your implementation here
        abort 0
    }

    /// Tag assets for organization
    /// 
    /// Investor has 50 assets and wants to organize them: "DeFi tokens", "NFT art",
    /// "Game items", etc. Tags let them categorize assets for easier management.
    /// Tag your SUI as "stable", your game sword as "gaming", your art NFT as "collectibles".
    /// Later you can filter: "show me all my DeFi assets".
    /// 
    /// Implementation Requirements:
    /// - Verify asset exists: bag::contains() - abort with EAssetNotFound if missing
    /// - Create tag key: concat asset_name + "_tag" (e.g., "my_sui_tag")
    /// - Add tag as dynamic field: df::add(&mut portfolio.id, tag_key, tag)
    public fun tag_asset(
        portfolio: &mut Portfolio,
        asset_name: String,
        tag: String,
        _ctx: &TxContext
    ) {
        // Your implementation here
    }

    /// Get the tag for an asset
    /// 
    /// Dynamic Field Operations:
    /// - Construct tag key: "{asset_name}_tag"
    /// - Borrow tag: df::borrow<String, String>(&portfolio.id, tag_key)
    /// 
    /// Implementation Requirements:
    /// - Abort with EAssetNotFound if asset doesn't exist
    /// - Abort with ETagNotFound if tag doesn't exist
    /// - Return the tag value
    public fun get_asset_tag(
        portfolio: &Portfolio,
        asset_name: String
    ): String {
        // Your implementation here
        asset_name // Placeholder
    }

    /// Check if an asset has a specific tag
    /// 
    /// Dynamic Field Operations:
    /// - Check if tag exists and matches value
    /// 
    /// Implementation Requirements:
    /// - Return false if asset doesn't exist or tag doesn't exist
    /// - Compare tag value with given category
    /// - Return true if matches
    public fun has_tag(
        portfolio: &Portfolio,
        asset_name: String,
        category: String
    ): bool {
        // Your implementation here
        false // Placeholder
    }

    /// Remove an asset from the portfolio
    /// 
    /// Bag Operations:
    /// - Remove from bag: bag::remove<String, Asset<T>>(&mut portfolio.assets, name)
    /// - Returns the Asset<T> wrapper
    /// 
    /// Implementation Requirements:
    /// - Abort with ENotOwner if sender is not owner
    /// - Abort with EAssetNotFound if asset doesn't exist
    /// - Remove asset from bag
    /// - If tag exists, remove it too (optional cleanup)
    /// - Decrement total_assets counter
    /// - Return the unwrapped value
    public fun remove_asset<T: store>(
        portfolio: &mut Portfolio,
        name: String,
        ctx: &TxContext
    ): T {
        // Your implementation here
        abort 0 // Placeholder - need to return actual value
    }

    /// Check if portfolio contains an asset
    /// 
    /// Bag Operations:
    /// - Use bag::contains(&portfolio.assets, name)
    /// 
    /// Implementation Requirements:
    /// - Return bag::contains result
    public fun contains_asset(
        portfolio: &Portfolio,
        name: String
    ): bool {
        // Your implementation here
        false // Placeholder
    }

    /// Get the value of an asset (immutable)
    /// 
    /// Bag Operations:
    /// - Borrow from bag: bag::borrow<String, Asset<T>>(&portfolio.assets, name)
    /// - Return reference to the wrapped value
    /// 
    /// Implementation Requirements:
    /// - Abort with EAssetNotFound if asset doesn't exist
    /// - Borrow Asset<T> wrapper from bag
    /// - Return reference to value field
    public fun borrow_asset<T: store>(
        portfolio: &Portfolio,
        name: String
    ): &T {
        // Your implementation here
        abort 0 // Placeholder - need to return actual reference
    }

    // ==================== Getter Functions ====================
    public fun portfolio_owner(portfolio: &Portfolio): address { portfolio.owner }
    public fun portfolio_total_assets(portfolio: &Portfolio): u64 { portfolio.total_assets }
    public fun asset_value<T: store>(asset: &Asset<T>): &T { &asset.value }
    public fun asset_added_at<T: store>(asset: &Asset<T>): u64 { asset.added_at }
}

#[test_only]
module suilings::portfolio_manager_tests {
    use suilings::portfolio_manager::{Self, Portfolio};
    use sui::test_scenario;
    use std::string::{Self, String};

    const OWNER: address = @0x01;

    public struct TestAssetA has store { value: u64 }
    public struct TestAssetB has store { name: String }

    #[test]
    fun test_create_portfolio() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            portfolio_manager::create_portfolio(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let portfolio = test_scenario::take_from_sender<Portfolio>(&scenario);
            assert!(portfolio_manager::portfolio_total_assets(&portfolio) == 0, 0);
            assert!(portfolio_manager::portfolio_owner(&portfolio) == OWNER, 1);
            test_scenario::return_to_sender(&scenario, portfolio);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_add_asset() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            portfolio_manager::create_portfolio(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut portfolio = test_scenario::take_from_sender<Portfolio>(&scenario);
            let asset = TestAssetA { value: 100 };
            
            portfolio_manager::add_asset(
                &mut portfolio,
                string::utf8(b"asset1"),
                asset,
                test_scenario::ctx(&mut scenario)
            );
            
            assert!(portfolio_manager::portfolio_total_assets(&portfolio) == 1, 0);
            assert!(
                portfolio_manager::contains_asset(&portfolio, string::utf8(b"asset1")),
                1
            );
            test_scenario::return_to_sender(&scenario, portfolio);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_add_different_types() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            portfolio_manager::create_portfolio(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut portfolio = test_scenario::take_from_sender<Portfolio>(&scenario);
            
            // Add first asset type
            let asset_a = TestAssetA { value: 100 };
            portfolio_manager::add_asset(
                &mut portfolio,
                string::utf8(b"assetA"),
                asset_a,
                test_scenario::ctx(&mut scenario)
            );
            
            // Add second asset type
            let asset_b = TestAssetB { name: string::utf8(b"test") };
            portfolio_manager::add_asset(
                &mut portfolio,
                string::utf8(b"assetB"),
                asset_b,
                test_scenario::ctx(&mut scenario)
            );
            
            assert!(portfolio_manager::portfolio_total_assets(&portfolio) == 2, 0);
            test_scenario::return_to_sender(&scenario, portfolio);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_tag_asset() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            portfolio_manager::create_portfolio(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut portfolio = test_scenario::take_from_sender<Portfolio>(&scenario);
            let asset = TestAssetA { value: 100 };
            
            portfolio_manager::add_asset(
                &mut portfolio,
                string::utf8(b"stocks"),
                asset,
                test_scenario::ctx(&mut scenario)
            );
            
            portfolio_manager::tag_asset(
                &mut portfolio,
                string::utf8(b"stocks"),
                string::utf8(b"equity"),
                test_scenario::ctx(&mut scenario)
            );
            
            let tag = portfolio_manager::get_asset_tag(
                &portfolio,
                string::utf8(b"stocks")
            );
            assert!(tag == string::utf8(b"equity"), 0);
            
            test_scenario::return_to_sender(&scenario, portfolio);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_has_tag() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            portfolio_manager::create_portfolio(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut portfolio = test_scenario::take_from_sender<Portfolio>(&scenario);
            let asset = TestAssetA { value: 200 };
            
            portfolio_manager::add_asset(
                &mut portfolio,
                string::utf8(b"crypto"),
                asset,
                test_scenario::ctx(&mut scenario)
            );
            
            portfolio_manager::tag_asset(
                &mut portfolio,
                string::utf8(b"crypto"),
                string::utf8(b"blockchain"),
                test_scenario::ctx(&mut scenario)
            );
            
            assert!(
                portfolio_manager::has_tag(
                    &portfolio,
                    string::utf8(b"crypto"),
                    string::utf8(b"blockchain")
                ),
                0
            );
            
            assert!(
                !portfolio_manager::has_tag(
                    &portfolio,
                    string::utf8(b"crypto"),
                    string::utf8(b"equity")
                ),
                1
            );
            
            test_scenario::return_to_sender(&scenario, portfolio);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_remove_asset() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            portfolio_manager::create_portfolio(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut portfolio = test_scenario::take_from_sender<Portfolio>(&scenario);
            let asset = TestAssetA { value: 300 };
            
            portfolio_manager::add_asset(
                &mut portfolio,
                string::utf8(b"temp"),
                asset,
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_to_sender(&scenario, portfolio);
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut portfolio = test_scenario::take_from_sender<Portfolio>(&scenario);
            let asset = portfolio_manager::remove_asset<TestAssetA>(
                &mut portfolio,
                string::utf8(b"temp"),
                test_scenario::ctx(&mut scenario)
            );
            
            assert!(asset.value == 300, 0);
            assert!(portfolio_manager::portfolio_total_assets(&portfolio) == 0, 1);
            assert!(
                !portfolio_manager::contains_asset(&portfolio, string::utf8(b"temp")),
                2
            );
            
            let TestAssetA { value: _ } = asset;
            test_scenario::return_to_sender(&scenario, portfolio);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = portfolio_manager::EAssetAlreadyExists)]
    fun test_duplicate_asset_fails() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            portfolio_manager::create_portfolio(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut portfolio = test_scenario::take_from_sender<Portfolio>(&scenario);
            
            let asset1 = TestAssetA { value: 100 };
            portfolio_manager::add_asset(
                &mut portfolio,
                string::utf8(b"same"),
                asset1,
                test_scenario::ctx(&mut scenario)
            );
            
            let asset2 = TestAssetA { value: 200 };
            // This should fail - duplicate name
            portfolio_manager::add_asset(
                &mut portfolio,
                string::utf8(b"same"),
                asset2,
                test_scenario::ctx(&mut scenario)
            );
            
            test_scenario::return_to_sender(&scenario, portfolio);
        };

        test_scenario::end(scenario);
    }
}

