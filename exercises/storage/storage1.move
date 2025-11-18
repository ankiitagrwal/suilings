// Exercise: Storage Basics
//
// Learn to store objects inside other objects using the 'store' ability.
//
// Stuck? Check out: https://move-book.com/storage/storage-functions.html

module suilings::storage1 {
use sui::object::{Self, UID};
use sui::tx_context::TxContext;
use std::vector;

/// Parent object that can store children
public struct Parent has key {
    id: UID,
    name: vector<u8>,
    children: vector<Child>,
}

/// Child object that can be stored in parent (needs 'store' ability)
public struct Child has store {
    value: u64,
    name: vector<u8>,
}

/// Creates a new parent
public fun create_parent(name: vector<u8>, ctx: &mut TxContext): Parent {
    Parent {
    id: object::new(ctx),
    name,
    children: vector::empty<Child>(),
}
}

/// Creates a new child
    public fun create_child(value: u64, name: vector<u8>): Child {
        Child {
        value,
        name,
}
}

/// Adds a child to the parent
    public fun add_child(parent: &mut Parent, child: Child) {
// TODO: Add child to parent's children vector
        abort 0
}

/// Returns the number of children
    public fun child_count(parent: &Parent): u64 {
// TODO: Return the number of children
        0
}

/// Returns the parent's name
    public fun parent_name(parent: &Parent): vector<u8> {
// TODO: Return the name of the parent
        b""
}

/// Returns the child's value
    public fun child_value(child: &Child): u64 {
// TODO: Return the value of the child
        0
        }}

#[test_only]
module suilings::storage1_tests {

use suilings::storage1;
use sui::test_scenario;
use sui::test_utils;

#[test]
    fun add_child_works() {
        let addr = @0xA;
        let mut scenario = test_scenario::begin(addr);
        {
        let ctx = test_scenario::ctx(&mut scenario);
        let mut parent = storage1::create_parent(b"Parent1", ctx);
        let child = storage1::create_child(42, b"Child1");

        storage1::add_child(&mut parent, child);

        assert!(storage1::child_count(&parent) == 1);
        test_utils::destroy(parent);
        };
        test_scenario::end(scenario);
}

    #[test]
    fun multiple_children_work() {
        let addr = @0xB;
        let mut scenario = test_scenario::begin(addr);
        {
        let ctx = test_scenario::ctx(&mut scenario);
        let mut parent = storage1::create_parent(b"Parent2", ctx);
        let child1 = storage1::create_child(10, b"Child1");
        let child2 = storage1::create_child(20, b"Child2");

        storage1::add_child(&mut parent, child1);
        storage1::add_child(&mut parent, child2);

        assert!(storage1::child_count(&parent) == 2);
        test_utils::destroy(parent);
        };
        test_scenario::end(scenario);
}

}