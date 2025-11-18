// Exercise: Ownership Basics
//
// Understand basic ownership transfer in Move. Each value has exactly one owner.
//
// Stuck? Check out: https://move-book.com/move-basics/ownership-and-scope.html

module suilings::ownership1 {
/// A simple box with a value
public struct Box has drop {
    value: u64,
}

/// Creates a new box
public fun create_box(value: u64): Box {
    // TODO: Create and return a Box
    abort 0
}

/// Extracts the value from a box
public fun value(box: Box): u64 {
    // TODO: Extract and return the value from Box
    0
}

/// Transfers ownership of the box
public fun transfer_box(box: Box): Box {
    // TODO: Simply return the box (ownership is transferred)
    abort 0
}

/// Updates the box's value
public fun update_value(mut box: Box, new_value: u64): Box {
    // TODO: Update the box's value and return it
    abort 0
    }}

#[test_only]
module suilings::ownership1_tests {

    use suilings::ownership1;

    #[test]
    fun ownership_transfer_works() {
    let box1 = ownership1::create_box(10);
    let value = ownership1::value(box1);
    assert!(value == 10);
    // box1 is now consumed and cannot be used again
}

#[test]
    fun transfer_works() {
        let box1 = ownership1::create_box(20);
        let box2 = ownership1::transfer_box(box1);
        let value = ownership1::value(box2);
        assert!(value == 20);
}

    #[test]
    fun update_works() {
        let box1 = ownership1::create_box(5);
        let box2 = ownership1::update_value(box1, 15);
        let value = ownership1::value(box2);
        assert!(value == 15);
}

}