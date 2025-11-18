// Exercise: Advanced Receiving Patterns
//
// Handle shared objects and mutable operations in entry functions.
//
// Stuck? Check out: https://move-book.com/storage/transfer-to-object.html

module suilings::receiving3 {
use sui::object::{Self, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};

/// Counter that can be shared
public struct Counter has key {
    id: UID,
    value: u64,
}

/// Coin with a value
public struct Coin has key, store {
    id: UID,
    value: u64,
}

/// Creates a new counter
public fun create_counter(initial: u64, ctx: &mut TxContext): Counter {
    Counter {
    id: object::new(ctx),
    value: initial,
}
}

/// Creates a new coin
    public fun create_coin(value: u64, ctx: &mut TxContext): Coin {
        Coin {
        id: object::new(ctx),
        value,
}
}

/// Increments the counter
    public fun increment_counter(counter: &mut Counter) {
// TODO: Increment the counter's value
// Entry functions can take mutable references to shared objects
}

/// Adds a coin's value to the counter and destroys the coin
    public fun add_to_counter(counter: &mut Counter, coin: Coin) {
// TODO: Add coin's value to counter, then destroy the coin
}

/// Transfers a coin and updates the counter
    public fun transfer_and_update(counter: &mut Counter, coin: Coin, recipient: address, ctx: &mut TxContext) {
// TODO: Add coin value to counter, then transfer a new coin to recipient
// Create new coin with same value and transfer it
}

/// Returns the counter's value
    public fun counter_value(counter: &Counter): u64 {
        counter.value
        }}

#[test_only]
module suilings::receiving3_tests {

use suilings::receiving3;
use sui::test_scenario;
use sui::test_utils;

#[test]
    fun increment_counter_works() {
        let addr = @0x26;
        let mut scenario = test_scenario::begin(addr);
        {
        let ctx = test_scenario::ctx(&mut scenario);
        let mut counter = receiving3::create_counter(10, ctx);

        receiving3::increment_counter(&mut counter);
        assert!(receiving3::counter_value(&counter) == 11);

        test_utils::destroy(counter);
        };
        test_scenario::end(scenario);
}

    #[test]
    fun add_to_counter_works() {
        let addr = @0x27;
        let mut scenario = test_scenario::begin(addr);
        {
        let ctx = test_scenario::ctx(&mut scenario);
        let mut counter = receiving3::create_counter(5, ctx);
        let coin = receiving3::create_coin(20, ctx);

        receiving3::add_to_counter(&mut counter, coin);
        assert!(receiving3::counter_value(&counter) == 25);

        test_utils::destroy(counter);
        };
        test_scenario::end(scenario);
}

}