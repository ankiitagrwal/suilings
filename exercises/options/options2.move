// Exercise: Error Handling with Assert
//
// Practice proper error handling using assert and error constants.
//
// Stuck? Check out: https://move-book.com/guides/better-error-handling.html

module suilings::options2 {

// Error constants use EPascalCase naming
const EDivisionByZero: u64 = 0;
const EOutOfRange: u64 = 1;
const EEmptyVector: u64 = 2;
const EInvalidAmount: u64 = 3;
const EInsufficientBalance: u64 = 4;

/// Safe division with zero check
public fun safe_divide(a: u64, b: u64): u64 {
    // TODO: Assert b != 0 with EDivisionByZero, then return a / b
    0
}

/// Gets element at index with bounds checking
public fun element(vec: &vector<u64>, index: u64): u64 {
    // TODO: Assert index < vec.length() with EOutOfRange
    0
}

/// Calculates average of vector elements
public fun calculate_average(numbers: vector<u64>): u64 {
    // TODO: Assert vector is not empty with EEmptyVector
    0
}

/// Simulates withdrawing from a bank account
public fun withdraw(balance: u64, amount: u64): u64 {
    // TODO: Assert amount > 0 with EInvalidAmount
    // TODO: Assert amount <= balance with EInsufficientBalance
    0
    }}

#[test_only]
module suilings::options2_tests {

    use suilings::options2;

    #[test]
    fun safe_divide_works() {
    assert!(options2::safe_divide(10) == 5);
    assert!(options2::safe_divide(100) == 25);
}

#[test, expected_failure(abort_code = 0)]
    fun divide_by_zero_aborts() {
        options2::safe_divide(10, 0);
}

    #[test]
    fun element_returns_correct_value() {
        let vec = vector[10, 20, 30, 40];
        assert!(options2::element(&vec) == 10);
        assert!(options2::element(&vec) == 30);
}

    #[test, expected_failure(abort_code = 1)]
    fun element_out_of_range_aborts() {
        let vec = vector[10, 20];
        options2::element(&vec, 5);
}

    #[test]
    fun calculate_average_works() {
        let nums = vector[10, 20, 30, 40];
        assert!(options2::calculate_average(nums) == 25);

        let nums2 = vector[100, 200];
        assert!(options2::calculate_average(nums2) == 150);
}

    #[test, expected_failure(abort_code = 2)]
    fun average_empty_vector_aborts() {
        let empty = vector[];
        options2::calculate_average(empty);
}

    #[test]
    fun withdraw_calculates_new_balance() {
        assert!(options2::withdraw(100) == 70);
        assert!(options2::withdraw(50) == 0);
}

    #[test, expected_failure(abort_code = 3)]
    fun withdraw_zero_aborts() {
        options2::withdraw(100, 0);
}

    #[test, expected_failure(abort_code = 4)]
    fun withdraw_too_much_aborts() {
        options2::withdraw(50, 100);
}
}