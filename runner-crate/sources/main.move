module suilings::primitives {
/// Returns a small number as u8 type.
public fun get_small_number(): u8 {
    // TODO: This should return a u8 (small number)
    100
}

/// Returns a large number as u64 type.
public fun get_large_number(): u64 {
    // TODO: This should return a u64 (large number)
    1000000
}

/// Adds two u64 numbers and returns the result.
public fun add_numbers(a: u64, b: u64): u64 {
    // TODO: Add the two numbers and return the result
    a + b
}
}

#[test_only]
module suilings::primitives_tests {
use suilings::primitives;

#[test]
    fun small_number() {
        let num = primitives::get_small_number();
        assert!(num == 100);
}

    #[test]
    fun large_number() {
        let num = primitives::get_large_number();
        assert!(num == 1000000);
}

    #[test]
    fun add_numbers() {
        let result = primitives::add_numbers(5, 10);
        assert!(result == 15);
}
}