// Exercise: Multiple Return Values
//
// Practice functions that return multiple values using tuples.
//
// Stuck? Check out: https://move-book.com/move-basics/function.html

module suilings::multiple_returns {

/// Returns both quotient and remainder from division
public fun divide_with_remainder(dividend: u64, divisor: u64): (u64, u64) {
    // TODO: Return (quotient, remainder)
    (0, 0)
}

/// Returns the minimum and maximum of two numbers
public fun min_max(a: u64, b: u64): (u64, u64) {
    // TODO: Return (min, max)
    (0, 0)
}

/// Splits a name into first and last (simplified version)
public fun split_name(full_name: vector<u8>): (vector<u8>, vector<u8>) {
    // TODO: For simplicity, return the same name twice
    (b"", b"")
}

/// Swaps two values
public fun swap(a: u64, b: u64): (u64, u64) {
    // TODO: Return (b, a)
    (0, 0)
}

/// Calculates area and perimeter of a rectangle
public fun calculate_rectangle(width: u64, height: u64): (u64, u64) {
    // TODO: Return (area, perimeter)
    // area = width * height, perimeter = 2 * (width + height)
    (0, 0)
    }}

#[test_only]
module suilings::multiple_returns_tests {

    use suilings::multiple_returns;

    #[test]
    fun divide_with_remainder_works() {
    let (quotient, remainder) = multiple_returns::divide_with_remainder(17, 5);
    assert!(quotient == 3);
    assert!(remainder == 2);
}

#[test]
    fun min_max_returns_correct_values() {
        let (min, max) = multiple_returns::min_max(10, 5);
        assert!(min == 5);
        assert!(max == 10);

        let (min2, max2) = multiple_returns::min_max(3, 8);
        assert!(min2 == 3);
        assert!(max2 == 8);
}

    #[test]
    fun swap_exchanges_values() {
        let (a, b) = multiple_returns::swap(10, 20);
        assert!(a == 20);
        assert!(b == 10);
}

    #[test]
    fun rectangle_calculations_correct() {
        let (area, perimeter) = multiple_returns::calculate_rectangle(5, 10);
        assert!(area == 50);
        assert!(perimeter == 30);
}
}