// Exercise: Phantom Types and Advanced Generics
//
// Implement type-safe wrappers using phantom types for compile-time safety.
//
// Stuck? Check out: https://move-book.com/move-basics/generics.html

module suilings::generics3 {
use std::vector;
use std::option::{Self, Option};

/// State markers for type-level programming
public struct Locked {}
public struct Unlocked {}

// TODO: Define a Box<T, State> struct with phantom type State
// T should have store + drop abilities
// State is a phantom parameter (not stored in fields)
// Fields: value: T
// Abilities: drop

// TODO: Define a Coin<Currency> struct with phantom type Currency
// Currency is a phantom parameter
// Fields: value: u64
// Abilities: drop

/// Currency type markers
public struct USD {}
public struct EUR {}
public struct SUI {}

// TODO: Define a Container<T> struct for optional values
// T should have drop ability
// Fields: inner: Option<T>
// Abilities: drop

// ===== Box Operations =====

/// Creates a locked box with a value
public fun create_locked_box<T: store + drop>(value: T): Box<T, Locked> {
    // TODO: Create a locked box with the value
    abort 0
}

/// Unlocks a box
public fun unlock_box<T: store + drop>(box: Box<T, Locked>): Box<T, Unlocked> {
    // TODO: Convert a locked box to an unlocked box
    // Hint: Destructure and reconstruct with different phantom type
    abort 0
}

/// Opens an unlocked box and extracts the value
public fun open_box<T: store + drop>(box: Box<T, Unlocked>): T {
    // TODO: Extract value from unlocked box
    // Note: Can only open unlocked boxes!
    abort 0
}

// ===== Coin Operations =====

/// Mints a coin with the specified amount
public fun mint_coin<Currency>(amount: u64): Coin<Currency> {
    // TODO: Create a coin with the specified amount
    abort 0
}

/// Returns the coin's value
public fun coin_value<Currency>(coin: &Coin<Currency>): u64 {
    // TODO: Get the value of a coin
    0
}

/// Merges two coins of the same currency
public fun merge_coins<Currency>(coin1: Coin<Currency>, coin2: Coin<Currency>): Coin<Currency> {
    // TODO: Merge two coins of the same currency
    // Hint: Destructure both, add values, create new coin
    abort 0
}

/// Splits a coin into two coins
public fun split_coin<Currency>(coin: Coin<Currency>, amount: u64): (Coin<Currency>, Coin<Currency>) {
    // TODO: Split a coin into two coins
    // First coin has 'amount', second has remainder
    // Abort if amount > coin.value
    abort 0
}

// ===== Container Operations =====

/// Creates an empty container
public fun create_empty<T: drop>(): Container<T> {
    // TODO: Create an empty container
    abort 0
}

/// Creates a container with a value
public fun create_with_value<T: drop>(value: T): Container<T> {
    // TODO: Create a container with a value
    abort 0
}

/// Checks if the container is empty
public fun is_empty<T: drop>(container: &Container<T>): bool {
    // TODO: Check if container is empty
    false
}

/// Extracts the value from the container
public fun unwrap<T: drop>(container: Container<T>): T {
    // TODO: Extract value from container, abort if empty
    abort 0
    }}

#[test_only]
module suilings::generics3_tests {

    use suilings::generics3;

    #[test]
    fun locked_box_works() {
    let locked = generics3::create_locked_box<u64>(42);
    let unlocked = generics3::unlock_box(locked);
    let value = generics3::open_box(unlocked);
    assert!(value == 42);
}

#[test]
    fun box_with_string_works() {
use std::string;
        let s = string::utf8(b"secret");
        let locked = generics3::create_locked_box(s);
        let unlocked = generics3::unlock_box(locked);
        let value = generics3::open_box(unlocked);
        assert!(value == string::utf8(b"secret"));
}

    #[test]
    fun coin_operations_work() {
        let coin1 = generics3::mint_coin<generics3::USD>(100);
        let coin2 = generics3::mint_coin<generics3::USD>(50);

        assert!(generics3::coin_value(&coin1) == 100);

        let merged = generics3::merge_coins(coin1, coin2);
        assert!(generics3::coin_value(&merged) == 150);

        sui::test_utils::destroy(merged);
}

    #[test]
    fun different_currencies_work() {
        let usd = generics3::mint_coin<generics3::USD>(100);
        let eur = generics3::mint_coin<generics3::EUR>(100);
        let sui = generics3::mint_coin<generics3::SUI>(100);

// These are all different types at compile time!
        assert!(generics3::coin_value(&usd) == 100);
        assert!(generics3::coin_value(&eur) == 100);
        assert!(generics3::coin_value(&sui) == 100);

        sui::test_utils::destroy(usd);
        sui::test_utils::destroy(eur);
        sui::test_utils::destroy(sui);
}

    #[test]
    fun split_coin_works() {
        let coin = generics3::mint_coin<generics3::USD>(100);
        let (coin1, coin2) = generics3::split_coin(coin, 30);

        assert!(generics3::coin_value(&coin1) == 30);
        assert!(generics3::coin_value(&coin2) == 70);

        sui::test_utils::destroy(coin1);
        sui::test_utils::destroy(coin2);
}

    #[test]
    fun container_empty_works() {
        let container = generics3::create_empty<u64>();
        assert!(generics3::is_empty(&container));
        sui::test_utils::destroy(container);
}

    #[test]
    fun container_with_value_works() {
        let container = generics3::create_with_value<u64>(42);
        assert!(!generics3::is_empty(&container));
        let value = generics3::unwrap(container);
        assert!(value == 42);
}

    #[test]
    fun container_with_vector_works() {
    use std::vector;
        let vec = vector[1u64, 2, 3];
        let container = generics3::create_with_value(vec);
        let result = generics3::unwrap(container);
        assert!(result.length() == 3);
}

}