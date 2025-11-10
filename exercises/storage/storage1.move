// Storage in Sui: Objects with 'store' ability can be stored inside other objects.
// Objects stored in other objects become part of the parent object.
//
// Your task:
// Learn to store objects inside other objects using the 'store' ability.

module suilings::storage1 {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use std::vector;
    
    // Parent object that can store children
    public struct Parent has key {
        id: UID,
        name: vector<u8>,
        children: vector<Child>,
    }
    
    // Child object that can be stored in parent (needs 'store' ability)
    public struct Child has store {
        value: u64,
        name: vector<u8>,
    }
    
    public fun create_parent(name: vector<u8>, ctx: &mut TxContext): Parent {
        Parent {
            id: object::new(ctx),
            name,
            children: vector::empty<Child>(),
        }
    }
    
    public fun create_child(value: u64, name: vector<u8>): Child {
        Child {
            value,
            name,
        }
    }
    
    public fun add_child(parent: &mut Parent, child: Child) {
        // TODO: Add child to parent's children vector
        // Hint: vector::push_back(&mut parent.children, child)
        vector::push_back(&mut parent.children, child);
    }
    
    public fun get_child_count(parent: &Parent): u64 {
        // TODO: Return the number of children
        vector::length(&parent.children)
    }
    
    public fun get_parent_name(parent: &Parent): vector<u8> {
        parent.name
    }
    
    public fun get_child_value(child: &Child): u64 {
        child.value
    }
}

#[test_only]
module suilings::storage1_tests {
    use suilings::storage1;
    use sui::test_scenario;
    use sui::test_utils;
    
    #[test]
    fun test_add_child() {
        let addr = @0xA;
        let mut scenario = test_scenario::begin(addr);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let mut parent = storage1::create_parent(b"Parent1", ctx);
            let child = storage1::create_child(42, b"Child1");
            
            storage1::add_child(&mut parent, child);
            
            assert!(storage1::get_child_count(&parent) == 1, 0);
            test_utils::destroy(parent);
        };
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_multiple_children() {
        let addr = @0xB;
        let mut scenario = test_scenario::begin(addr);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let mut parent = storage1::create_parent(b"Parent2", ctx);
            let child1 = storage1::create_child(10, b"Child1");
            let child2 = storage1::create_child(20, b"Child2");
            
            storage1::add_child(&mut parent, child1);
            storage1::add_child(&mut parent, child2);
            
            assert!(storage1::get_child_count(&parent) == 2, 0);
            test_utils::destroy(parent);
        };
        test_scenario::end(scenario);
    }
}

