// Exercise: Advanced Generics
//
// Work with multiple type parameters, constraints, and generic patterns.
//
// Stuck? Check out: https://move-book.com/move-basics/generics.html

module suilings::generics1;
use std::vector;
use std::option::{Self, Option};
    
// TODO: Define a Pair<T, U> struct that can hold two different types
// Both T and U should have drop ability
// The struct itself should have drop ability
// Fields: first: T, second: U
    
// TODO: Define a Result<T, E> struct (like Rust's Result)
// It should have drop ability if both T and E have drop
// Use an Option for success value and Option for error value
// Fields: ok: Option<T>, err: Option<E>
    
/// Creates a pair of two values
public fun create_pair<T: drop, U: drop>(first: T, second: U): Pair<T, U> {
    // TODO: Create and return a Pair
    abort 0
}
    
/// Swaps the values in a pair
public fun swap_pair<T: drop, U: drop>(pair: Pair<T, U>): Pair<U, T> {
    // TODO: Destructure the pair and create a new one with swapped values
    abort 0
}
    
/// Creates a successful Result
public fun ok<T: drop, E: drop>(value: T): Result<T, E> {
    // TODO: Create a successful Result with the value
    abort 0
}
    
/// Creates an error Result
public fun err<T: drop, E: drop>(error: E): Result<T, E> {
    // TODO: Create an error Result with the error value
    abort 0
}
    
/// Checks if a Result is ok
public fun is_ok<T: drop, E: drop>(result: &Result<T, E>): bool {
    // TODO: Return true if result is ok (has a value in ok field)
    false
}
    
/// Finds the first element in a vector greater than threshold
public fun find(vec: &vector<u64>, threshold: u64): Option<u64> {
    let len = vec.length();
    let mut i = 0;
    while (i < len) {
        if (*vector::borrow(vec, i) > threshold) {
            return option::some(i)
        };
        i = i + 1;
    };
    option::none()
}

/// Maps a vector by multiplying each element by factor
public fun map(vec: vector<u64>, factor: u64): vector<u64> {
    let len = vec.length();
    let mut out = vector::empty<u64>();
    let mut i = 0;
    while (i < len) {
        let x = *vector::borrow(&vec, i);
        vector::push_back(&mut out, x * factor);
        i = i + 1;
    };
    out
}

#[test_only]
module suilings::generics1_tests;

use suilings::generics1;
use std::option;

#[test]
fun pair_works() {
    let pair = generics1::create_pair(42u64, b"hello");
    let swapped = generics1::swap_pair(pair);
    // swapped should now be Pair<vector<u8>, u64>
    sui::test_utils::destroy(swapped);
}

#[test]
fun result_ok_works() {
    let result = generics1::ok<u64, vector<u8>>(100);
    assert!(generics1::is_ok(&result));
    sui::test_utils::destroy(result);
}

#[test]
fun result_err_works() {
    let result = generics1::err<u64, vector<u8>>(b"error");
    assert!(!generics1::is_ok(&result));
    sui::test_utils::destroy(result);
}

#[test]
fun find_works() {
    use std::vector;
    let vec = vector[1u64, 2, 3, 4, 5];
    
    // Find first element greater than 3
    let idx = generics1::find(&vec, 3);
    assert!(option::is_some(&idx));
    assert!(*option::borrow(&idx) == 3); // index of 4
}

#[test]
fun map_works() {
    use std::vector;
    let vec = vector[1u64, 2, 3, 4];
    
    // Double each element
    let doubled = generics1::map(vec, 2);
    assert!(*vector::borrow(&doubled) == 2);
    assert!(*vector::borrow(&doubled) == 8);
}
