// Exercise: Mutable References
//
// Practice using mutable references to modify values in place.
//
// Stuck? Check out: https://move-book.com/move-basics/references.html

module suilings::mutable_refs;

/// Increments a value by 1
public fun increment(value: &mut u64) {
    // TODO: Increment using *value = *value + 1
}

/// Doubles a value
public fun double(value: &mut u64) {
    // TODO: Multiply by 2
}

/// Adds an amount to the target
public fun add_to(target: &mut u64, amount: u64) {
    // TODO: Add amount to target
}

/// Resets a value to zero
public fun reset(value: &mut u64) {
    // TODO: Set to 0
}

/// Swaps two values
public fun swap_values(a: &mut u64, b: &mut u64) {
    // TODO: Use a temp variable to swap
}

/// Applies a discount percentage to a price
public fun apply_discount(price: &mut u64, discount_percent: u64) {
    // TODO: Reduce price by discount_percent
    // Formula: price = price - (price * discount_percent / 100)
}

#[test_only]
module suilings::mutable_refs_tests;

use suilings::mutable_refs;

#[test]
fun increment_adds_one() {
    let mut x = 5;
    mutable_refs::increment(&mut x);
    assert!(x == 6);
}

#[test]
fun double_multiplies_by_two() {
    let mut x = 10;
    mutable_refs::double(&mut x);
    assert!(x == 20);
}

#[test]
fun add_to_increases_value() {
    let mut x = 100;
    mutable_refs::add_to(&mut x, 50);
    assert!(x == 150);
}

#[test]
fun reset_zeros_value() {
    let mut x = 999;
    mutable_refs::reset(&mut x);
    assert!(x == 0);
}

#[test]
fun swap_exchanges_values() {
    let mut a = 10;
    let mut b = 20;
    mutable_refs::swap_values(&mut a, &mut b);
    assert!(a == 20);
    assert!(b == 10);
}

#[test]
fun discount_reduces_price() {
    let mut price = 100;
    mutable_refs::apply_discount(&mut price, 20); // 20% off
    assert!(price == 80);
}