// Vectors are growable arrays in Move.
//
// Common operations:
// - vector::empty<T>() - create empty vector
// - vector::push_back(&mut v, item) - add to end
// - vector::pop_back(&mut v) - remove from end
// - vector::length(&v) - get size
// - vector::borrow(&v, index) - get reference to element
// - vector::borrow_mut(&mut v, index) - get mutable reference
//
// Your task:
// Implement basic vector operations.

module suilings::vectors1 {
    use std::vector;
    
    public fun create_range(start: u64, end: u64): vector<u64> {
        // TODO: Create a vector containing numbers from start to end (inclusive)
        // Example: create_range(1, 5) = [1, 2, 3, 4, 5]
        vector::empty()
    }
    
    public fun sum_vector(numbers: vector<u64>): u64 {
        // TODO: Sum all elements in the vector
        // Don't modify the vector (use borrow, not pop_back)
        0
    }
    
    public fun reverse_vector(numbers: vector<u64>): vector<u64> {
        // TODO: Return a new vector with elements in reverse order
        // Example: [1, 2, 3] -> [3, 2, 1]
        vector::empty()
    }
    
    public fun filter_even(numbers: vector<u64>): vector<u64> {
        // TODO: Return a new vector containing only even numbers
        // Example: [1, 2, 3, 4, 5] -> [2, 4]
        vector::empty()
    }
}

#[test_only]
module suilings::vectors1_tests {
    use suilings::vectors1;
    use std::vector;
    
    #[test]
    fun test_create_range() {
        let range = vectors1::create_range(1, 5);
        assert!(vector::length(&range) == 5, 0);
        assert!(*vector::borrow(&range, 0) == 1, 1);
        assert!(*vector::borrow(&range, 4) == 5, 2);
    }
    
    #[test]
    fun test_sum_vector() {
        let nums = vector[1, 2, 3, 4, 5];
        assert!(vectors1::sum_vector(nums) == 15, 0);
        
        let nums2 = vector[10, 20, 30];
        assert!(vectors1::sum_vector(nums2) == 60, 1);
    }
    
    #[test]
    fun test_reverse_vector() {
        let nums = vector[1, 2, 3, 4, 5];
        let reversed = vectors1::reverse_vector(nums);
        assert!(*vector::borrow(&reversed, 0) == 5, 0);
        assert!(*vector::borrow(&reversed, 4) == 1, 1);
        assert!(vector::length(&reversed) == 5, 2);
    }
    
    #[test]
    fun test_filter_even() {
        let nums = vector[1, 2, 3, 4, 5, 6, 7, 8];
        let evens = vectors1::filter_even(nums);
        assert!(vector::length(&evens) == 4, 0);
        assert!(*vector::borrow(&evens, 0) == 2, 1);
        assert!(*vector::borrow(&evens, 3) == 8, 2);
    }
}

