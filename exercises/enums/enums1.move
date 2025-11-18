// Exercise: Enum Basics
//
// Practice creating and using enums to represent states or categories.
//
// Stuck? Check out: https://move-book.com/move-basics/enum-and-match.html

module suilings::enums1 {

// TODO: Define a Status enum with variants: Pending, Active, Completed
/// Represents the status of a task or process
public enum Status {
    Pending,
    Active,
    Completed,
}

// TODO: Define a Color enum with variants: Red, Green, Blue
/// Represents basic colors
public enum Color {
    Red,
    Green,
    Blue,
}

/// Creates a pending status
public fun create_pending_status(): Status {
    // TODO: Return Status::Pending
    Status::Pending
}

/// Creates an active status
public fun create_active_status(): Status {
    // TODO: Return Status::Active
    Status::Active
}

/// Creates a red color
public fun create_red_color(): Color {
    // TODO: Return Color::Red
    Color::Red
}

/// Creates a blue color
public fun create_blue_color(): Color {
    // TODO: Return Color::Blue
    Color::Blue
}
}

#[test_only]
module suilings::enums1_tests {

use suilings::enums1;

#[test]
    fun status_enum_variants_work() {
        let pending = enums1::create_pending_status();
        let active = enums1::create_active_status();
// Same function calls return equal values
        assert!(pending == enums1::create_pending_status());
        assert!(active == enums1::create_active_status());
// Different variants are not equal
        assert!(pending != active);
}

    #[test]
    fun color_enum_variants_work() {
        let red = enums1::create_red_color();
        let blue = enums1::create_blue_color();
// Same function calls return equal values
        assert!(red == enums1::create_red_color());
        assert!(blue == enums1::create_blue_color());
// Different variants are not equal
        assert!(red != blue);
}
}