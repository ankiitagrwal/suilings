// Exercise: Receiving Objects Basics
//
// Create entry functions that receive and process objects.
//
// Stuck? Check out: https://move-book.com/storage/transfer-to-object.html

module suilings::receiving1;
use sui::object::{Self, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};
    
/// Coin with a value
public struct Coin has key, store {
    id: UID,
    value: u64,
}
    
/// Creates a new coin
public fun create_coin(value: u64, ctx: &mut TxContext): Coin {
    Coin {
        id: object::new(ctx),
        value,
    }
}
    
/// Receives a coin and transfers it to a recipient
public fun receive_coin(coin: Coin, recipient: address) {
    // TODO: Transfer the coin to the recipient
}
    
/// Receives a coin and burns it
public fun burn_coin(coin: Coin) {
    // TODO: Destroy the coin
    // Note: UID must be explicitly deleted, it doesn't have 'drop'
    // Hint: object::delete(coin.id);
}
    
/// Returns the coin's value
public fun coin_value(coin: &Coin): u64 {
    coin.value
}

#[test_only]
module suilings::receiving1_tests;

use suilings::receiving1;
use sui::test_scenario;
use sui::test_utils;

#[test]
fun receive_coin_works() {
    let sender = @0x20;
    let recipient = @0x21;
    let mut scenario = test_scenario::begin(sender);
    {
        let ctx = test_scenario::ctx(&mut scenario);
        let coin = receiving1::create_coin(100, ctx);
        
        // In tests, we simulate entry function calls
        receiving1::receive_coin(coin, recipient);
        
        // Verify coin was transferred (in real scenario, check recipient's balance)
    };
    test_scenario::end(scenario);
}

#[test]
fun burn_coin_works() {
    let addr = @0x22;
    let mut scenario = test_scenario::begin(addr);
    {
        let ctx = test_scenario::ctx(&mut scenario);
        let coin = receiving1::create_coin(50, ctx);
        
        receiving1::burn_coin(coin);
        // Coin is destroyed
    };
    test_scenario::end(scenario);
}
