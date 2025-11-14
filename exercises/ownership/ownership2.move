// References allow you to borrow values without taking ownership.
// - &T: immutable reference (read-only)
// - &mut T: mutable reference (can modify)
//
// References don't transfer ownership, so the original value can still be used.
//
// Your task:
// Use references to avoid transferring ownership.

module suilings::ownership2 {
    public struct Counter has drop {
        value: u64,
    }
    
    public fun create_counter(initial: u64): Counter {
        Counter { value: initial }
    }
    
    public fun read_value(counter: &Counter): u64 {
        // TODO: Return the counter's value using a reference
       
    }
    
    public fun increment(counter: &mut Counter) {
        // TODO: Increment the counter's value by 1
        // Use mutable reference to modify
    }
    
    public fun add_to_counter(counter: &mut Counter, amount: u64) {
        // TODO: Add amount to the counter's value
       
    }
    
    public fun get_and_increment(counter: &mut Counter): u64 {
        // TODO: Get the current value, then increment
        // Return the old value
       
    }
}

#[test_only]
module suilings::ownership2_tests {
    use suilings::ownership2;
    
    #[test]
    fun test_read_without_move() {
        let counter = ownership2::create_counter(10);
        let value1 = ownership2::read_value(&counter);
        let value2 = ownership2::read_value(&counter); // Can use again!
        assert!(value1 == 10, 0);
        assert!(value2 == 10, 1);
    }
    
    #[test]
    fun test_increment() {
        let mut counter = ownership2::create_counter(5);
        ownership2::increment(&mut counter);
        assert!(ownership2::read_value(&counter) == 6, 0);
        
        ownership2::add_to_counter(&mut counter, 4);
        assert!(ownership2::read_value(&counter) == 10, 1);
    }
    
    #[test]
    fun test_get_and_increment() {
        let mut counter = ownership2::create_counter(7);
        let old = ownership2::get_and_increment(&mut counter);
        assert!(old == 7, 0);
        assert!(ownership2::read_value(&counter) == 8, 1);
    }
}

