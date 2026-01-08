// Exercise: One-Time Witness (OTW) - Registry System
//
// Build a global registry system using OTW to ensure single initialization.
// The registry tracks all registered entities and can only be created once.
//
// Stuck? Check out: https://move-book.com/programmability/one-time-witness.html

module suilings::witness2 {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use std::vector;

// Error constants
const EAlreadyRegistered: u64 = 1;
const ENotRegistered: u64 = 2;
const ENotAdmin: u64 = 3;

/// One-Time Witness for this module
/// Name matches module name (WITNESS2)
public struct WITNESS2 has drop {}

/// Test helper to create witness (only for testing)
#[test_only]
public fun create_witness_for_testing(): WITNESS2 {
    WITNESS2 {}
}

/// Global registry that tracks all registrations
public struct GlobalRegistry has key {
    id: UID,
    /// List of all registered addresses
    registered: vector<address>,
    /// Total number of registrations
    total_count: u64,
    /// Admin address (the one who initialized)
    admin: address,
    /// Whether registry has been initialized
    is_initialized: bool,
}

/// Registration badge issued to each registrant
public struct RegistrationBadge has key, store {
    id: UID,
    registrant: address,
    registration_number: u64,
}

/// Initialize the global registry (can only be called once)
///
/// Your system needs a global registry that can only be initialized once.
/// The OTW pattern ensures this: WITNESS2 can only be created during
/// module initialization, proving this is the first and only initialization.
///
/// Implementation Requirements:
/// - Create GlobalRegistry with new UID
/// - Initialize empty registered vector
/// - Set total_count = 0
/// - Set admin = tx_context::sender(ctx)
/// - Set is_initialized = true
/// - Share the registry using transfer::share_object()
///
/// Note: The witness is automatically provided by Sui during module init
public fun init_registry(
    witness: WITNESS2,
    ctx: &mut TxContext
) {
    // Your implementation here
}

/// Register a new address in the global registry
///
/// Allow addresses to register themselves in the system.
/// Each registration is unique - no double registrations allowed.
///
/// Security Requirements:
/// - Address must not already be registered (abort with EAlreadyRegistered)
/// - Registry must be initialized (check is_initialized)
///
/// Registration Operations:
/// - Verify is_initialized
/// - Check !vector::contains(&registry.registered, &sender)
/// - Add sender to registered vector
/// - Increment total_count
/// - Create RegistrationBadge with new UID, registrant = sender, registration_number = total_count
/// - Transfer badge to sender
public fun register(
    registry: &mut GlobalRegistry,
    ctx: &mut TxContext
) {
    // Your implementation here
}

/// Remove a registration (admin only)
///
/// Admin can remove addresses from the registry.
/// This demonstrates admin-only operations in shared objects.
///
/// Security Requirements:
/// - Only admin can remove (abort with ENotAdmin)
/// - Address must be registered (abort with ENotRegistered)
///
/// Removal Operations:
/// - Verify sender == registry.admin
/// - Verify vector::contains(&registry.registered, &address)
/// - Find index and remove using vector::remove()
/// - Decrement total_count
public fun remove_registration(
    registry: &mut GlobalRegistry,
    address: address,
    ctx: &TxContext
) {
    // Your implementation here
}

/// Check if an address is registered
///
/// Query whether a specific address is in the registry.
/// Useful for access control and UI displays.
///
/// Registry Operations:
/// - Use vector::contains(&registry.registered, &address)
public fun is_registered(registry: &GlobalRegistry, address: address): bool {
    // Your implementation here
    false
}

/// Get total registration count
///
/// Return the total number of registrations.
public fun total_registrations(registry: &GlobalRegistry): u64 {
    registry.total_count
}

/// Get admin address
public fun admin(registry: &GlobalRegistry): address {
    registry.admin
}

/// Get registration number from badge
public fun registration_number(badge: &RegistrationBadge): u64 {
    badge.registration_number
}
}

#[test_only]
module suilings::witness2_tests {
use suilings::witness2::{Self, GlobalRegistry, RegistrationBadge, WITNESS2};
use sui::test_scenario;

const ADMIN: address = @0xAD;
const USER1: address = @0x01;
const USER2: address = @0x02;
const USER3: address = @0x03;

#[test]
fun test_registry_initialization() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
        {
            witness2::init_registry(
                witness2::create_witness_for_testing(),
                test_scenario::ctx(&mut scenario)
            );
        };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let registry = test_scenario::take_shared<GlobalRegistry>(&scenario);
        assert!(witness2::admin(&registry) == ADMIN, 0);
        assert!(witness2::total_registrations(&registry) == 0, 1);
        assert!(!witness2::is_registered(&registry, USER1), 2);
        test_scenario::return_shared(registry);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_registration() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
        {
            witness2::init_registry(
                witness2::create_witness_for_testing(),
                test_scenario::ctx(&mut scenario)
            );
        };

