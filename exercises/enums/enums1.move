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
        abort 0
    }
    
    public fun create_active_status(): Status {
        // TODO: Return Status::Active
        abort 0
    }
    
    public fun create_red_color(): Color {
        // TODO: Return Color::Red
        abort 0
    }
    
    public fun create_blue_color(): Color {
        // TODO: Return Color::Blue
        abort 0
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
        assert!(pending == enums1::Status::Pending, 0);
        assert!(active == enums1::Status::Active, 1);
    }
    
    #[test]
    fun test_color_enum() {
        let red = enums1::create_red_color();
        let blue = enums1::create_blue_color();
        assert!(red == enums1::Color::Red, 0);
        assert!(blue == enums1::Color::Blue, 1);
    }
}

