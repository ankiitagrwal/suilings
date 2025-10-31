// ==== FUNCTIONS EXERCISE ====
// Functions in Move are declared with the `fun` keyword.
// They can have parameters and return values.
//
// Your task:
// Implement the functions below following their specifications.

module suilings::functions {
    public fun multiply(a: u64, b: u64): u64 {
        // TODO: Return the product of a and b
        0
    }
    
    public fun square(num: u64): u64 {
        // TODO: Return the square of num (num * num)
        0
    }
    
    public fun max(a: u64, b: u64): u64 {
        // TODO: Return the larger of the two numbers
        // Hint: Use an if expression: if (condition) value1 else value2
        0
    }
}

#[test_only]
module suilings::functions_tests {
    use suilings::functions;
    
    #[test]
    fun test_multiply() {
        assert!(functions::multiply(5, 6) == 30, 0);
        assert!(functions::multiply(0, 100) == 0, 1);
    }
    
    #[test]
    fun test_square() {
        assert!(functions::square(5) == 25, 0);
        assert!(functions::square(10) == 100, 1);
    }
    
    #[test]
    fun test_max() {
        assert!(functions::max(10, 5) == 10, 0);
        assert!(functions::max(3, 7) == 7, 1);
        assert!(functions::max(5, 5) == 5, 2);
    }
}

