// Match expressions allow you to pattern match on enum variants.
// Syntax: match (enum_value) { Variant1 => result1, Variant2 => result2 }
//
// Match is exhaustive - you must handle all variants!
//
// Your task:
// Use match expressions to handle enum variants.

module suilings::enums2 {
    public enum Direction {
        North,
        South,
        East,
        West,
    }
    
    public enum Priority {
        Low,
        Medium,
        High,
    }
    
    public fun get_direction_name(direction: Direction): vector<u8> {
        // TODO: Use match to return the name of the direction
        // North => b"North", South => b"South", etc.
        b""
    }
    
    public fun get_priority_value(priority: Priority): u8 {
        // TODO: Use match to return a numeric value
        // Low => 1, Medium => 2, High => 3
        0
    }
    
    public fun is_opposite(dir1: Direction, dir2: Direction): bool {
        // TODO: Use match to check if two directions are opposite
        // North <-> South, East <-> West
        false
    }
}

#[test_only]
module suilings::enums2_tests {
    use suilings::enums2;
    
    #[test]
    fun test_direction_name() {
        assert!(enums2::get_direction_name(enums2::Direction::North) == b"North", 0);
        assert!(enums2::get_direction_name(enums2::Direction::South) == b"South", 1);
        assert!(enums2::get_direction_name(enums2::Direction::East) == b"East", 2);
        assert!(enums2::get_direction_name(enums2::Direction::West) == b"West", 3);
    }
    
    #[test]
    fun test_priority_value() {
        assert!(enums2::get_priority_value(enums2::Priority::Low) == 1, 0);
        assert!(enums2::get_priority_value(enums2::Priority::Medium) == 2, 1);
        assert!(enums2::get_priority_value(enums2::Priority::High) == 3, 2);
    }
    
    #[test]
    fun test_is_opposite() {
        assert!(enums2::is_opposite(enums2::Direction::North, enums2::Direction::South) == true, 0);
        assert!(enums2::is_opposite(enums2::Direction::East, enums2::Direction::West) == true, 1);
        assert!(enums2::is_opposite(enums2::Direction::North, enums2::Direction::East) == false, 2);
    }
}

