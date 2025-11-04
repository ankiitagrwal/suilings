// Functions can take mutable references (&mut) to modify values in place.
// This is more efficient than copying large values.
//
// Your task:
// Implement functions that use mutable references

module suilings::mutable_refs {
    public fun increment(value: &mut u64) {
        // TODO: Increment the value by 1
        // Hint: *value = *value + 1;
    }
    
    public fun double(value: &mut u64) {
        // TODO: Double the value (multiply by 2)
    }
    
    public fun add_to(target: &mut u64, amount: u64) {
        // TODO: Add amount to target
    }
    
    public fun reset(value: &mut u64) {
        // TODO: Set value to 0
    }
    
    public fun swap_values(a: &mut u64, b: &mut u64) {
        // TODO: Swap the values of a and b
        // Hint: You'll need a temporary variable
        // let temp = *a;
        // *a = *b;
        // *b = temp;
    }
    
    public fun apply_discount(price: &mut u64, discount_percent: u64) {
        // TODO: Reduce price by discount_percent
        // Formula: price = price - (price * discount_percent / 100)
        // Hint: Be careful with integer division
    }
}

#[test_only]
module suilings::mutable_refs_tests {
    use suilings::mutable_refs;
    
    #[test]
    fun test_increment() {
        let mut x = 5;
        mutable_refs::increment(&mut x);
        assert!(x == 6, 0);
    }
    
    #[test]
    fun test_double() {
        let mut x = 10;
        mutable_refs::double(&mut x);
        assert!(x == 20, 0);
    }
    
    #[test]
    fun test_add_to() {
        let mut x = 100;
        mutable_refs::add_to(&mut x, 50);
        assert!(x == 150, 0);
    }
    
    #[test]
    fun test_reset() {
        let mut x = 999;
        mutable_refs::reset(&mut x);
        assert!(x == 0, 0);
    }
    
    #[test]
    fun test_swap() {
        let mut a = 10;
        let mut b = 20;
        mutable_refs::swap_values(&mut a, &mut b);
        assert!(a == 20, 0);
        assert!(b == 10, 1);
    }
    
    #[test]
    fun test_discount() {
        let mut price = 100;
        mutable_refs::apply_discount(&mut price, 20); // 20% off
        assert!(price == 80, 0);
    }
}

