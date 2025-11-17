// Exercise: Advanced Storage Operations
//
// Implement functions to remove children from storage and manage collections.
//
// Stuck? Check out: https://move-book.com/storage/storage-functions.html

module suilings::storage2;
use sui::object::{Self, UID};
use sui::tx_context::TxContext;
use std::vector;
    
/// Container that holds items
public struct Container has key {
    id: UID,
    name: vector<u8>,
    items: vector<Item>,
}
    
/// Item that can be stored
public struct Item has store, drop {
    name: vector<u8>,
    quantity: u64,
}
    
/// Creates a new container
public fun create_container(name: vector<u8>, ctx: &mut TxContext): Container {
    Container {
        id: object::new(ctx),
        name,
        items: vector::empty<Item>(),
    }
}
    
/// Creates a new item
public fun create_item(name: vector<u8>, quantity: u64): Item {
    Item {
        name,
        quantity,
    }
}
    
/// Adds an item to the container
public fun add_item(container: &mut Container, item: Item) {
    // TODO: Add item to container's items vector
}
    
/// Removes an item from the container at the given index
public fun remove_item(container: &mut Container, index: u64): Item {
    // TODO: Remove item from container at given index
    abort 0
}
    
/// Returns the number of items
public fun item_count(container: &Container): u64 {
    // TODO: Return the number of items
    0
}
    
/// Returns the item's quantity
public fun item_quantity(item: &Item): u64 {
    // TODO: Return the quantity of the item
    0
}
    
/// Returns the item's name
public fun item_name(item: &Item): vector<u8> {
    // TODO: Return the name of the item
    b""
}

#[test_only]
module suilings::storage2_tests;

use suilings::storage2;
use sui::test_scenario;
use sui::test_utils;

#[test]
fun add_and_remove_work() {
    let addr = @0xC;
    let mut scenario = test_scenario::begin(addr);
    {
        let ctx = test_scenario::ctx(&mut scenario);
        let mut container = storage2::create_container(b"Box", ctx);
        let item = storage2::create_item(b"Apple", 5);
        
        storage2::add_item(&mut container, item);
        assert!(storage2::item_count(&container) == 1);
        
        let removed_item = storage2::remove_item(&mut container, 0);
        assert!(storage2::item_count(&container) == 0);
        
        test_utils::destroy(container);
    };
    test_scenario::end(scenario);
}

#[test]
fun multiple_items_work() {
    let addr = @0xD;
    let mut scenario = test_scenario::begin(addr);
    {
        let ctx = test_scenario::ctx(&mut scenario);
        let mut container = storage2::create_container(b"Storage", ctx);
        let item1 = storage2::create_item(b"Item1", 10);
        let item2 = storage2::create_item(b"Item2", 20);
        
        storage2::add_item(&mut container, item1);
        storage2::add_item(&mut container, item2);
        
        assert!(storage2::item_count(&container) == 2);
        
        test_utils::destroy(container);
    };
    test_scenario::end(scenario);
}
