// Generics allow you to write structs that work with any type.
// Syntax: struct Name<T> { field: T }
// You can also constrain generics with abilities: <T: copy + drop>
//
// Your task:
// Complete the generic struct definitions and implement the functions

module suilings::generic_structs {
    // TODO: Make this struct generic over type T
    // Add the constraint that T must have 'drop' ability
    public struct Box<T: drop> has drop {
        // TODO: Change value field to use the generic type T
        value: u64,
    }
    
    // TODO: Make this struct generic over two types K and V
    // K must have 'copy + drop', V must have 'drop'
    public struct Pair has drop {
        // TODO: Change these fields to use generic types K and V
        first: u64,
        second: u64,
    }
    
    public fun create_box<T: drop>(value: T): Box<T> {
        // TODO: Create and return a Box containing the value
        Box { value: 0 }
    }
    
    public fun unbox<T: drop>(box: Box<T>): T {
        // TODO: Extract and return the value from the box
        // Hint: Use let Box { value } = box; then return value
        let Box { value } = box;
        value
    }
    
    public fun create_pair<K: copy + drop, V: drop>(first: K, second: V): Pair<K, V> {
        // TODO: Create and return a Pair with the given values
        Pair { first: 0, second: 0 }
    }
    
    public fun get_first<K: copy + drop, V: drop>(pair: &Pair<K, V>): K {
        // TODO: Return the first element of the pair
        // Note: K has 'copy' so we can return a copy
        0
    }
    
    public fun swap<K: copy + drop, V: copy + drop>(pair: Pair<K, V>): Pair<V, K> {
        // TODO: Return a new Pair with first and second swapped
        // Hint: Pair { first: pair.second, second: pair.first }
        Pair { first: 0, second: 0 }
    }
}

#[test_only]
module suilings::generic_structs_tests {
    use suilings::generic_structs;
    
    #[test]
    fun test_box_u64() {
        let box = generic_structs::create_box<u64>(42);
        let value = generic_structs::unbox(box);
        assert!(value == 42, 0);
    }
    
    #[test]
    fun test_box_bool() {
        let box = generic_structs::create_box<bool>(true);
        let value = generic_structs::unbox(box);
        assert!(value == true, 0);
    }
    
    #[test]
    fun test_pair() {
        let pair = generic_structs::create_pair<u64, bool>(10, true);
        let first = generic_structs::get_first(&pair);
        assert!(first == 10, 0);
    }
    
    #[test]
    fun test_swap() {
        let pair = generic_structs::create_pair<u8, u64>(5, 100);
        let swapped = generic_structs::swap(pair);
        let first = generic_structs::get_first(&swapped);
        assert!(first == 100, 0);
    }
}

