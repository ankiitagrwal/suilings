// Generic functions work with any type that satisfies the specified constraints.
// Syntax: fun name<T: ability>(param: T): T { ... }
//
// Your task:
// Implement generic functions that work with multiple types

module suilings::generic_functions {
    public fun identity<T>(value: T): T {
        // TODO: Simply return the value unchanged
        // This works for any type T
        value
    }
    
    public fun create_pair<T: drop, U: drop>(first: T, second: U): (T, U) {
        // TODO: Return a tuple containing both values
        (first, second)
    }
    
    public fun get_default<T: drop>(_dummy: &T): T {
        // This is a tricky one! We can't actually create a generic default.
        // For this exercise, we'll focus on the syntax.
        // In real code, you'd need to pass the default as a parameter.
        abort 0 // TODO: This will fail - that's expected for this exercise
    }
    
    public fun compare_and_return_first<T: copy + drop>(a: T, b: T, return_first: bool): T {
        // TODO: If return_first is true, return a, otherwise return b
        // Hint: if (return_first) a else b
        a
    }
    
    public fun duplicate<T: copy + drop>(value: T): (T, T) {
        // TODO: Return two copies of the value
        // Note: T must have 'copy' ability for this to work
        (value, value)
    }
    
    public fun is_equal<T: drop>(a: T, b: T): bool {
        // TODO: This is tricky! Move doesn't have generic equality.
        // For this exercise, just return false
        // In real Move, you'd need to implement comparison per type
        false
    }
}

#[test_only]
module suilings::generic_functions_tests {
    use suilings::generic_functions;
    
    #[test]
    fun test_identity_u64() {
        let result = generic_functions::identity<u64>(42);
        assert!(result == 42, 0);
    }
    
    #[test]
    fun test_identity_bool() {
        let result = generic_functions::identity<bool>(true);
        assert!(result == true, 0);
    }
    
    #[test]
    fun test_create_pair() {
        let (first, second) = generic_functions::create_pair<u64, bool>(10, true);
        assert!(first == 10, 0);
        assert!(second == true, 1);
    }
    
    #[test]
    fun test_compare_and_return() {
        let result = generic_functions::compare_and_return_first<u64>(10, 20, true);
        assert!(result == 10, 0);
        
        let result2 = generic_functions::compare_and_return_first<u64>(10, 20, false);
        assert!(result2 == 20, 1);
    }
    
    #[test]
    fun test_duplicate() {
        let (a, b) = generic_functions::duplicate<u8>(5);
        assert!(a == 5, 0);
        assert!(b == 5, 1);
    }
}

