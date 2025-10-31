// ==== ADVANCED FUNCTIONS EXERCISE ====
// This exercise combines multiple concepts: generics, references, and complex logic.
//
// Your task:
// Implement advanced function patterns

module suilings::advanced_functions {
    public struct Container<T: drop> has drop {
        value: T,
        count: u64,
    }
    
    public fun create_container<T: drop>(value: T): Container<T> {
        // TODO: Create a container with count initialized to 1
        Container { value, count: 0 }
    }
    
    public fun get_count<T: drop>(container: &Container<T>): u64 {
        // TODO: Return the count from the container
        0
    }
    
    public fun increment_count<T: drop>(container: &mut Container<T>) {
        // TODO: Increment the container's count by 1
    }
    
    public fun unwrap<T: drop>(container: Container<T>): T {
        // TODO: Extract and return the value, discarding the count
        // Hint: let Container { value, count: _ } = container;
        let Container { value, count: _ } = container;
        value
    }
    
    public fun map_container<T: drop, U: drop>(
        container: Container<T>,
        _transform: bool // Placeholder for transformation logic
    ): Container<U> {
        // This is conceptually advanced - in real code, you'd pass a function
        // For this exercise, we'll abort since we can't actually transform
        abort 0
    }
    
    public fun process_if<T: drop>(
        value: T,
        condition: bool,
        _processor: bool // Placeholder
    ): T {
        // TODO: If condition is true, just return value unchanged
        // (In real code, you'd apply some processing)
        if (condition) {
            value
        } else {
            value
        }
    }
    
    public fun fold_sum(numbers: vector<u64>): u64 {
        // TODO: Sum all numbers in the vector
        // Hint: Use a loop
        // let mut sum = 0;
        // let mut i = 0;
        // while (i < vector::length(&numbers)) {
        //     sum = sum + *vector::borrow(&numbers, i);
        //     i = i + 1;
        // };
        // sum
        use std::vector;
        let mut sum = 0;
        let mut i = 0;
        while (i < vector::length(&numbers)) {
            sum = sum + *vector::borrow(&numbers, i);
            i = i + 1;
        };
        sum
    }
}

#[test_only]
module suilings::advanced_functions_tests {
    use suilings::advanced_functions;
    use std::vector;
    
    #[test]
    fun test_container() {
        let container = advanced_functions::create_container<u64>(42);
        assert!(advanced_functions::get_count(&container) == 1, 0);
        let value = advanced_functions::unwrap(container);
        assert!(value == 42, 1);
    }
    
    #[test]
    fun test_increment_count() {
        let mut container = advanced_functions::create_container<bool>(true);
        advanced_functions::increment_count(&mut container);
        advanced_functions::increment_count(&mut container);
        assert!(advanced_functions::get_count(&container) == 3, 0);
    }
    
    #[test]
    fun test_process_if() {
        let result = advanced_functions::process_if<u64>(10, true, false);
        assert!(result == 10, 0);
    }
    
    #[test]
    fun test_fold_sum() {
        let mut nums = vector::empty<u64>();
        vector::push_back(&mut nums, 1);
        vector::push_back(&mut nums, 2);
        vector::push_back(&mut nums, 3);
        vector::push_back(&mut nums, 4);
        
        let sum = advanced_functions::fold_sum(nums);
        assert!(sum == 10, 0);
    }
}

