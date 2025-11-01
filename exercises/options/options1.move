// ==== OPTION TYPE - BASICS ====
// Option<T> represents a value that may or may not exist.
// It's Move's way of handling nullable values safely.
//
// Option has two variants:
// - option::some(value) - contains a value
// - option::none() - empty/null
//
// Common operations:
// - option::is_some(&opt) - check if has value
// - option::is_none(&opt) - check if empty
// - option::borrow(&opt) - get reference (panics if none)
// - option::contains(&opt, &val) - check specific value
// - option::destroy_some(opt) - extract value (panics if none)
// - option::destroy_none(opt) - destroy if none (panics if some)
//
// Your task:
// Work with Option types to handle optional values.

module suilings::options1 {
    use std::option::{Self, Option};
    
    public fun divide(a: u64, b: u64): Option<u64> {
        // TODO: Return Some(a / b) if b != 0, otherwise None
        option::none()
    }
    
    public fun get_or_default(opt: Option<u64>, default: u64): u64 {
        // TODO: Return the value in opt if it exists, otherwise return default
        0
    }
    
    public fun find_in_vector(vec: vector<u64>, target: u64): Option<u64> {
        // TODO: Return Some(index) if target is found, otherwise None
        option::none()
    }
    
    public fun max_of_options(a: Option<u64>, b: Option<u64>): Option<u64> {
        // TODO: Return the maximum value if both exist
        // If only one exists, return that one
        // If neither exist, return None
        option::none()
    }
}

#[test_only]
module suilings::options1_tests {
    use suilings::options1;
    use std::option;
    
    #[test]
    fun test_divide() {
        let result = options1::divide(10, 2);
        assert!(option::is_some(&result), 0);
        assert!(*option::borrow(&result) == 5, 1);
        
        let result2 = options1::divide(10, 0);
        assert!(option::is_none(&result2), 2);
    }
    
    #[test]
    fun test_get_or_default() {
        let some_val = option::some(42);
        assert!(options1::get_or_default(some_val, 0) == 42, 0);
        
        let none_val = option::none();
        assert!(options1::get_or_default(none_val, 99) == 99, 1);
    }
    
    #[test]
    fun test_find_in_vector() {
        use std::vector;
        let vec = vector[10, 20, 30, 40];
        
        let result = options1::find_in_vector(vec, 30);
        assert!(option::is_some(&result), 0);
        assert!(*option::borrow(&result) == 2, 1);
        
        let result2 = options1::find_in_vector(vec, 99);
        assert!(option::is_none(&result2), 2);
    }
    
    #[test]
    fun test_max_of_options() {
        let a = option::some(10);
        let b = option::some(20);
        let result = options1::max_of_options(a, b);
        assert!(*option::borrow(&result) == 20, 0);
        
        let c = option::some(15);
        let d = option::none();
        let result2 = options1::max_of_options(c, d);
        assert!(*option::borrow(&result2) == 15, 1);
        
        let e = option::none();
        let f = option::none();
        let result3 = options1::max_of_options(e, f);
        assert!(option::is_none(&result3), 2);
    }
}

