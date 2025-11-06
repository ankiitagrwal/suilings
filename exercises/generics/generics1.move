// Generics in Move can have multiple type parameters and constraints.
//
// Phantom type parameters are used when a type parameter doesn't appear
// in any fields but is needed for type safety.
//
// Multiple constraints: <T: copy + drop + store>
//
// Your task:
// Work with advanced generic patterns.

module suilings::generics1 {
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
    
    public fun create_pair<T: drop, U: drop>(first: T, second: U): Pair<T, U> {
        // TODO: Create and return a Pair
        abort 0
    }
    
    public fun swap_pair<T: drop, U: drop>(pair: Pair<T, U>): Pair<U, T> {
        // TODO: Destructure the pair and create a new one with swapped values
        abort 0
    }
    
    public fun ok<T: drop, E: drop>(value: T): Result<T, E> {
        // TODO: Create a successful Result with the value
        abort 0
    }
    
    public fun err<T: drop, E: drop>(error: E): Result<T, E> {
        // TODO: Create an error Result with the error value
        abort 0
    }
    
    public fun is_ok<T: drop, E: drop>(result: &Result<T, E>): bool {
        // TODO: Return true if result is ok (has a value in ok field)
        false
    }
    
    // Generic function to find element in vector by value
    // Note: Move doesn't support lambdas/closures, so we find by comparing with a value
   // Find first index of an element > threshold (matches your test)
    public fun find(vec: &vector<u64>, threshold: u64): Option<u64> {
        let len = vector::length(vec);
        let mut i = 0;
        while (i < len) {
            if (*vector::borrow(vec, i) > threshold) {
                return option::some(i)
            };
            i = i + 1;
        };
        option::none()
    }

    // Map u64 vector by multiplying each element by `factor` (matches your test)
    public fun map(vec: vector<u64>, factor: u64): vector<u64> {
        let len = vector::length(&vec);
        let mut out = vector::empty<u64>();
        let mut i = 0;
        while (i < len) {
            let x = *vector::borrow(&vec, i);
            vector::push_back(&mut out, x * factor);
            i = i + 1;
        };
        out
    }
}

#[test_only]
module suilings::generics1_tests {
    use suilings::generics1;
    use std::option;
    
    #[test]
    fun test_pair() {
        let pair = generics1::create_pair(42u64, b"hello");
        let swapped = generics1::swap_pair(pair);
        // swapped should now be Pair<vector<u8>, u64>
        sui::test_utils::destroy(swapped);
    }
    
    #[test]
    fun test_result_ok() {
        let result = generics1::ok<u64, vector<u8>>(100);
        assert!(generics1::is_ok(&result), 0);
        sui::test_utils::destroy(result);
    }
    
    #[test]
    fun test_result_err() {
        let result = generics1::err<u64, vector<u8>>(b"error");
        assert!(!generics1::is_ok(&result), 0);
        sui::test_utils::destroy(result);
    }
    
    #[test]
    fun test_find() {
        use std::vector;
        let vec = vector[1u64, 2, 3, 4, 5];
        
        // Find first element greater than 3
        let idx = generics1::find(&vec, 3);
        assert!(option::is_some(&idx), 0);
        assert!(*option::borrow(&idx) == 3, 1); // index of 4
    }
    
    #[test]
    fun test_map() {
        use std::vector;
        let vec = vector[1u64, 2, 3, 4];
        
        // Double each element
        let doubled = generics1::map(vec, 2);
        assert!(*vector::borrow(&doubled, 0) == 2, 0);
        assert!(*vector::borrow(&doubled, 3) == 8, 1);
    }
}

