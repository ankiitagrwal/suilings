// Move supports while loops and loop with break/continue.
//
// while (condition) { ... }
// loop { ... break; ... }
// continue - skip to next iteration
// break - exit the loop
//
// Your task:
// Implement functions using loops.

module suilings::control_flow2 {
    public fun sum_range(start: u64, end: u64): u64 {
        // TODO: Sum all numbers from start to end (inclusive)
        // Use a while loop
        // Example: sum_range(1, 5) = 1 + 2 + 3 + 4 + 5 = 15
        0
    }
    
    public fun count_even(numbers: vector<u64>): u64 {
        // TODO: Count how many even numbers are in the vector
        // Use a while loop to iterate through the vector
        // Hint: Use std::vector::length() and std::vector::borrow()
        0
    }
    
    public fun factorial(n: u64): u64 {
        // TODO: Calculate n! (n factorial)
        // 0! = 1, 5! = 5 * 4 * 3 * 2 * 1 = 120
        // Use a loop with break
        0
    }
    
    public fun find_first_greater(numbers: vector<u64>, threshold: u64): u64 {
        // TODO: Find the first number greater than threshold
        // Return 0 if not found
        // Use loop with break
        0
    }
}

#[test_only]
module suilings::control_flow2_tests {
    use suilings::control_flow2;
    use std::vector;
    
    #[test]
    fun test_sum_range() {
        assert!(control_flow2::sum_range(1, 5) == 15, 0);
        assert!(control_flow2::sum_range(1, 10) == 55, 1);
        assert!(control_flow2::sum_range(5, 5) == 5, 2);
        assert!(control_flow2::sum_range(0, 0) == 0, 3);
    }
    
    #[test]
    fun test_count_even() {
        let nums = vector[1, 2, 3, 4, 5, 6];
        assert!(control_flow2::count_even(nums) == 3, 0);
        
        let nums2 = vector[1, 3, 5, 7];
        assert!(control_flow2::count_even(nums2) == 0, 1);
        
        let nums3 = vector[2, 4, 6, 8];
        assert!(control_flow2::count_even(nums3) == 4, 2);
    }
    
    #[test]
    fun test_factorial() {
        assert!(control_flow2::factorial(0) == 1, 0);
        assert!(control_flow2::factorial(1) == 1, 1);
        assert!(control_flow2::factorial(5) == 120, 2);
        assert!(control_flow2::factorial(6) == 720, 3);
    }
    
    #[test]
    fun test_find_first_greater() {
        let nums = vector[1, 3, 5, 7, 9];
        assert!(control_flow2::find_first_greater(nums, 4) == 5, 0);
        assert!(control_flow2::find_first_greater(nums, 10) == 0, 1);
        assert!(control_flow2::find_first_greater(nums, 0) == 1, 2);
    }
}

