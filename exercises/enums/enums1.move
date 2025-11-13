// Enums in Move allow you to define a type that can be one of several variants.
// Syntax: public enum EnumName { Variant1, Variant2, Variant3 }
//
// Enums are useful for representing states, options, or categories.
//
// Your task:
// Create and use basic enums.

module suilings::enums1 {
    // TODO: Define a Status enum with variants: Pending, Active, Completed
    // Syntax: public enum Status { Pending, Active, Completed }
    
    public fun create_pending_status(): Status {
        // TODO: Return Status::Pending
    }
    
    public fun create_active_status(): Status {
        // TODO: Return Status::Active
    }
    
    public fun create_red_color(): Color {
        // TODO: Return Color::Red
    }
    
    public fun create_blue_color(): Color {
        // TODO: Return Color::Blue
    }
}

#[test_only]
module suilings::enums1_tests {
    use suilings::enums1;
    
    #[test]
    fun test_status_enum() {
        let pending = enums1::create_pending_status();
        let active = enums1::create_active_status();
        // Enums can be compared directly
        // Same function calls should return equal values
        assert!(pending == enums1::create_pending_status(), 0);
        assert!(active == enums1::create_active_status(), 1);
        // Different functions should return different values
        assert!(pending != active, 2);
    }
    
    #[test]
    fun test_color_enum() {
        let red = enums1::create_red_color();
        let blue = enums1::create_blue_color();
        // Same function calls should return equal values
        assert!(red == enums1::create_red_color(), 0);
        assert!(blue == enums1::create_blue_color(), 1);
        // Different functions should return different values
        assert!(red != blue, 2);
    }
}

