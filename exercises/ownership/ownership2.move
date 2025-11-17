// Exercise: References and Borrowing
//
// Use references to borrow values without taking ownership.
//
// Stuck? Check out: https://move-book.com/move-basics/references.html

module suilings::ownership2;
/// A counter with a value
public struct Counter has drop {
    value: u64,
}
    
/// Creates a new counter
public fun create_counter(initial: u64): Counter {
    Counter { value: initial }
}
    
/// Reads the counter's value using an immutable reference
public fun read_value(counter: &Counter): u64 {
    // TODO: Return the counter's value using a reference
    0
}
    
/// Increments the counter's value by 1
public fun increment(counter: &mut Counter) {
    // TODO: Increment the counter's value by 1
    // Use mutable reference to modify
}
    
/// Adds an amount to the counter's value
public fun add_to_counter(counter: &mut Counter, amount: u64) {
    // TODO: Add amount to the counter's value
}
    
/// Gets the current value and then increments
public fun get_and_increment(counter: &mut Counter): u64 {
    // TODO: Get the current value, then increment
    // Return the old value
    0
}

#[test_only]
module suilings::ownership2_tests;

use suilings::ownership2;

#[test]
fun read_without_move_works() {
    let counter = ownership2::create_counter(10);
    let value1 = ownership2::read_value(&counter);
    let value2 = ownership2::read_value(&counter); // Can use again!
    assert!(value1 == 10);
    assert!(value2 == 10);
}

#[test]
fun increment_works() {
    let mut counter = ownership2::create_counter(5);
    ownership2::increment(&mut counter);
    assert!(ownership2::read_value(&counter) == 6);
    
    ownership2::add_to_counter(&mut counter, 4);
    assert!(ownership2::read_value(&counter) == 10);
}

#[test]
fun get_and_increment_works() {
    let mut counter = ownership2::create_counter(7);
    let old = ownership2::get_and_increment(&mut counter);
    assert!(old == 7);
    assert!(ownership2::read_value(&counter) == 8);
}
