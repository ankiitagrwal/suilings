// Move uses abort and assert for error handling.
//
// - assert!(condition, error_code) - abort if condition is false
// - abort error_code - immediately stop execution
//
// Error codes are u64 values that indicate what went wrong.
// Best practice: Define error constants with descriptive names.
//
// Your task:
// Implement functions with proper error handling.

module suilings::options2 {
    use std::vector;
    
    // Error codes
    const EDIVISION_BY_ZERO: u64 = 0;
    const EOUT_OF_RANGE: u64 = 1;
    const EEMPTY_VECTOR: u64 = 2;
    const EINVALID_AMOUNT: u64 = 3;
    const EINSUFFICIENT_BALANCE: u64 = 4;
    
    public fun safe_divide(a: u64, b: u64): u64 {
        // TODO: Return a / b, but abort with EDIVISION_BY_ZERO if b is 0
        0
    }
    
    public fun get_element(vec: &vector<u64>, index: u64): u64 {
        // TODO: Return the element at index
        // Abort with EOUT_OF_RANGE if index >= length
        0
    }
    
    public fun calculate_average(numbers: vector<u64>): u64 {
        // TODO: Calculate the average of all numbers
        // Abort with EEMPTY_VECTOR if the vector is empty
        0
    }
    
    // Simulated bank account
    public fun withdraw(balance: u64, amount: u64): u64 {
        // TODO: Return new balance after withdrawal
        // Abort with EINVALID_AMOUNT if amount is 0
        // Abort with EINSUFFICIENT_BALANCE if amount > balance
        0
    }
}

#[test_only]
module suilings::options2_tests {
    use suilings::options2;
    use std::vector;
    
    #[test]
    fun test_safe_divide() {
        assert!(options2::safe_divide(10, 2) == 5, 0);
        assert!(options2::safe_divide(100, 4) == 25, 1);
    }
    
    #[test]
    #[expected_failure(abort_code = 0)] // EDIVISION_BY_ZERO
    fun test_divide_by_zero() {
        options2::safe_divide(10, 0);
    }
    
    #[test]
    fun test_get_element() {
        let vec = vector[10, 20, 30, 40];
        assert!(options2::get_element(&vec, 0) == 10, 0);
        assert!(options2::get_element(&vec, 2) == 30, 1);
    }
    
    #[test]
    #[expected_failure(abort_code = 1)] // EOUT_OF_RANGE
    fun test_get_element_out_of_range() {
        let vec = vector[10, 20];
        options2::get_element(&vec, 5);
    }
    
    #[test]
    fun test_calculate_average() {
        let nums = vector[10, 20, 30, 40];
        assert!(options2::calculate_average(nums) == 25, 0);
        
        let nums2 = vector[100, 200];
        assert!(options2::calculate_average(nums2) == 150, 1);
    }
    
    #[test]
    #[expected_failure(abort_code = 2)] // EEMPTY_VECTOR
    fun test_average_empty() {
        let empty = vector::empty();
        options2::calculate_average(empty);
    }
    
    #[test]
    fun test_withdraw() {
        assert!(options2::withdraw(100, 30) == 70, 0);
        assert!(options2::withdraw(50, 50) == 0, 1);
    }
    
    #[test]
    #[expected_failure(abort_code = 3)] // EINVALID_AMOUNT
    fun test_withdraw_zero() {
        options2::withdraw(100, 0);
    }
    
    #[test]
    #[expected_failure(abort_code = 4)] // EINSUFFICIENT_BALANCE
    fun test_withdraw_too_much() {
        options2::withdraw(50, 100);
    }
}

