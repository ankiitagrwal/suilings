// More complex vector manipulations and algorithms.
//
// Additional operations:
// - vector::contains(&v, &item) - check if item exists
// - vector::index_of(&v, &item) - find position
// - vector::remove(&mut v, index) - remove at index
// - vector::swap(&mut v, i, j) - swap elements
//
// Your task:
// Implement advanced vector algorithms.

module suilings::vectors2 {
    use std::vector;
    
    public fun remove_duplicates(numbers: vector<u64>): vector<u64> {
        // TODO: Remove duplicate elements, keeping first occurrence
        // Example: [1, 2, 2, 3, 1, 4] -> [1, 2, 3, 4]
        vector::empty()
    }
    
    public fun find_max(numbers: vector<u64>): u64 {
        // TODO: Find the maximum value in the vector
        // You can assume the vector is not empty
        0
    }
    
    public fun merge_sorted(a: vector<u64>, b: vector<u64>): vector<u64> {
        // TODO: Merge two sorted vectors into one sorted vector
        // Example: [1, 3, 5] + [2, 4, 6] -> [1, 2, 3, 4, 5, 6]
        vector::empty()
    }
    
    public fun chunk_vector(numbers: vector<u64>, chunk_size: u64): vector<vector<u64>> {
        // TODO: Split vector into chunks of given size
        // Example: [1,2,3,4,5,6,7], size 3 -> [[1,2,3], [4,5,6], [7]]
        vector::empty()
    }
}

#[test_only]
module suilings::vectors2_tests {
    use suilings::vectors2;
    use std::vector;
    
    #[test]
    fun test_remove_duplicates() {
        let nums = vector[1, 2, 2, 3, 1, 4, 3];
        let unique = vectors2::remove_duplicates(nums);
        assert!(vector::length(&unique) == 4, 0);
        assert!(*vector::borrow(&unique, 0) == 1, 1);
        assert!(*vector::borrow(&unique, 1) == 2, 2);
        assert!(*vector::borrow(&unique, 2) == 3, 3);
        assert!(*vector::borrow(&unique, 3) == 4, 4);
    }
    
    #[test]
    fun test_find_max() {
        let nums = vector[3, 7, 2, 9, 1, 5];
        assert!(vectors2::find_max(nums) == 9, 0);
        
        let nums2 = vector[42];
        assert!(vectors2::find_max(nums2) == 42, 1);
    }
    
    #[test]
    fun test_merge_sorted() {
        let a = vector[1, 3, 5, 7];
        let b = vector[2, 4, 6, 8];
        let merged = vectors2::merge_sorted(a, b);
        
        assert!(vector::length(&merged) == 8, 0);
        let i = 0;
        while (i < 8) {
            assert!(*vector::borrow(&merged, i) == i + 1, i);
            i = i + 1;
        }
    }
    
    #[test]
    fun test_chunk_vector() {
        let nums = vector[1, 2, 3, 4, 5, 6, 7];
        let chunks = vectors2::chunk_vector(nums, 3);
        
        assert!(vector::length(&chunks) == 3, 0);
        let chunk1 = vector::borrow(&chunks, 0);
        assert!(vector::length(chunk1) == 3, 1);
        
        let chunk3 = vector::borrow(&chunks, 2);
        assert!(vector::length(chunk3) == 1, 2);
        assert!(*vector::borrow(chunk3, 0) == 7, 3);
    }
}

