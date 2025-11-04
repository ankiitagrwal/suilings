// Booleans in Move are represented by the `bool` type.
// Common operations: && (and), || (or), ! (not), == (equal), != (not equal)
//
// Your task:
// Implement the boolean logic functions below.

module suilings::boolean_ops {
    public fun is_adult(age: u8): bool {
        // TODO: Return true if age is 18 or older
        false
    }
    
    public fun can_vote(age: u8, is_citizen: bool): bool {
        // TODO: Return true if age >= 18 AND is_citizen is true
        false
    }
    
    public fun is_teenager(age: u8): bool {
        // TODO: Return true if age is between 13 and 19 (inclusive)
        false
    }
}

#[test_only]
module suilings::boolean_ops_tests {
    use suilings::boolean_ops;
    
    #[test]
    fun test_is_adult() {
        assert!(boolean_ops::is_adult(18) == true, 0);
        assert!(boolean_ops::is_adult(17) == false, 1);
        assert!(boolean_ops::is_adult(25) == true, 2);
    }
    
    #[test]
    fun test_can_vote() {
        assert!(boolean_ops::can_vote(18, true) == true, 0);
        assert!(boolean_ops::can_vote(18, false) == false, 1);
        assert!(boolean_ops::can_vote(17, true) == false, 2);
    }
    
    #[test]
    fun test_is_teenager() {
        assert!(boolean_ops::is_teenager(13) == true, 0);
        assert!(boolean_ops::is_teenager(19) == true, 1);
        assert!(boolean_ops::is_teenager(12) == false, 2);
        assert!(boolean_ops::is_teenager(20) == false, 3);
    }
}

