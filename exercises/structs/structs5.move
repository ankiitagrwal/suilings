// Exercise: Generic Structs
//
// Practice creating structs that work with any type using generics.
//
// Stuck? Check out: https://move-book.com/move-basics/generics.html

module suilings::generic_structs {

// TODO: Make this struct generic over type T with 'drop' constraint
/// A box that can hold any droppable value
public struct Box<T: drop> has drop {
    // TODO: Change value field to use generic type T
    value: u64,
}

// TODO: Make this struct generic over K and V types
/// A pair of two values of potentially different types
public struct Pair has drop {
    // TODO: Change to generic types K and V
    first: u64,
    second: u64,
}

/// Creates a new box containing the given value
public fun create_box<T: drop>(value: T): Box<T> {
    // TODO: Create Box with the value
    Box { value: 0 }
}

/// Extracts the value from a box
public fun unbox<T: drop>(box: Box<T>): T {
    // TODO: Destructure and return value
    let Box { value } = box;
    value
}

/// Creates a pair with two values
public fun create_pair<K: copy + drop, V: drop>(first: K, second: V): Pair<K, V> {
    // TODO: Create Pair with both values
    Pair { first: 0, second: 0 }
}

/// Returns the first element (K has copy ability)
public fun first<K: copy + drop, V: drop>(pair: &Pair<K, V>): K {
    // TODO: Return pair.first
    0
}

/// Swaps the first and second elements
public fun swap<K: copy + drop, V: copy + drop>(pair: Pair<K, V>): Pair<V, K> {
    // TODO: Return new Pair with swapped values
    Pair { first: 0, second: 0 }
    }}

#[test_only]
module suilings::generic_structs_tests {

    use suilings::generic_structs;

    #[test]
    fun box_works_with_u64() {
    let box = generic_structs::create_box<u64>(42);
    let value = generic_structs::unbox(box);
    assert!(value == 42);
}

#[test]
    fun box_works_with_bool() {
        let box = generic_structs::create_box<bool>(true);
        let value = generic_structs::unbox(box);
        assert!(value == true);
}

    #[test]
    fun pair_stores_different_types() {
        let pair = generic_structs::create_pair<u64, bool>(10, true);
        let first_val = generic_structs::first(&pair);
        assert!(first_val == 10);
}

    #[test]
    fun swap_exchanges_pair_elements() {
        let pair = generic_structs::create_pair<u8, u64>(5, 100);
        let swapped = generic_structs::swap(pair);
        let first_val = generic_structs::first(&swapped);
        assert!(first_val == 100);
}
}