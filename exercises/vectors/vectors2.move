// Exercise: Advanced Vector Operations
//
// Practice complex vector manipulations and algorithms.
//
// Stuck? Check out: https://move-book.com/move-basics/vector.html

module suilings::vectors2;

/// Removes duplicate elements, keeping first occurrence
public fun remove_duplicates(numbers: vector<u64>): vector<u64> {
    // TODO: Return vector with duplicates removed
    // Example: [1, 2, 2, 3, 1, 4] -> [1, 2, 3, 4]
    vector[]
}

/// Finds the maximum value in the vector
public fun find_max(numbers: vector<u64>): u64 {
    // TODO: Return largest element (assume non-empty)
    0
}

/// Merges two sorted vectors into one sorted vector
public fun merge_sorted(a: vector<u64>, b: vector<u64>): vector<u64> {
    // TODO: Merge maintaining sorted order
    // Example: [1, 3, 5] + [2, 4, 6] -> [1, 2, 3, 4, 5, 6]
    vector[]
}

/// Splits vector into chunks of given size
public fun chunk_vector(numbers: vector<u64>, chunk_size: u64): vector<vector<u64>> {
    // TODO: Create vector of vectors with specified chunk size
    // Example: [1,2,3,4,5,6,7], size 3 -> [[1,2,3], [4,5,6], [7]]
    vector[]
}

#[test_only]
module suilings::vectors2_tests;

use suilings::vectors2;

#[test]
fun remove_duplicates_keeps_first_occurrence() {
    let nums = vector[1, 2, 2, 3, 1, 4, 3];
    let unique = vectors2::remove_duplicates(nums);
    assert!(unique.length() == 4);
    assert!(unique[0] == 1);
    assert!(unique[1] == 2);
    assert!(unique[2] == 3);
    assert!(unique[3] == 4);
}

#[test]
fun find_max_returns_largest() {
    let nums = vector[3, 7, 2, 9, 1, 5];
    assert!(vectors2::find_max(nums) == 9);
    
    let nums2 = vector[42];
    assert!(vectors2::find_max(nums2) == 42);
}

#[test]
fun merge_sorted_combines_in_order() {
    let a = vector[1, 3, 5, 7];
    let b = vector[2, 4, 6, 8];
    let merged = vectors2::merge_sorted(a, b);
    
    assert!(merged.length() == 8);
    let mut i = 0;
    while (i < 8) {
        assert!(merged[i] == i + 1);
        i = i + 1;
    }
}

#[test]
fun chunk_vector_splits_correctly() {
    let nums = vector[1, 2, 3, 4, 5, 6, 7];
    let chunks = vectors2::chunk_vector(nums, 3);
    
    assert!(chunks.length() == 3);
    let chunk1 = &chunks[0];
    assert!(chunk1.length() == 3);
    
    let chunk3 = &chunks[2];
    assert!(chunk3.length() == 1);
    assert!(chunk3[0] == 7);
}