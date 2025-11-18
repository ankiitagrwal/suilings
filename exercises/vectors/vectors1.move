// Exercise: Vector Basics
//
// Practice basic vector operations in Move.
//
// Stuck? Check out: https://move-book.com/move-basics/vector.html

module suilings::vectors1 {

/// Creates a vector containing numbers from start to end (inclusive)
public fun create_range(start: u64, end: u64): vector<u64> {
    // TODO: Build vector [start, start+1, ..., end]
    // Use modern syntax: vector[], push_back, or vec.length()
    vector[]
}

/// Sums all elements in the vector
public fun sum_vector(numbers: vector<u64>): u64 {
    // TODO: Iterate and sum using modern syntax
    // Use numbers.length() and numbers[i]
    0
}

/// Returns a new vector with elements in reverse order
public fun reverse_vector(numbers: vector<u64>): vector<u64> {
    // TODO: Create new vector with reversed elements
    vector[]
}

/// Returns only the even numbers from the vector
public fun filter_even(numbers: vector<u64>): vector<u64> {
    // TODO: Filter elements where num % 2 == 0
    vector[]
    }}

#[test_only]
module suilings::vectors1_tests {

    use suilings::vectors1;

    #[test]
    fun create_range_builds_sequence() {
    let range = vectors1::create_range(1, 5);
    assert!(range.length() == 5);
    assert!(range[0] == 1);
    assert!(range[4] == 5);
}

#[test]
    fun sum_vector_calculates_total() {
        let nums = vector[1, 2, 3, 4, 5];
        assert!(vectors1::sum_vector(nums) == 15);

        let nums2 = vector[10, 20, 30];
        assert!(vectors1::sum_vector(nums2) == 60);
}

    #[test]
    fun reverse_vector_flips_order() {
        let nums = vector[1, 2, 3, 4, 5];
        let reversed = vectors1::reverse_vector(nums);
        assert!(reversed[0] == 5);
        assert!(reversed[4] == 1);
        assert!(reversed.length() == 5);
}

    #[test]
    fun filter_even_keeps_even_numbers() {
        let nums = vector[1, 2, 3, 4, 5, 6, 7, 8];
        let evens = vectors1::filter_even(nums);
        assert!(evens.length() == 4);
        assert!(evens[0] == 2);
        assert!(evens[3] == 8);
}
}