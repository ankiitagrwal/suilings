// ==== MULTIPLE RETURN VALUES EXERCISE ====
// Functions in Move can return multiple values using tuples.
// Syntax: fun name(): (Type1, Type2) { (value1, value2) }
// To destructure: let (var1, var2) = function_call();
//
// Your task:
// Implement functions that return multiple values

module suilings::multiple_returns {
    public fun divide_with_remainder(dividend: u64, divisor: u64): (u64, u64) {
        // TODO: Return both quotient and remainder
        // Hint: (dividend / divisor, dividend % divisor)
        (0, 0)
    }
    
    public fun min_max(a: u64, b: u64): (u64, u64) {
        // TODO: Return (minimum, maximum) of the two numbers
        // Hint: Use if to determine which is smaller/larger
        (0, 0)
    }
    
    public fun split_name(full_name: vector<u8>): (vector<u8>, vector<u8>) {
        // TODO: For simplicity, return the same name twice
        // In a real implementation, you'd split on space
        // Return (first_name, last_name)
        (b"", b"")
    }
    
    public fun swap(a: u64, b: u64): (u64, u64) {
        // TODO: Return the values in swapped order
        // Return (b, a)
        (0, 0)
    }
    
    public fun calculate_rectangle(width: u64, height: u64): (u64, u64) {
        // TODO: Return (area, perimeter)
        // area = width * height
        // perimeter = 2 * (width + height)
        (0, 0)
    }
}

#[test_only]
module suilings::multiple_returns_tests {
    use suilings::multiple_returns;
    
    #[test]
    fun test_divide_with_remainder() {
        let (quotient, remainder) = multiple_returns::divide_with_remainder(17, 5);
        assert!(quotient == 3, 0);
        assert!(remainder == 2, 1);
    }
    
    #[test]
    fun test_min_max() {
        let (min, max) = multiple_returns::min_max(10, 5);
        assert!(min == 5, 0);
        assert!(max == 10, 1);
        
        let (min2, max2) = multiple_returns::min_max(3, 8);
        assert!(min2 == 3, 2);
        assert!(max2 == 8, 3);
    }
    
    #[test]
    fun test_swap() {
        let (a, b) = multiple_returns::swap(10, 20);
        assert!(a == 20, 0);
        assert!(b == 10, 1);
    }
    
    #[test]
    fun test_calculate_rectangle() {
        let (area, perimeter) = multiple_returns::calculate_rectangle(5, 10);
        assert!(area == 50, 0);
        assert!(perimeter == 30, 1);
    }
}

