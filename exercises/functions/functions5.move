// Exercise: Advanced Functions with Generics
//
// Practice combining generics with structs and complex logic.
//
// Stuck? Check out: https://move-book.com/move-basics/generics.html

module suilings::advanced_functions {

/// A container holding a value and a count
public struct Container<T: drop> has drop {
    value: T,
    count: u64,
}

/// Creates a new container with count = 1
public fun create_container<T: drop>(value: T): Container<T> {
    // TODO: Initialize count to 1
    Container { value, count: 0 }
}

/// Returns the count from a container
public fun count<T: drop>(container: &Container<T>): u64 {
    // TODO: Return container.count
    0
}

/// Increments the container's count
public fun increment_count<T: drop>(container: &mut Container<T>) {
    // TODO: Increment count by 1
}

/// Extracts the value from the container
public fun unwrap<T: drop>(container: Container<T>): T {
    // TODO: Destructure and return value
    let Container { value, .. } = container;
    value
}

/// Placeholder for map operation
public fun map_container<T: drop, U: drop>(
        container: Container<T>,
        _transform: bool
        ): Container<U> {
// Conceptually advanced - would need function parameters
        abort 0
}

/// Returns value unchanged if condition is true
    public fun process_if<T: drop>(
        value: T,
        condition: bool,
        _processor: bool
        ): T {
// TODO: Return value based on condition
        if (condition) {
        value
        } else {
        value
}
}

/// Sums all numbers in a vector
    public fun fold_sum(numbers: vector<u64>): u64 {
// TODO: Use modern vector syntax with fold or loop
        let mut sum = 0;
        let mut i = 0;
        while (i < numbers.length()) {
        sum = sum + numbers[i];
        i = i + 1;
        };
        sum
        }}

#[test_only]
module suilings::advanced_functions_tests {

use suilings::advanced_functions;

#[test]
    fun container_creation_and_unwrap() {
        let container = advanced_functions::create_container<u64>(42);
        assert!(advanced_functions::count(&container) == 1);
        let value = advanced_functions::unwrap(container);
        assert!(value == 42);
}

    #[test]
    fun increment_count_works() {
        let mut container = advanced_functions::create_container<bool>(true);
        advanced_functions::increment_count(&mut container);
        advanced_functions::increment_count(&mut container);
        assert!(advanced_functions::count(&container) == 3);
}

    #[test]
    fun process_if_returns_value() {
        let result = advanced_functions::process_if<u64>(10, true, false);
        assert!(result == 10);
}

    #[test]
    fun fold_sum_calculates_correctly() {
        let nums = vector[1, 2, 3, 4];
        let sum = advanced_functions::fold_sum(nums);
        assert!(sum == 10);
}
}