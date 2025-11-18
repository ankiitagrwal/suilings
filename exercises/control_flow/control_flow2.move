// Exercise: Loops in Move
//
// Practice using while loops and loop with break/continue.
//
// Stuck? Check out: https://move-book.com/move-basics/control-flow.html

module suilings::control_flow2 {

/// Sums all numbers from start to end (inclusive)
public fun sum_range(start: u64, end: u64): u64 {
    // TODO: Use a while loop to sum numbers
    // Example: sum_range(1, 5) = 1 + 2 + 3 + 4 + 5 = 15
    0
}

/// Counts how many even numbers are in the vector
public fun count_even(numbers: vector<u64>): u64 {
    // TODO: Iterate through vector and count even numbers
    // Use modern syntax: numbers.length() and numbers[i]
    0
}

/// Calculates n factorial (n!)
public fun factorial(n: u64): u64 {
    // TODO: Calculate n! using a loop with break
    // 0! = 1, 5! = 120
    0
}

/// Finds the first number greater than threshold
public fun find_first_greater(numbers: vector<u64>, threshold: u64): u64 {
    // TODO: Return first number > threshold, or 0 if none found
    // Use loop with break
    0
    }}

#[test_only]
module suilings::control_flow2_tests {

    use suilings::control_flow2;

    #[test]
    fun sum_range_calculates_correctly() {
    assert!(control_flow2::sum_range(1) == 15);
    assert!(control_flow2::sum_range(1) == 55);
    assert!(control_flow2::sum_range(5) == 5);
    assert!(control_flow2::sum_range(0) == 0);
}

#[test]
    fun count_even_finds_correct_count() {
        let nums = vector[1, 2, 3, 4, 5, 6];
        assert!(control_flow2::count_even(nums) == 3);

        let nums2 = vector[1, 3, 5, 7];
        assert!(control_flow2::count_even(nums2) == 0);

        let nums3 = vector[2, 4, 6, 8];
        assert!(control_flow2::count_even(nums3) == 4);
}

    #[test]
    fun factorial_calculates_correctly() {
        assert!(control_flow2::factorial(0) == 1);
        assert!(control_flow2::factorial(1) == 1);
        assert!(control_flow2::factorial(5) == 120);
        assert!(control_flow2::factorial(6) == 720);
}

    #[test]
    fun find_first_greater_works() {
        let nums = vector[1, 3, 5, 7, 9];
        assert!(control_flow2::find_first_greater(nums) == 5);
        assert!(control_flow2::find_first_greater(nums) == 0);
        assert!(control_flow2::find_first_greater(nums) == 1);
}
}