    test_scenario::next_tx(&mut scenario, USER1);
    {
        let mut registry = test_scenario::take_shared<GlobalRegistry>(&scenario);
        witness2::register(&mut registry, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(registry);
    };

    test_scenario::next_tx(&mut scenario, USER1);
    {
        let badge = test_scenario::take_from_sender<RegistrationBadge>(&scenario);
        let registry = test_scenario::take_shared<GlobalRegistry>(&scenario);
        
        assert!(witness2::is_registered(&registry, USER1), 0);
        assert!(witness2::total_registrations(&registry) == 1, 1);
        assert!(witness2::registration_number(&badge) == 1, 2);
        
        test_scenario::return_shared(registry);
        sui::test_utils::destroy(badge);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_multiple_registrations() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
        {
            witness2::init_registry(
                witness2::create_witness_for_testing(),
                test_scenario::ctx(&mut scenario)
            );
        };

    test_scenario::next_tx(&mut scenario, USER1);
    {
        let mut registry = test_scenario::take_shared<GlobalRegistry>(&scenario);
        witness2::register(&mut registry, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(registry);
    };

    test_scenario::next_tx(&mut scenario, USER2);
    {
        let mut registry = test_scenario::take_shared<GlobalRegistry>(&scenario);
        witness2::register(&mut registry, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(registry);
    };

    test_scenario::next_tx(&mut scenario, USER3);
    {
        let mut registry = test_scenario::take_shared<GlobalRegistry>(&scenario);
        witness2::register(&mut registry, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(registry);
    };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let registry = test_scenario::take_shared<GlobalRegistry>(&scenario);
        
        assert!(witness2::is_registered(&registry, USER1), 0);
        assert!(witness2::is_registered(&registry, USER2), 1);
        assert!(witness2::is_registered(&registry, USER3), 2);
        assert!(witness2::total_registrations(&registry) == 3, 3);
        
        test_scenario::return_shared(registry);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_remove_registration() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
        {
            witness2::init_registry(
                witness2::create_witness_for_testing(),
                test_scenario::ctx(&mut scenario)
            );
        };

    test_scenario::next_tx(&mut scenario, USER1);
    {
        let mut registry = test_scenario::take_shared<GlobalRegistry>(&scenario);
        witness2::register(&mut registry, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(registry);
    };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let mut registry = test_scenario::take_shared<GlobalRegistry>(&scenario);
        witness2::remove_registration(
            &mut registry,
            USER1,
            test_scenario::ctx(&mut scenario)
        );
        test_scenario::return_shared(registry);
    };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let registry = test_scenario::take_shared<GlobalRegistry>(&scenario);
        
        assert!(!witness2::is_registered(&registry, USER1), 0);
        assert!(witness2::total_registrations(&registry) == 0, 1);
        
        test_scenario::return_shared(registry);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = witness2::EAlreadyRegistered)]
fun test_double_registration_fails() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
        {
            witness2::init_registry(
                witness2::create_witness_for_testing(),
                test_scenario::ctx(&mut scenario)
            );
        };

    test_scenario::next_tx(&mut scenario, USER1);
    {
        let mut registry = test_scenario::take_shared<GlobalRegistry>(&scenario);
        witness2::register(&mut registry, test_scenario::ctx(&mut scenario));
        // This should fail - already registered
        witness2::register(&mut registry, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(registry);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = witness2::ENotAdmin)]
fun test_non_admin_cannot_remove() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
        {
            witness2::init_registry(
                witness2::create_witness_for_testing(),
                test_scenario::ctx(&mut scenario)
            );
        };

    test_scenario::next_tx(&mut scenario, USER1);
    {
        let mut registry = test_scenario::take_shared<GlobalRegistry>(&scenario);
        witness2::register(&mut registry, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(registry);
    };

    test_scenario::next_tx(&mut scenario, USER2);
    {
        let mut registry = test_scenario::take_shared<GlobalRegistry>(&scenario);
        // This should fail - not admin
        witness2::remove_registration(
            &mut registry,
            USER1,
            test_scenario::ctx(&mut scenario)
        );
        test_scenario::return_shared(registry);
    };

    test_scenario::end(scenario);
}
}

