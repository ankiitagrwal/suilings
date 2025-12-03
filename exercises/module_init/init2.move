// Exercise: Module Initializer - Token System
//
// Create a token system where the initial supply is minted during module initialization.
// The publisher gets special minting privileges through initialization.
//
// Stuck? Check out: https://move-book.com/programmability/module-initializer.html

module suilings::init2 {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::balance::{Self, Balance};
use sui::coin::{Self, Coin};

/// One-time witness for the token

// Error constants
const ENoRemainingMints: u64 = 1;
const EExceedsSupply: u64 = 2;

public struct INIT2 has drop {}

/// Treasury that manages the token supply
public struct Treasury has key {
    id: UID,
    total_supply: u64,
    circulating_supply: u64,
    minter: address,
}

/// Minting capability given to the publisher
public struct MintCap has key, store {
    id: UID,
    remaining_mints: u64,
}

/// Token that can be minted
public struct Token has key, store {
    id: UID,
    value: u64,
}

/// Module Initializer with One-Time Witness Pattern
/// 
/// Your project is launching a token with controlled supply. The init function
/// uses the One-Time Witness (OTW) pattern - a struct that can only be created
/// once, proving this is the authentic initialization.
///
/// Token Economics Setup:
/// - Total supply cap: 1 billion tokens (1_000_000_000)
/// - Initial circulating supply: 0 (minted on demand)
/// - The publisher becomes the official minter
///
/// Minting Privileges:
/// - Create a MintCap with limited mints (10 minting operations)
/// - This prevents unlimited token creation
/// - MintCap is sent to the publisher
///
/// The witness parameter (INIT2) guarantees this init only runs once
fun init(witness: INIT2, ctx: &mut TxContext) {
    // Your implementation here
}

/// Mint new tokens to a recipient
/// 
/// As the authorized minter, create new tokens within the supply limits.
///
/// Minting Controls:
/// - Limited by remaining mints in MintCap (prevents unlimited minting)
/// - Amount cannot exceed remaining available supply
/// - Each mint decrements the cap's remaining uses
///
/// Supply Tracking:
/// - Increase circulating_supply to track tokens in circulation
/// - Create a Token object with the specified value
/// - Transfer to the designated recipient
public fun mint(
    treasury: &mut Treasury,
    cap: &mut MintCap,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext
) {
    // Your implementation here
}

/// Burn tokens to reduce circulating supply
/// 
/// Tokens can be permanently destroyed, reducing the circulating supply.
/// This is useful for deflationary mechanics or token buybacks.
///
/// Burn Process:
/// - Unpack the token to access its value and id
/// - Reduce treasury's circulating_supply by the token's value
/// - Delete the token's UID (permanently destroys it)
public fun burn(treasury: &mut Treasury, token: Token) {
    // Your implementation here
}

/// Get treasury information
public fun treasury_info(treasury: &Treasury): (u64, u64, address) {
    // Return (total_supply, circulating_supply, minter)
    (0, 0, @0x0)
}

/// Get remaining mints from capability
public fun remaining_mints(cap: &MintCap): u64 {
    // Return remaining_mints count
    0
}

/// Get token value
public fun token_value(token: &Token): u64 {
    // Return the token's value
    0
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    // Create the witness and call init
    // let witness = INIT2 {};
    // init(witness, ctx);
}
}

