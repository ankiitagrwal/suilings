// Exercise: Boolean Operations
//
// Practice working with boolean logic and comparison operators.
//
// Stuck? Check out: https://move-book.com/move-basics/primitive-types.html

module suilings::boolean_ops {

/// Returns true if age is 18 or older
public fun is_adult(age: u8): bool {
    // TODO: Return true if age >= 18
    false
}

/// Returns true if person can vote (18+ and is a citizen)
public fun can_vote(age: u8, is_citizen: bool): bool {
    // TODO: Return true if age >= 18 AND is_citizen is true
    false
}

/// Returns true if age is between 13 and 19 (inclusive)
public fun is_teenager(age: u8): bool {
    // TODO: Check if age is in range [13, 19]
    false
}

}

#[test_only]
module suilings::boolean_ops_tests {

use suilings::boolean_ops;

#[test]
    fun is_adult_returns_correct_result() {
        assert!(boolean_ops::is_adult(18) == true);
        assert!(boolean_ops::is_adult(17) == false);
        assert!(boolean_ops::is_adult(25) == true);
}

    #[test]
    fun can_vote_checks_both_conditions() {
        assert!(boolean_ops::can_vote(18, true) == true);
        assert!(boolean_ops::can_vote(18, false) == false);
        assert!(boolean_ops::can_vote(17, true) == false);
}

    #[test]
    fun is_teenager_checks_age_range() {
        assert!(boolean_ops::is_teenager(13) == true);
        assert!(boolean_ops::is_teenager(19) == true);
        assert!(boolean_ops::is_teenager(12) == false);
        assert!(boolean_ops::is_teenager(20) == false);
}
}