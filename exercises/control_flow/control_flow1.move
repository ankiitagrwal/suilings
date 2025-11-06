// Control flow in Move uses if/else expressions.
// Unlike statements, expressions return values!
//
// Your task:
// Implement functions using if/else control flow.

module suilings::control_flow {
    public fun abs_diff(a: u64, b: u64): u64 {
        // TODO: Return the absolute difference between a and b
        0
    }
    
    public fun clamp(value: u64, min: u64, max: u64): u64 {
        // TODO: Return value clamped between min and max
        // If value < min, return min
        // If value > max, return max
        // Otherwise return value
        0
    }
    
    public fun get_grade(score: u8): vector<u8> {
        // TODO: Return grade based on score
        // 90-100: "A", 80-89: "B", 70-79: "C", 60-69: "D", below 60: "F"
        b"F"
    }
}

#[test_only]
module suilings::control_flow_tests {
    use suilings::control_flow;
    
    #[test]
    fun test_abs_diff() {
        assert!(control_flow::abs_diff(10, 5) == 5, 0);
        assert!(control_flow::abs_diff(5, 10) == 5, 1);
        assert!(control_flow::abs_diff(7, 7) == 0, 2);
    }
    
    #[test]
    fun test_clamp() {
        assert!(control_flow::clamp(15, 10, 20) == 15, 0);
        assert!(control_flow::clamp(5, 10, 20) == 10, 1);
        assert!(control_flow::clamp(25, 10, 20) == 20, 2);
    }
    
    #[test]
    fun test_get_grade() {
        assert!(control_flow::get_grade(95) == b"A", 0);
        assert!(control_flow::get_grade(85) == b"B", 1);
        assert!(control_flow::get_grade(75) == b"C", 2);
        assert!(control_flow::get_grade(65) == b"D", 3);
        assert!(control_flow::get_grade(55) == b"F", 4);
    }
}

