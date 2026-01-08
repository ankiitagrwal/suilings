// Exercise: One-Time Witness (OTW) - Token System
//
// Build a token system using One-Time Witness pattern to ensure single initialization.
// OTW ensures that certain operations can only happen once per module deployment.
//
// Stuck? Check out: https://move-book.com/programmability/one-time-witness.html

module suilings::witness1 {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::coin::{Self, Coin};
use sui::balance::{Self, Balance};
use sui::sui::SUI;

// Error constants
const EAlreadyInitialized: u64 = 1;
const EInsufficientBalance: u64 = 2;
const EInvalidAmount: u64 = 3;

/// One-Time Witness: A struct with no abilities and name matching module
/// This can only be created once during module initialization
/// The witness proves that initialization is happening
public struct WITNESS1 has drop {}

/// Treasury that holds the token supply
public struct Treasury has key {
    id: UID,
    /// Total supply of tokens
    total_supply: u64,
    /// Remaining tokens available for minting
    remaining: Balance<SUI>,
    /// Whether treasury has been initialized
    is_initialized: bool,
}

/// Token that can be minted from the treasury
public struct Token has key, store {
    id: UID,
    amount: u64,
}

/// Initialize the treasury (can only be called once)
///
/// Your token system needs a treasury that can only be initialized once.
/// The One-Time Witness pattern ensures this: the WITNESS1 struct can only
/// be created during module initialization, proving this is the first call.
///
/// Implementation Requirements:
/// - Create Treasury with new UID
/// - Convert initial_supply Coin to Balance using coin::into_balance()
/// - Set total_supply = coin::value(&initial_supply)
/// - Set remaining = the converted balance
/// - Set is_initialized = true
/// - Share the treasury using transfer::share_object()
///
/// Note: The witness parameter (WITNESS1) is automatically provided by Sui
/// during module initialization. You don't create it manually.
public fun init_treasury(
    witness: WITNESS1,
    initial_supply: Coin<SUI>,
    ctx: &mut TxContext
) {
    // Your implementation here
    // REMOVE this temporary line after implementation:
    transfer::public_transfer(initial_supply, tx_context::sender(ctx));
}

/// Mint tokens from the treasury
///
/// Create new tokens by withdrawing from the treasury's balance.
/// Only works if treasury has been initialized and has sufficient balance.
///
/// Security Requirements:
/// - Treasury must be initialized (abort with EAlreadyInitialized if !is_initialized)
/// - Amount must be > 0 (abort with EInvalidAmount)
/// - Treasury must have sufficient balance (abort with EInsufficientBalance)
///
/// Minting Operations:
/// - Verify is_initialized
/// - Verify amount > 0
/// - Check balance::value(&treasury.remaining) >= amount
/// - Split balance: balance::split(&mut treasury.remaining, amount)
/// - Convert to Coin: coin::from_balance()
/// - Create Token with new UID and amount
/// - Transfer token to sender
public fun mint(
    treasury: &mut Treasury,
    amount: u64,
    ctx: &mut TxContext
) {
    // Your implementation here
}

/// Get treasury information
///
/// Query the treasury's total supply and remaining balance.
/// Useful for UI displays and supply tracking.
public fun treasury_info(treasury: &Treasury): (u64, u64) {
    (
        treasury.total_supply,
        balance::value(&treasury.remaining)
    )
}

/// Check if treasury is initialized
public fun is_initialized(treasury: &Treasury): bool {
    treasury.is_initialized
}

/// Get token amount
public fun token_amount(token: &Token): u64 {
    token.amount
}

#[test_only]
public fun create_witness_for_testing(): WITNESS1 {
    WITNESS1 {}
}
}

#[test_only]
module suilings::witness1_tests {
use suilings::witness1::{Self, Treasury, Token};
use sui::test_scenario;
use sui::coin;
use sui::sui::SUI;

const ADMIN: address = @0xAD;
const USER: address = @0x01;

#[test]
fun test_treasury_initialization() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let initial = coin::mint_for_testing<SUI>(1000, test_scenario::ctx(&mut scenario));
        witness1::init_treasury(
            witness1::create_witness_for_testing(),
            initial,
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let treasury = test_scenario::take_shared<Treasury>(&scenario);
        let (total, remaining) = witness1::treasury_info(&treasury);
        assert!(total == 1000, 0);
        assert!(remaining == 1000, 1);
        assert!(witness1::is_initialized(&treasury), 2);
        test_scenario::return_shared(treasury);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_mint_tokens() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let initial = coin::mint_for_testing<SUI>(1000, test_scenario::ctx(&mut scenario));
        witness1::init_treasury(
            witness1::create_witness_for_testing(),
            initial,
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, USER);
    {
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        witness1::mint(&mut treasury, 100, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(treasury);
    };

    test_scenario::next_tx(&mut scenario, USER);
    {
        let token = test_scenario::take_from_sender<Token>(&scenario);
        assert!(witness1::token_amount(&token) == 100, 0);
        let treasury = test_scenario::take_shared<Treasury>(&scenario);
        let (_, remaining) = witness1::treasury_info(&treasury);
        assert!(remaining == 900, 1);
        test_scenario::return_shared(treasury);
        sui::test_utils::destroy(token);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_multiple_mints() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let initial = coin::mint_for_testing<SUI>(1000, test_scenario::ctx(&mut scenario));
        witness1::init_treasury(
            witness1::create_witness_for_testing(),
            initial,
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, USER);
    {
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        witness1::mint(&mut treasury, 200, test_scenario::ctx(&mut scenario));
        witness1::mint(&mut treasury, 300, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(treasury);
    };

    test_scenario::next_tx(&mut scenario, USER);
    {
        let token1 = test_scenario::take_from_sender<Token>(&scenario);
        let token2 = test_scenario::take_from_sender<Token>(&scenario);
        
        // Tokens may be returned in any order, so check both amounts exist
        let amount1 = witness1::token_amount(&token1);
        let amount2 = witness1::token_amount(&token2);
        assert!(
            (amount1 == 200 && amount2 == 300) || (amount1 == 300 && amount2 == 200),
            0
        );
        
        let treasury = test_scenario::take_shared<Treasury>(&scenario);
        let (_, remaining) = witness1::treasury_info(&treasury);
        assert!(remaining == 500, 1);
        test_scenario::return_shared(treasury);
        
        sui::test_utils::destroy(token1);
        sui::test_utils::destroy(token2);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = witness1::EInvalidAmount)]
fun test_mint_zero_fails() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let initial = coin::mint_for_testing<SUI>(1000, test_scenario::ctx(&mut scenario));
        witness1::init_treasury(
            witness1::create_witness_for_testing(),
            initial,
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, USER);
    {
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        // This should fail - amount must be > 0
        witness1::mint(&mut treasury, 0, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(treasury);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = witness1::EInsufficientBalance)]
fun test_mint_exceeds_balance_fails() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let initial = coin::mint_for_testing<SUI>(100, test_scenario::ctx(&mut scenario));
        witness1::init_treasury(
            witness1::create_witness_for_testing(),
            initial,
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, USER);
    {
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        // This should fail - amount > remaining balance
        witness1::mint(&mut treasury, 200, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(treasury);
    };

    test_scenario::end(scenario);
}
}

