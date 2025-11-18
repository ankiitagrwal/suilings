// Exercise: Match Expressions with Enums
//
// Use match expressions to handle enum variants. Match is exhaustive!
//
// Stuck? Check out: https://move-book.com/move-basics/enum-and-match.html

module suilings::enums2 {

/// Direction enum with four variants
public enum Direction {
    North,
    South,
    East,
    West,
}

/// Priority enum with three levels
public enum Priority {
    Low,
    Medium,
    High,
}

/// Returns the string name of the direction
public fun direction_name(direction: Direction): vector<u8> {
    // TODO: Use a match expression to return the correct name
    b""
}

/// Returns a numeric value for priority: Low=1, Medium=2, High=3
public fun priority_value(priority: Priority): u8 {
    // TODO: Use a match expression to return the correct value
    0
}

/// Checks if two directions are opposites
public fun is_opposite(dir1: Direction, dir2: Direction): bool {
    // TODO: Use match expressions to determine if dir1 and dir2 are opposites
    // North-South and East-West are opposites
    false
}

#[test]
    fun direction_name_works() {
        assert!(direction_name(Direction::North) == b"North");
        assert!(direction_name(Direction::South) == b"South");
        assert!(direction_name(Direction::East)  == b"East");
        assert!(direction_name(Direction::West)  == b"West");
}

    #[test]
    fun priority_value_works() {
        assert!(priority_value(Priority::Low)    == 1);
        assert!(priority_value(Priority::Medium) == 2);
        assert!(priority_value(Priority::High)   == 3);
}

    #[test]
    fun is_opposite_works() {
        assert!(is_opposite(Direction::North, Direction::South) == true);
        assert!(is_opposite(Direction::East,  Direction::West)  == true);
        assert!(is_opposite(Direction::North, Direction::East)  == false);
        assert!(is_opposite(Direction::West,  Direction::East)  == true);
}

}