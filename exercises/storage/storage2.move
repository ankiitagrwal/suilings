// Advanced storage operations: removing children and working with multiple children.
//
// Your task:
// Implement functions to remove children from storage and manage collections.

module suilings::storage2 {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use std::vector;
    
    public struct Container has key {
        id: UID,
        name: vector<u8>,
        items: vector<Item>,
    }
    
    public struct Item has store {
        name: vector<u8>,
        quantity: u64,
    }
    
    public fun create_container(name: vector<u8>, ctx: &mut TxContext): Container {
        Container {
            id: object::new(ctx),
            name,
            items: vector::empty<Item>(),
        }
    }
    
    public fun create_item(name: vector<u8>, quantity: u64): Item {
        Item {
            name,
            quantity,
        }
    }
    
    public fun add_item(container: &mut Container, item: Item) {
        // TODO: Add item to container's items vector
        vector::push_back(&mut container.items, item);
    }
    
    public fun remove_item(container: &mut Container, index: u64): Item {
        // TODO: Remove item from container at given index
        // Hint: vector::remove(&mut container.items, index)
        vector::remove(&mut container.items, index)
    }
    
    public fun get_item_count(container: &Container): u64 {
        // TODO: Return the number of items
        vector::length(&container.items)
    }
    
    public fun get_item_quantity(item: &Item): u64 {
        item.quantity
    }
    
    public fun get_item_name(item: &Item): vector<u8> {
        item.name
    }
}

#[test_only]
module suilings::storage2_tests {
    use suilings::storage2;
    use sui::test_scenario;
    use sui::test_utils;
    
    #[test]
    fun test_add_and_remove() {
        let addr = @0xC;
        let mut scenario = test_scenario::begin(addr);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let mut container = storage2::create_container(b"Box", ctx);
            let item = storage2::create_item(b"Apple", 5);
            
            storage2::add_item(&mut container, item);
            assert!(storage2::get_item_count(&container) == 1, 0);
            
            let removed_item = storage2::remove_item(&mut container, 0);
            assert!(storage2::get_item_count(&container) == 0, 1);
            
            test_utils::destroy(container);
        };
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_multiple_items() {
        let addr = @0xD;
        let mut scenario = test_scenario::begin(addr);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let mut container = storage2::create_container(b"Storage", ctx);
            let item1 = storage2::create_item(b"Item1", 10);
            let item2 = storage2::create_item(b"Item2", 20);
            
            storage2::add_item(&mut container, item1);
            storage2::add_item(&mut container, item2);
            
            assert!(storage2::get_item_count(&container) == 2, 0);
            
            test_utils::destroy(container);
        };
        test_scenario::end(scenario);
    }
}