#[test_only]
module suilings::init2_tests {
use suilings::init2::{Self, Treasury, MintCap, Token};
use sui::test_scenario;

#[test]
fun test_init_creates_treasury() {
    let publisher = @0xCAFE;
    let mut scenario = test_scenario::begin(publisher);
    
    // Simulate init
    {
        init2::init_for_testing(test_scenario::ctx(&mut scenario));
    };
    
    // Check treasury
    test_scenario::next_tx(&mut scenario, publisher);
    {
        let treasury = test_scenario::take_shared<Treasury>(&scenario);
        let cap = test_scenario::take_from_sender<MintCap>(&scenario);
        
        let (total, circulating, minter) = init2::treasury_info(&treasury);
        assert!(total == 1_000_000_000, 0);
        assert!(circulating == 0, 1);
        assert!(minter == publisher, 2);
        assert!(init2::remaining_mints(&cap) == 10, 3);
        
        test_scenario::return_shared(treasury);
        test_scenario::return_to_sender(&scenario, cap);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_minting_tokens() {
    let publisher = @0xCAFE;
    let recipient = @0xA;
    let mut scenario = test_scenario::begin(publisher);
    
    // Init
    {
        init2::init_for_testing(test_scenario::ctx(&mut scenario));
    };
    
    // Mint tokens
    test_scenario::next_tx(&mut scenario, publisher);
    {
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        let mut cap = test_scenario::take_from_sender<MintCap>(&scenario);
        
        init2::mint(&mut treasury, &mut cap, 1000, recipient, test_scenario::ctx(&mut scenario));
        
        let (_, circulating, _) = init2::treasury_info(&treasury);
        assert!(circulating == 1000, 0);
        assert!(init2::remaining_mints(&cap) == 9, 1);
        
        test_scenario::return_shared(treasury);
        test_scenario::return_to_sender(&scenario, cap);
    };
    
    // Check recipient received token
    test_scenario::next_tx(&mut scenario, recipient);
    {
        let token = test_scenario::take_from_sender<Token>(&scenario);
        assert!(init2::token_value(&token) == 1000, 0);
        test_scenario::return_to_sender(&scenario, token);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_burning_tokens() {
    let publisher = @0xCAFE;
    let recipient = @0xA;
    let mut scenario = test_scenario::begin(publisher);
    
    // Init and mint
    {
        init2::init_for_testing(test_scenario::ctx(&mut scenario));
    };
    
    test_scenario::next_tx(&mut scenario, publisher);
    {
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        let mut cap = test_scenario::take_from_sender<MintCap>(&scenario);
        init2::mint(&mut treasury, &mut cap, 1000, recipient, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(treasury);
        test_scenario::return_to_sender(&scenario, cap);
    };
    
    // Burn token
    test_scenario::next_tx(&mut scenario, recipient);
    {
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        let token = test_scenario::take_from_sender<Token>(&scenario);
        
        init2::burn(&mut treasury, token);
        
        let (_, circulating, _) = init2::treasury_info(&treasury);
        assert!(circulating == 0, 0);
        
        test_scenario::return_shared(treasury);
    };
    
    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = 1)]
fun test_mint_cap_exhaustion() {
    let publisher = @0xCAFE;
    let recipient = @0xA;
    let mut scenario = test_scenario::begin(publisher);
    
    // Init
    {
        init2::init_for_testing(test_scenario::ctx(&mut scenario));
    };
    
    // Mint 11 times (should fail on 11th)
    test_scenario::next_tx(&mut scenario, publisher);
    {
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        let mut cap = test_scenario::take_from_sender<MintCap>(&scenario);
        
        let mut i = 0;
        while (i < 11) {
            init2::mint(&mut treasury, &mut cap, 100, recipient, test_scenario::ctx(&mut scenario));
            i = i + 1;
        };
        
        test_scenario::return_shared(treasury);
        test_scenario::return_to_sender(&scenario, cap);
    };
    
    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = 2)]
fun test_mint_exceeds_supply() {
    let publisher = @0xCAFE;
    let recipient = @0xA;
    let mut scenario = test_scenario::begin(publisher);
    
    // Init
    {
        init2::init_for_testing(test_scenario::ctx(&mut scenario));
    };
    
    // Try to mint more than total supply
    test_scenario::next_tx(&mut scenario, publisher);
    {
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        let mut cap = test_scenario::take_from_sender<MintCap>(&scenario);
        
        init2::mint(&mut treasury, &mut cap, 2_000_000_000, recipient, test_scenario::ctx(&mut scenario));
        
        test_scenario::return_shared(treasury);
        test_scenario::return_to_sender(&scenario, cap);
    };
    
    test_scenario::end(scenario);
}
}
