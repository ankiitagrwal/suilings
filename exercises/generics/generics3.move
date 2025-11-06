// Advanced generic patterns: Phantom types and type constraints.
//
// Phantom types are type parameters that don't appear in struct fields
// but are used for type-level programming and compile-time safety.
//
// Example use cases:
// - Type-safe state machines
// - Currency types without runtime overhead
// - Capability patterns
//
// Your task:
// Implement type-safe wrappers using phantom types.

module suilings::generics3 {
    use std::vector;
    use std::option::{Self, Option};
    
    // Phantom type markers for state
    public struct Locked {}
    public struct Unlocked {}
    
    // TODO: Define a Box<T, State> struct with phantom type State
    // T should have store + drop abilities
    // State is a phantom parameter (not stored in fields)
    // Fields: value: T
    // Abilities: drop (only for the struct, not required for State)
    public struct Box<T: store + drop, State> has drop {
        value: T,
    }
    
    // TODO: Define a Coin<Currency> struct with phantom type Currency
    // Currency is a phantom parameter
    // Fields: value: u64
    // Abilities: drop
    public struct Coin<Currency> has drop {
        value: u64,
    }
    
    // Currency type markers
    public struct USD {}
    public struct EUR {}
    public struct SUI {}
    
    // TODO: Define a Container<T> struct for optional values
    // T should have drop ability
    // Fields: inner: Option<T>
    // Abilities: drop
    public struct Container<T: drop> has drop {
        inner: Option<T>,
    }
    
    // ===== Box Operations =====
    
    public fun create_locked_box<T: store + drop>(value: T): Box<T, Locked> {
        // TODO: Create a locked box with the value
        abort 0
    }
    
    public fun unlock_box<T: store + drop>(box: Box<T, Locked>): Box<T, Unlocked> {
        // TODO: Convert a locked box to an unlocked box
        // Hint: Destructure and reconstruct with different phantom type
        abort 0
    }
    
    public fun open_box<T: store + drop>(box: Box<T, Unlocked>): T {
        // TODO: Extract value from unlocked box
        // Note: Can only open unlocked boxes!
        abort 0
    }
    
    // ===== Coin Operations =====
    
    public fun mint_coin<Currency>(amount: u64): Coin<Currency> {
        // TODO: Create a coin with the specified amount
        Coin { value: 0 } // Remove this line and implement correctly
    }
    
    public fun coin_value<Currency>(coin: &Coin<Currency>): u64 {
        // TODO: Get the value of a coin
        0
    }
    
    public fun merge_coins<Currency>(coin1: Coin<Currency>, coin2: Coin<Currency>): Coin<Currency> {
        // TODO: Merge two coins of the same currency
        // Hint: Destructure both, add values, create new coin
        abort 0
    }
    
    public fun split_coin<Currency>(coin: Coin<Currency>, amount: u64): (Coin<Currency>, Coin<Currency>) {
        // TODO: Split a coin into two coins
        // First coin has 'amount', second has remainder
        // Abort if amount > coin.value
        abort 0
    }
    
    // ===== Container Operations =====
    
    public fun create_empty<T: drop>(): Container<T> {
        // TODO: Create an empty container
        Container { inner: option::none() } // Remove this line and implement correctly
    }
    
    public fun create_with_value<T: drop>(value: T): Container<T> {
        // TODO: Create a container with a value
        abort 0
    }
    
    public fun is_empty<T: drop>(container: &Container<T>): bool {
        // TODO: Check if container is empty
        false
    }
    
    public fun unwrap<T: drop>(container: Container<T>): T {
        // TODO: Extract value from container, abort if empty
        abort 0
    }
}

#[test_only]
module suilings::generics3_tests {
    use suilings::generics3;
    
    #[test]
    fun test_locked_box() {
        let locked = generics3::create_locked_box<u64>(42);
        let unlocked = generics3::unlock_box(locked);
        let value = generics3::open_box(unlocked);
        assert!(value == 42, 0);
    }
    
    #[test]
    fun test_box_with_string() {
        use std::string;
        let s = string::utf8(b"secret");
        let locked = generics3::create_locked_box(s);
        let unlocked = generics3::unlock_box(locked);
        let value = generics3::open_box(unlocked);
        assert!(value == string::utf8(b"secret"), 0);
    }
    
    #[test]
    fun test_coin_operations() {
        let coin1 = generics3::mint_coin<generics3::USD>(100);
        let coin2 = generics3::mint_coin<generics3::USD>(50);
        
        assert!(generics3::coin_value(&coin1) == 100, 0);
        
        let merged = generics3::merge_coins(coin1, coin2);
        assert!(generics3::coin_value(&merged) == 150, 1);
        
        sui::test_utils::destroy(merged);
    }
    
    #[test]
    fun test_different_currencies() {
        let usd = generics3::mint_coin<generics3::USD>(100);
        let eur = generics3::mint_coin<generics3::EUR>(100);
        let sui = generics3::mint_coin<generics3::SUI>(100);
        
        // These are all different types at compile time!
        assert!(generics3::coin_value(&usd) == 100, 0);
        assert!(generics3::coin_value(&eur) == 100, 1);
        assert!(generics3::coin_value(&sui) == 100, 2);
        
        sui::test_utils::destroy(usd);
        sui::test_utils::destroy(eur);
        sui::test_utils::destroy(sui);
    }
    
    #[test]
    fun test_split_coin() {
        let coin = generics3::mint_coin<generics3::USD>(100);
        let (coin1, coin2) = generics3::split_coin(coin, 30);
        
        assert!(generics3::coin_value(&coin1) == 30, 0);
        assert!(generics3::coin_value(&coin2) == 70, 1);
        
        sui::test_utils::destroy(coin1);
        sui::test_utils::destroy(coin2);
    }
    
    #[test]
    fun test_container_empty() {
        let container = generics3::create_empty<u64>();
        assert!(generics3::is_empty(&container), 0);
        sui::test_utils::destroy(container);
    }
    
    #[test]
    fun test_container_with_value() {
        let container = generics3::create_with_value<u64>(42);
        assert!(!generics3::is_empty(&container), 0);
        let value = generics3::unwrap(container);
        assert!(value == 42, 1);
    }
    
    #[test]
    fun test_container_with_vector() {
        use std::vector;
        let vec = vector[1u64, 2, 3];
        let container = generics3::create_with_value(vec);
        let result = generics3::unwrap(container);
        assert!(vector::length(&result) == 3, 0);
    }
}


