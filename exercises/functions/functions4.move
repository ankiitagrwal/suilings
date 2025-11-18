// Exercise: Generic Functions
//
// Practice writing generic functions that work with multiple types.
//
// Stuck? Check out: https://move-book.com/move-basics/generics.html

module suilings::generic_functions {

/// Returns the value unchanged (identity function)
public fun identity<T>(value: T): T {
    // TODO: Return value
    value
}

/// Creates a pair (tuple) of two values
public fun create_pair<T: drop, U: drop>(first: T, second: U): (T, U) {
    // TODO: Return (first, second)
    (first, second)
}

/// Attempts to get a default value (intentionally fails)
public fun get_default<T: drop>(_dummy: &T): T {
    // Note: Move doesn't have generic defaults
    // This is here to demonstrate the concept
    abort 0
}

/// Returns first or second value based on condition
public fun compare_and_return_first<T: copy + drop>(a: T, b: T, return_first: bool): T {
    // TODO: if (return_first) a else b
    a
}

/// Returns two copies of the same value
public fun duplicate<T: copy + drop>(value: T): (T, T) {
    // TODO: Return (value, value)
    (value, value)
}

/// Placeholder for equality check (Move has no generic equality)
public fun is_equal<T: drop>(a: T, b: T): bool {
    // Note: Move doesn't have generic equality
    false
    }}

#[test_only]
module suilings::generic_functions_tests {

    use suilings::generic_functions;

    #[test]
    fun identity_works_with_u64() {
    let result = generic_functions::identity<u64>(42);
    assert!(result == 42);
}

#[test]
    fun identity_works_with_bool() {
        let result = generic_functions::identity<bool>(true);
        assert!(result == true);
}

    #[test]
    fun create_pair_works() {
        let (first, second) = generic_functions::create_pair<u64, bool>(10, true);
        assert!(first == 10);
        assert!(second == true);
}

    #[test]
    fun compare_and_return_selects_correctly() {
        let result = generic_functions::compare_and_return_first<u64>(10, 20, true);
        assert!(result == 10);

        let result2 = generic_functions::compare_and_return_first<u64>(10, 20, false);
        assert!(result2 == 20);
}

    #[test]
    fun duplicate_creates_two_copies() {
        let (a, b) = generic_functions::duplicate<u8>(5);
        assert!(a == 5);
        assert!(b == 5);
}
}