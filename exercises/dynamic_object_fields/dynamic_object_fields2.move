// Exercise: Dynamic Object Fields - Component System
//
// Build a component system where objects can have multiple child objects attached.
// Use dynamic object fields to create flexible object hierarchies.
//
// Stuck? Check out: https://move-book.com/programmability/dynamic-object-fields.html

module suilings::component_system {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::dynamic_object_field as dof;
use std::string::String;
use std::vector;

// Error constants
const EComponentNotFound: u64 = 1;
const EComponentAlreadyExists: u64 = 2;
const ENotOwner: u64 = 3;
const EInvalidComponent: u64 = 4;

/// A main object that can have components attached
public struct MainObject has key, store {
    id: UID,
    name: String,
    owner: address,
    component_count: u64,
}

/// A component that can be attached to main objects
public struct Component has key, store {
    id: UID,
    name: String,
    component_type: u8, // 0: Engine, 1: Weapon, 2: Shield, 3: Sensor
    level: u8,
    owner: address,
}

/// Create a new main object
///
/// Your system needs objects that can have multiple child components.
/// Dynamic object fields allow attaching objects while maintaining their
/// UIDs and independent existence.
///
/// Implementation Requirements:
/// - Create MainObject with new UID
/// - Set name, owner (tx_context::sender()), component_count = 0
/// - Transfer to owner
public fun create_main_object(
    name: String,
    ctx: &mut TxContext
): MainObject {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Create a new component
///
/// Create a component object that can be attached to main objects.
/// Components are independent objects with their own properties.
///
/// Implementation Requirements:
/// - Create Component with new UID
/// - Set name, component_type, level, owner (tx_context::sender())
/// - Transfer to creator
public fun create_component(
    name: String,
    component_type: u8,
    level: u8,
    ctx: &mut TxContext
): Component {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Attach a component to a main object
///
/// Add a component to a main object using dynamic object fields.
/// The component maintains its UID and can be detached later.
///
/// Security Requirements:
/// - Component must not already exist for this key (abort with EComponentAlreadyExists)
/// - Only main object owner can attach (abort with ENotOwner)
/// - Component level must be > 0 (abort with EInvalidComponent)
///
/// Dynamic Object Field Operations:
/// - Check exists: dof::exists_<String, Component>(&main.id, key)
/// - Verify sender is owner
/// - Verify component.level > 0
/// - Add: dof::add(&mut main.id, key, component)
/// - Increment main.component_count
public fun attach_component(
    main: &mut MainObject,
    key: String,
    component: Component,
    ctx: &TxContext,
) {
    // Your implementation here
    transfer::public_transfer(component, tx_context::sender(ctx)); // Temporary - replace with dof::add
}

/// Detach a component from a main object
///
/// Remove a component and return it as an independent object.
/// The component can then be transferred or attached elsewhere.
///
/// Security Requirements:
/// - Component must exist (abort with EComponentNotFound)
/// - Only main object owner can detach (abort with ENotOwner)
///
/// Dynamic Object Field Operations:
/// - Verify exists
/// - Verify sender is owner
/// - Remove: dof::remove<String, Component>(&mut main.id, key)
/// - Decrement main.component_count
/// - Return the Component object
public fun detach_component(
    main: &mut MainObject,
    key: String,
    ctx: &TxContext,
): Component {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Upgrade a component's level
///
/// Increase the level of an attached component.
/// Components can be upgraded while remaining attached.
///
/// Security Requirements:
/// - Component must exist (abort with EComponentNotFound)
/// - Only main object owner can upgrade (abort with ENotOwner)
/// - New level must be <= 10 (abort with EInvalidComponent)
///
/// Dynamic Object Field Operations:
/// - Verify exists
/// - Verify sender is owner
/// - Borrow mutable: dof::borrow_mut<String, Component>(&mut main.id, key)
/// - Update level field (but keep it <= 10)
public fun upgrade_component(
    main: &mut MainObject,
    key: String,
    new_level: u8,
    ctx: &TxContext,
) {
    // Your implementation here
}

/// Get total power of all components
///
/// Calculate the combined power of all attached components.
/// Power = sum of (component.level * 10) for all components.
///
/// Note: This requires iterating through dynamic object fields.
/// For this exercise, you can use a helper that checks common keys,
/// or implement a simpler version that checks specific known keys.
///
/// Dynamic Object Field Operations:
/// - Check exists for each potential key
/// - Borrow each component
/// - Sum up (level * 10) for each
public fun total_component_power(main: &MainObject): u64 {
    // Your implementation here
    // Note: In practice, you'd iterate through all dynamic fields
    // For this exercise, check a few common keys like "engine", "weapon", "shield"
    0
}

/// Get a component by key
///
/// Borrow a component without removing it.
///
/// Security Requirements:
/// - Component must exist (abort with EComponentNotFound)
///
/// Dynamic Object Field Operations:
/// - Verify exists
/// - Borrow: dof::borrow<String, Component>(&main.id, key)
/// - Return immutable reference
public fun get_component(main: &MainObject, key: String): &Component {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Check if a component exists
///
/// Query whether a specific component is attached.
///
/// Dynamic Object Field Operations:
/// - Use dof::exists_<String, Component>(&main.id, key)
public fun has_component(main: &MainObject, key: String): bool {
    // Your implementation here
    false
}

// ==================== Getter Functions ====================

public fun main_name(main: &MainObject): String {
    main.name
}

public fun main_owner(main: &MainObject): address {
    main.owner
}

public fun component_count(main: &MainObject): u64 {
    main.component_count
}

public fun component_name(component: &Component): String {
    component.name
}

public fun component_type(component: &Component): u8 {
    component.component_type
}

public fun component_level(component: &Component): u8 {
    component.level
}
}

#[test_only]
module suilings::component_system_tests {
use suilings::component_system::{Self, MainObject, Component};
use sui::test_scenario;
use std::string;

const OWNER: address = @0x01;
const OTHER: address = @0x02;

#[test]
fun test_create_and_attach() {
    let mut scenario = test_scenario::begin(OWNER);

    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let mut main = component_system::create_main_object(
            string::utf8(b"Spaceship"),
            test_scenario::ctx(&mut scenario)
        );
        let engine = component_system::create_component(
            string::utf8(b"Engine"),
            0,
            3,
            test_scenario::ctx(&mut scenario)
        );
        
        component_system::attach_component(
            &mut main,
            string::utf8(b"engine"),
            engine,
            test_scenario::ctx(&mut scenario)
        );
        
        assert!(component_system::component_count(&main) == 1, 0);
        assert!(component_system::has_component(&main, string::utf8(b"engine")), 1);
        
        transfer::public_transfer(main, OWNER);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_detach_component() {
    let mut scenario = test_scenario::begin(OWNER);

    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let mut main = component_system::create_main_object(
            string::utf8(b"Vehicle"),
            test_scenario::ctx(&mut scenario)
        );
        let weapon = component_system::create_component(
            string::utf8(b"Cannon"),
            1,
            5,
            test_scenario::ctx(&mut scenario)
        );
        
        component_system::attach_component(
            &mut main,
            string::utf8(b"weapon"),
            weapon,
            test_scenario::ctx(&mut scenario)
        );
        
        let detached = component_system::detach_component(
            &mut main,
            string::utf8(b"weapon"),
            test_scenario::ctx(&mut scenario)
        );
        
        assert!(component_system::component_count(&main) == 0, 0);
        assert!(!component_system::has_component(&main, string::utf8(b"weapon")), 1);
        assert!(component_system::component_level(&detached) == 5, 2);
        
        transfer::public_transfer(main, OWNER);
        transfer::public_transfer(detached, OWNER);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_upgrade_component() {
    let mut scenario = test_scenario::begin(OWNER);

    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let mut main = component_system::create_main_object(
            string::utf8(b"Upgradeable Ship"),
            test_scenario::ctx(&mut scenario)
        );
        let shield = component_system::create_component(
            string::utf8(b"Shield"),
            2,
            2,
            test_scenario::ctx(&mut scenario)
        );
        
        component_system::attach_component(
            &mut main,
            string::utf8(b"shield"),
            shield,
            test_scenario::ctx(&mut scenario)
        );
        
        component_system::upgrade_component(
            &mut main,
            string::utf8(b"shield"),
            7,
            test_scenario::ctx(&mut scenario)
        );
        
        let shield_ref = component_system::get_component(&main, string::utf8(b"shield"));
        assert!(component_system::component_level(shield_ref) == 7, 0);
        
        transfer::public_transfer(main, OWNER);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_multiple_components() {
    let mut scenario = test_scenario::begin(OWNER);

    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let mut main = component_system::create_main_object(
            string::utf8(b"Fully Equipped"),
            test_scenario::ctx(&mut scenario)
        );
        
        let engine = component_system::create_component(
            string::utf8(b"Engine"),
            0,
            3,
            test_scenario::ctx(&mut scenario)
        );
        let weapon = component_system::create_component(
            string::utf8(b"Weapon"),
            1,
            4,
            test_scenario::ctx(&mut scenario)
        );
        let shield = component_system::create_component(
            string::utf8(b"Shield"),
            2,
            2,
            test_scenario::ctx(&mut scenario)
        );
        
        component_system::attach_component(
            &mut main,
            string::utf8(b"engine"),
            engine,
            test_scenario::ctx(&mut scenario)
        );
        component_system::attach_component(
            &mut main,
            string::utf8(b"weapon"),
            weapon,
            test_scenario::ctx(&mut scenario)
        );
        component_system::attach_component(
            &mut main,
            string::utf8(b"shield"),
            shield,
            test_scenario::ctx(&mut scenario)
        );
        
        assert!(component_system::component_count(&main) == 3, 0);
        
        transfer::public_transfer(main, OWNER);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = component_system::EComponentAlreadyExists)]
fun test_duplicate_component_fails() {
    let mut scenario = test_scenario::begin(OWNER);

    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let mut main = component_system::create_main_object(
            string::utf8(b"Test Object"),
            test_scenario::ctx(&mut scenario)
        );
        let comp1 = component_system::create_component(
            string::utf8(b"Comp1"),
            0,
            1,
            test_scenario::ctx(&mut scenario)
        );
        let comp2 = component_system::create_component(
            string::utf8(b"Comp2"),
            0,
            1,
            test_scenario::ctx(&mut scenario)
        );
        
        component_system::attach_component(
            &mut main,
            string::utf8(b"same_key"),
            comp1,
            test_scenario::ctx(&mut scenario)
        );
        
        // This should fail - duplicate key
        component_system::attach_component(
            &mut main,
            string::utf8(b"same_key"),
            comp2,
            test_scenario::ctx(&mut scenario)
        );
        
        transfer::public_transfer(main, OWNER);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = component_system::EInvalidComponent)]
fun test_zero_level_component_fails() {
    let mut scenario = test_scenario::begin(OWNER);

    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let mut main = component_system::create_main_object(
            string::utf8(b"Test Object"),
            test_scenario::ctx(&mut scenario)
        );
        let invalid = component_system::create_component(
            string::utf8(b"Invalid"),
            0,
            0, // Level 0 - should fail
            test_scenario::ctx(&mut scenario)
        );
        
        // This should fail - level must be > 0
        component_system::attach_component(
            &mut main,
            string::utf8(b"invalid"),
            invalid,
            test_scenario::ctx(&mut scenario)
        );
        
        transfer::public_transfer(main, OWNER);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = component_system::EInvalidComponent)]
fun test_upgrade_exceeds_max_fails() {
    let mut scenario = test_scenario::begin(OWNER);

    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let mut main = component_system::create_main_object(
            string::utf8(b"Test Object"),
            test_scenario::ctx(&mut scenario)
        );
        let comp = component_system::create_component(
            string::utf8(b"Component"),
            0,
            5,
            test_scenario::ctx(&mut scenario)
        );
        
        component_system::attach_component(
            &mut main,
            string::utf8(b"comp"),
            comp,
            test_scenario::ctx(&mut scenario)
        );
        
        // This should fail - level > 10
        component_system::upgrade_component(
            &mut main,
            string::utf8(b"comp"),
            15,
            test_scenario::ctx(&mut scenario)
        );
        
        transfer::public_transfer(main, OWNER);
    };

    test_scenario::end(scenario);
}
}

