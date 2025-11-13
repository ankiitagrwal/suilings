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
        /// Returns the string name of the direction as bytes
        // TODO: Use a match expression to return the correct name
    }
    
   
    public fun get_priority_value(priority: Priority): u8 {
         /// Returns a numeric value for priority: Low=1, Medium=2, High=3
         /// TODO: Use a match expression to return the correct value
        
    }

    public fun is_opposite(dir1: Direction, dir2: Direction): bool {
        /// Checks if two directions are opposites
        // TODO: Use match expressions to determine if dir1 and dir2 are opposites
    }
    
    #[test]
    fun test_direction_name() {
        assert!(get_direction_name(Direction::North) == b"North", 0);
        assert!(get_direction_name(Direction::South) == b"South", 1);
        assert!(get_direction_name(Direction::East)  == b"East",  2);
        assert!(get_direction_name(Direction::West)  == b"West",  3);
    }

    #[test]
    fun test_priority_value() {
        assert!(get_priority_value(Priority::Low)    == 1, 0);
        assert!(get_priority_value(Priority::Medium) == 2, 1);
        assert!(get_priority_value(Priority::High)   == 3, 2);
    }
    
    #[test]
    fun test_is_opposite() {
        assert!(is_opposite(Direction::North, Direction::South) == true, 0);
        assert!(is_opposite(Direction::East,  Direction::West)  == true, 1);
        assert!(is_opposite(Direction::North, Direction::East)  == false, 2);
        assert!(is_opposite(Direction::West,  Direction::East)  == true, 3);
    }
}

