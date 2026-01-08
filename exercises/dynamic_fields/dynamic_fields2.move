// Exercise: Dynamic Fields - Attribute System
//
// Build an advanced attribute system using dynamic fields with numeric values.
// Store different types of attributes (stats, counters, flags) on game items.
//
// Stuck? Check out: https://move-book.com/programmability/dynamic-fields.html

module suilings::attribute_system {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::dynamic_field;
use std::string::String;

// Error constants
const EAttributeNotFound: u64 = 1;
const EAttributeAlreadyExists: u64 = 2;
const EInvalidStatValue: u64 = 3;
const EInsufficientStat: u64 = 4;

/// A game item that can have various attributes
public struct GameItem has key, store {
    id: UID,
    name: String,
    item_type: u8, // 0: Weapon, 1: Armor, 2: Consumable
    owner: address,
}

/// Numeric attribute (for stats like attack, defense, health)
/// Note: The name is stored as the dynamic field key, not in the struct
public struct StatAttribute has store, drop {
    value: u64,
    max_value: u64,
}

/// Counter attribute (for tracking usage, durability, etc.)
/// Note: The name is stored as the dynamic field key, not in the struct
public struct CounterAttribute has store, drop {
    count: u64,
}

/// Create a new game item
///
/// Your game needs items with flexible attributes that can be
/// added dynamically. Different item types need different stats.
///
/// Implementation Requirements:
/// - Create GameItem with new UID
/// - Set name, item_type, and owner (tx_context::sender())
/// - Transfer to owner
public fun create_item(
    name: String,
    item_type: u8,
    ctx: &mut TxContext
): GameItem {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Add a stat attribute to an item
///
/// Attach numeric stats like attack power, defense, or health.
/// Stats have a current value and a maximum value.
///
/// Security Requirements:
/// - Stat must not already exist (abort with EAttributeAlreadyExists)
/// - Value must be <= max_value (abort with EInvalidStatValue)
///
/// Dynamic Field Operations:
/// - Check exists: dynamic_field::exists_<String>(&item.id, name)
/// - Create StatAttribute with value, max_value (name is the key, not in struct)
/// - Add: dynamic_field::add(&mut item.id, name, stat)
public fun add_stat(
    item: &mut GameItem,
    name: String,
    value: u64,
    max_value: u64,
) {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Get a stat's current value
///
/// Retrieve the current value of a stat attribute.
///
/// Security Requirements:
/// - Stat must exist (abort with EAttributeNotFound)
///
/// Dynamic Field Operations:
/// - Verify exists
/// - Borrow: dynamic_field::borrow<String, StatAttribute>(&item.id, name)
/// - Return the value field
public fun get_stat_value(item: &GameItem, name: String): u64 {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Increase a stat value
///
/// Upgrade an item's stat (e.g., enhance weapon attack power).
/// Cannot exceed the maximum value.
///
/// Security Requirements:
/// - Stat must exist (abort with EAttributeNotFound)
/// - New value must be <= max_value (abort with EInvalidStatValue)
///
/// Dynamic Field Operations:
/// - Verify exists
/// - Borrow mutable: dynamic_field::borrow_mut<String, StatAttribute>(&mut item.id, name)
/// - Update value field (but keep it <= max_value)
public fun increase_stat(
    item: &mut GameItem,
    name: String,
    amount: u64,
) {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Decrease a stat value
///
/// Reduce a stat (e.g., durability loss, damage taken).
/// Cannot go below 0.
///
/// Security Requirements:
/// - Stat must exist (abort with EAttributeNotFound)
/// - Current value must be >= amount (abort with EInsufficientStat)
///
/// Dynamic Field Operations:
/// - Verify exists
/// - Borrow mutable
/// - Decrease value (but keep it >= 0)
public fun decrease_stat(
    item: &mut GameItem,
    name: String,
    amount: u64,
) {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Add a counter attribute
///
/// Track usage counts, durability, or any incrementing value.
/// Counters start at 0 and can only increase.
///
/// Security Requirements:
/// - Counter must not already exist (abort with EAttributeAlreadyExists)
///
/// Dynamic Field Operations:
/// - Check exists
/// - Create CounterAttribute with count = 0 (name is the key)
/// - Add to dynamic field
public fun add_counter(
    item: &mut GameItem,
    name: String,
) {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Increment a counter
///
/// Increase the counter value by 1 (e.g., usage count, kill count).
///
/// Security Requirements:
/// - Counter must exist (abort with EAttributeNotFound)
///
/// Dynamic Field Operations:
/// - Verify exists
/// - Borrow mutable: dynamic_field::borrow_mut<String, CounterAttribute>(&mut item.id, name)
/// - Increment count field
public fun increment_counter(
    item: &mut GameItem,
    name: String,
) {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Get counter value
///
/// Retrieve the current count value.
///
/// Security Requirements:
/// - Counter must exist (abort with EAttributeNotFound)
///
/// Dynamic Field Operations:
/// - Verify exists
/// - Borrow: dynamic_field::borrow<String, CounterAttribute>(&item.id, name)
/// - Return count field
public fun get_counter_value(item: &GameItem, name: String): u64 {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Remove an attribute (stat or counter)
///
/// Delete an attribute completely from the item.
/// Returns the attribute so it can be inspected or destroyed.
///
/// Security Requirements:
/// - Attribute must exist (abort with EAttributeNotFound)
///
/// Dynamic Field Operations:
/// - Verify exists (try both StatAttribute and CounterAttribute)
/// - Remove: dynamic_field::remove<String, T>(&mut item.id, name)
/// - Note: You may need separate functions for stat vs counter
public fun remove_stat(
    item: &mut GameItem,
    name: String,
): StatAttribute {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

// ==================== Getter Functions ====================

public fun item_name(item: &GameItem): String {
    item.name
}

public fun item_type(item: &GameItem): u8 {
    item.item_type
}

public fun item_owner(item: &GameItem): address {
    item.owner
}

public fun stat_max(stat: &StatAttribute): u64 {
    stat.max_value
}
}

#[test_only]
module suilings::attribute_system_tests {
use suilings::attribute_system;
use sui::test_scenario;
use std::string;
use sui::transfer;

const PLAYER: address = @0x01;

#[test]
fun test_create_item() {
    let mut scenario = test_scenario::begin(PLAYER);

    test_scenario::next_tx(&mut scenario, PLAYER);
    {
        let item = attribute_system::create_item(
            string::utf8(b"Sword"),
            0, // Weapon
            test_scenario::ctx(&mut scenario)
        );
        assert!(attribute_system::item_name(&item) == string::utf8(b"Sword"), 0);
        assert!(attribute_system::item_type(&item) == 0, 1);
        transfer::public_transfer(item, PLAYER);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_add_and_get_stat() {
    let mut scenario = test_scenario::begin(PLAYER);

    test_scenario::next_tx(&mut scenario, PLAYER);
    {
        let mut item = attribute_system::create_item(
            string::utf8(b"Power Sword"),
            0,
            test_scenario::ctx(&mut scenario)
        );
        
        attribute_system::add_stat(
            &mut item,
            string::utf8(b"attack"),
            50,
            100
        );
        
        assert!(attribute_system::get_stat_value(&item, string::utf8(b"attack")) == 50, 0);
        
        transfer::public_transfer(item, PLAYER);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_increase_stat() {
    let mut scenario = test_scenario::begin(PLAYER);

    test_scenario::next_tx(&mut scenario, PLAYER);
    {
        let mut item = attribute_system::create_item(
            string::utf8(b"Upgradeable Sword"),
            0,
            test_scenario::ctx(&mut scenario)
        );
        
        attribute_system::add_stat(&mut item, string::utf8(b"attack"), 30, 100);
        attribute_system::increase_stat(&mut item, string::utf8(b"attack"), 20);
        
        assert!(attribute_system::get_stat_value(&item, string::utf8(b"attack")) == 50, 0);
        
        transfer::public_transfer(item, PLAYER);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_decrease_stat() {
    let mut scenario = test_scenario::begin(PLAYER);

    test_scenario::next_tx(&mut scenario, PLAYER);
    {
        let mut item = attribute_system::create_item(
            string::utf8(b"Durable Armor"),
            1,
            test_scenario::ctx(&mut scenario)
        );
        
        attribute_system::add_stat(&mut item, string::utf8(b"durability"), 100, 100);
        attribute_system::decrease_stat(&mut item, string::utf8(b"durability"), 25);
        
        assert!(attribute_system::get_stat_value(&item, string::utf8(b"durability")) == 75, 0);
        
        transfer::public_transfer(item, PLAYER);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_counter_operations() {
    let mut scenario = test_scenario::begin(PLAYER);

    test_scenario::next_tx(&mut scenario, PLAYER);
    {
        let mut item = attribute_system::create_item(
            string::utf8(b"Used Item"),
            2,
            test_scenario::ctx(&mut scenario)
        );
        
        attribute_system::add_counter(&mut item, string::utf8(b"usage"));
        assert!(attribute_system::get_counter_value(&item, string::utf8(b"usage")) == 0, 0);
        
        attribute_system::increment_counter(&mut item, string::utf8(b"usage"));
        attribute_system::increment_counter(&mut item, string::utf8(b"usage"));
        
        assert!(attribute_system::get_counter_value(&item, string::utf8(b"usage")) == 2, 1);
        
        transfer::public_transfer(item, PLAYER);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = attribute_system::EAttributeAlreadyExists)]
fun test_duplicate_stat_fails() {
    let mut scenario = test_scenario::begin(PLAYER);

    test_scenario::next_tx(&mut scenario, PLAYER);
    {
        let mut item = attribute_system::create_item(
            string::utf8(b"Test Item"),
            0,
            test_scenario::ctx(&mut scenario)
        );
        
        attribute_system::add_stat(&mut item, string::utf8(b"attack"), 10, 100);
        // This should fail - duplicate
        attribute_system::add_stat(&mut item, string::utf8(b"attack"), 20, 100);
        
        transfer::public_transfer(item, PLAYER);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = attribute_system::EInvalidStatValue)]
fun test_stat_exceeds_max_fails() {
    let mut scenario = test_scenario::begin(PLAYER);

    test_scenario::next_tx(&mut scenario, PLAYER);
    {
        let mut item = attribute_system::create_item(
            string::utf8(b"Test Item"),
            0,
            test_scenario::ctx(&mut scenario)
        );
        
        // This should fail - value > max_value
        attribute_system::add_stat(&mut item, string::utf8(b"attack"), 150, 100);
        
        transfer::public_transfer(item, PLAYER);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = attribute_system::EInsufficientStat)]
fun test_decrease_below_zero_fails() {
    let mut scenario = test_scenario::begin(PLAYER);

    test_scenario::next_tx(&mut scenario, PLAYER);
    {
        let mut item = attribute_system::create_item(
            string::utf8(b"Test Item"),
            0,
            test_scenario::ctx(&mut scenario)
        );
        
        attribute_system::add_stat(&mut item, string::utf8(b"durability"), 10, 100);
        // This should fail - trying to decrease by more than current value
        attribute_system::decrease_stat(&mut item, string::utf8(b"durability"), 20);
        
        transfer::public_transfer(item, PLAYER);
    };

    test_scenario::end(scenario);
}
}

