// Ownership in Move is unique - each value has exactly one owner.
// When you pass a value to a function, ownership is transferred (moved).
// You cannot use a value after it's been moved!
//
// Your task:
// Understand basic ownership transfer.

module suilings::ownership1 {
    public struct Box has drop {
        value: u64,
    }
    
    public fun create_box(value: u64): Box {
        // TODO: Create and return a Box
        
    }
    
    public fun get_value(box: Box): u64 {
        // TODO: Extract and return the value from Box
       
    }
    
    public fun transfer_box(box: Box): Box {
        // TODO: Simply return the box (ownership is transferred)
        
    }
    
    public fun update_value(mut box: Box, new_value: u64): Box {
        // TODO: Update the box's value and return it
       
    }
}

#[test_only]
module suilings::ownership1_tests {
    use suilings::ownership1;
    
    #[test]
    fun test_ownership_transfer() {
        let box1 = ownership1::create_box(10);
        let value = ownership1::get_value(box1);
        assert!(value == 10, 0);
        // box1 is now consumed and cannot be used again
    }
    
    #[test]
    fun test_transfer() {
        let box1 = ownership1::create_box(20);
        let box2 = ownership1::transfer_box(box1);
        let value = ownership1::get_value(box2);
        assert!(value == 20, 0);
    }
    
    #[test]
    fun test_update() {
        let box1 = ownership1::create_box(5);
        let box2 = ownership1::update_value(box1, 15);
        let value = ownership1::get_value(box2);
        assert!(value == 15, 0);
    }
}

