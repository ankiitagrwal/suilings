// Exercise: Option Type Basics
//
// Practice using Option<T> to handle values that may or may not exist.
//
// Stuck? Check out: https://move-book.com/move-basics/option.html

module suilings::options1 {

use std::option::{Self, Option};

/// Safe division that returns None when dividing by zero
public fun divide(a: u64, b: u64): Option<u64> {
    // TODO: Return Some(a / b) if b != 0, otherwise None
    option::none()
}

/// Returns the value in opt if it exists, otherwise returns default
public fun get_or_default(opt: Option<u64>, default: u64): u64 {
    // TODO: Extract value or use default
    // Modern: opt.destroy_or!(default)
    0
}

/// Finds target in vector and returns its index
public fun find_in_vector(vec: vector<u64>, target: u64): Option<u64> {
    // TODO: Return Some(index) if found, None otherwise
    option::none()
}

/// Returns the maximum of two optional values
public fun max_of_options(a: Option<u64>, b: Option<u64>): Option<u64> {
    // TODO: Return max if both exist, one if only one exists, None if neither
    option::none()
    }}

#[test_only]
module suilings::options1_tests {

    use suilings::options1;
    use std::option;

    #[test]
    fun divide_returns_some_when_valid() {
    let result = options1::divide(10, 2);
    assert!(option::is_some(&result));
    assert!(*option::borrow(&result) == 5);

    let result2 = options1::divide(10, 0);
    assert!(option::is_none(&result2));
}

#[test]
    fun get_or_default_handles_both_cases() {
        let some_val = option::some(42);
        assert!(options1::get_or_default(some_val) == 42);

        let none_val = option::none();
        assert!(options1::get_or_default(none_val) == 99);
}

    #[test]
    fun find_in_vector_locates_elements() {
        let vec = vector[10, 20, 30, 40];

        let result = options1::find_in_vector(vec, 30);
        assert!(option::is_some(&result));
        assert!(*option::borrow(&result) == 2);

        let result2 = options1::find_in_vector(vec, 99);
        assert!(option::is_none(&result2));
}

    #[test]
    fun max_of_options_handles_all_cases() {
        let a = option::some(10);
        let b = option::some(20);
        let result = options1::max_of_options(a, b);
        assert!(*option::borrow(&result) == 20);

        let c = option::some(15);
        let d = option::none();
        let result2 = options1::max_of_options(c, d);
        assert!(*option::borrow(&result2) == 15);

        let e = option::none();
        let f = option::none();
        let result3 = options1::max_of_options(e, f);
        assert!(option::is_none(&result3));
}
}