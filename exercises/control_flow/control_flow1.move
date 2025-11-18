// Exercise: If/Else Control Flow
//
// Practice using if/else expressions for control flow.
//
// Stuck? Check out: https://move-book.com/move-basics/control-flow.html

module suilings::control_flow {

/// Returns the absolute difference between two numbers
public fun abs_diff(a: u64, b: u64): u64 {
    // TODO: Return |a - b|
    0
}

/// Clamps a value between min and max
public fun clamp(value: u64, min: u64, max: u64): u64 {
    // TODO: If value < min, return min
    //       If value > max, return max
    //       Otherwise return value
    0
}

/// Returns a letter grade based on score
public fun get_grade(score: u8): vector<u8> {
    // TODO: 90-100: "A", 80-89: "B", 70-79: "C", 60-69: "D", <60: "F"
    b"F"
    }}

#[test_only]
module suilings::control_flow_tests {

    use suilings::control_flow;

    #[test]
    fun abs_diff_calculates_correctly() {
    assert!(control_flow::abs_diff(10) == 5);
    assert!(control_flow::abs_diff(5) == 5);
    assert!(control_flow::abs_diff(7) == 0);
}

#[test]
    fun clamp_constrains_values() {
        assert!(control_flow::clamp(15, 10) == 15);
        assert!(control_flow::clamp(5, 10) == 10);
        assert!(control_flow::clamp(25, 10) == 20);
}

    #[test]
    fun get_grade_returns_correct_letter() {
        assert!(control_flow::get_grade(95) == b"A");
        assert!(control_flow::get_grade(85) == b"B");
        assert!(control_flow::get_grade(75) == b"C");
        assert!(control_flow::get_grade(65) == b"D");
        assert!(control_flow::get_grade(55) == b"F");
}
}