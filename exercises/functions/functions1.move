// Exercise: Functions in Move
//
// Practice declaring and implementing functions with parameters and return values.
//
// Stuck? Check out: https://move-book.com/move-basics/function.html

module suilings::functions {
/// Multiplies two numbers and returns the product.
public fun multiply(a: u64, b: u64): u64 {
    // TODO: Return the product of a and b
    0
}

/// Calculates the square of a number.
public fun square(num: u64): u64 {
    // TODO: Return the square of num (num * num)
    0
}

/// Returns the maximum of two numbers.
public fun max(a: u64, b: u64): u64 {
    // TODO: Return the larger of the two numbers
    0
    }}

#[test_only]
module suilings::functions_tests {
    use suilings::functions;

    #[test]
    fun multiply() {
    assert!(functions::multiply(5) == 30);
    assert!(functions::multiply(0) == 0);
}

#[test]
    fun square() {
        assert!(functions::square(5) == 25);
        assert!(functions::square(10) == 100);
}

    #[test]
    fun max() {
        assert!(functions::max(10) == 10);
        assert!(functions::max(3) == 7);
        assert!(functions::max(5) == 5);
}

}