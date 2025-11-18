// Exercise: Importing and Using Modules
//
// Practice importing functions from other modules.
//
// Stuck? Check out: https://move-book.com/move-basics/importing-modules.html

module suilings::calculator {

// TODO: Add the `use` line here to import math::add

/// Adds three numbers by calling the imported add function
public fun sum_three(x: u64, y: u64, z: u64): u64 {
    // TODO: Replace with calls to add()
    0
}

#[test]
    fun sum_three_works() {
        assert!(sum_three(1, 2) == 6);
        assert!(sum_three(10, 20) == 60);
}

// Helper module
}
module suilings::math {

/// Simple addition function
public fun add(a: u64, b: u64): u64 {
    a + b
}
}