// Exercise: One-Time Witness (OTW) - Capability System
//
// Build a capability system using OTW to ensure single admin capability creation.
// The system issues admin capabilities that can only be created once during initialization.
//
// Stuck? Check out: https://move-book.com/programmability/one-time-witness.html

module suilings::witness3 {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use std::vector;

// Error constants
const ENotAdmin: u64 = 1;
const EAlreadyGranted: u64 = 2;
const ENotGranted: u64 = 3;
const ESystemLocked: u64 = 4;

/// One-Time Witness for this module
public struct WITNESS3 has drop {}

/// Test helper to create witness (only for testing)
#[test_only]
public fun create_witness_for_testing(): WITNESS3 {
    WITNESS3 {}
}

/// System that manages capabilities
public struct CapabilitySystem has key {
    id: UID,
    /// Addresses that have been granted capabilities
    granted: vector<address>,
    /// Admin address (from initialization)
    admin: address,
    /// Whether system is locked (no new grants)
    is_locked: bool,
    /// Whether system has been initialized
    is_initialized: bool,
}

/// Admin capability - proves holder has admin rights
public struct AdminCap has key, store {
    id: UID,
    holder: address,
}

/// Initialize the capability system (can only be called once)
///
/// Your system needs a capability manager that can only be initialized once.
/// The OTW pattern ensures this: WITNESS3 can only be created during
/// module initialization, proving this is the first and only initialization.
///
/// Implementation Requirements:
/// - Create CapabilitySystem with new UID
/// - Initialize empty granted vector
/// - Set admin = tx_context::sender(ctx)
/// - Set is_locked = false
/// - Set is_initialized = true
/// - Share the system using transfer::share_object()
///
/// Note: The witness is automatically provided by Sui during module init
public fun init_system(
    witness: WITNESS3,
    ctx: &mut TxContext
) {
    // Your implementation here
}

/// Grant admin capability to an address
///
/// Issue an AdminCap to an address, giving them admin privileges.
/// Only the original admin (from init) can grant capabilities.
///
/// Security Requirements:
/// - Only admin can grant (abort with ENotAdmin)
/// - Address must not already have capability (abort with EAlreadyGranted)
/// - System must not be locked (abort with ESystemLocked)
///
/// Grant Operations:
/// - Verify sender == system.admin
/// - Verify !system.is_locked
/// - Verify !vector::contains(&system.granted, &address)
/// - Add address to granted vector
/// - Create AdminCap with new UID and holder = address
/// - Transfer AdminCap to the address
public fun grant_admin_cap(
    system: &mut CapabilitySystem,
    address: address,
    ctx: &mut TxContext
) {
    // Your implementation here
}

/// Revoke an admin capability
///
/// Remove admin privileges from an address.
/// Only the original admin can revoke capabilities.
///
/// Security Requirements:
/// - Only admin can revoke (abort with ENotAdmin)
/// - Address must have been granted (abort with ENotGranted)
///
/// Revoke Operations:
/// - Verify sender == system.admin
/// - Verify vector::contains(&system.granted, &address)
/// - Find index and remove from granted vector
public fun revoke_admin_cap(
    system: &mut CapabilitySystem,
    address: address,
    ctx: &TxContext
) {
    // Your implementation here
}

/// Lock the system (prevent new grants)
///
/// Permanently lock the system so no new capabilities can be granted.
/// Only the original admin can lock the system.
///
/// Security Requirements:
/// - Only admin can lock (abort with ENotAdmin)
///
/// Lock Operations:
/// - Verify sender == system.admin
/// - Set is_locked = true
public fun lock_system(
    system: &mut CapabilitySystem,
    ctx: &TxContext
) {
    // Your implementation here
}

/// Admin-only operation (requires AdminCap)
///
/// Perform an operation that requires admin privileges.
/// The AdminCap parameter proves the caller has admin rights.
///
/// Security Requirements:
/// - AdminCap holder must match sender (abort with ENotAdmin)
///
/// Admin Operations:
/// - Verify admin_cap.holder == tx_context::sender(ctx)
/// - Perform the operation (e.g., update system state)
public fun admin_operation(
    system: &mut CapabilitySystem,
    admin_cap: &AdminCap,
    ctx: &TxContext
) {
    assert!(admin_cap.holder == tx_context::sender(ctx), ENotAdmin);
    // Example: increment a counter or update state
    // For this exercise, just verify the capability is valid
}

/// Check if an address has admin capability
///
/// Query whether a specific address has been granted admin rights.
public fun has_admin_cap(system: &CapabilitySystem, address: address): bool {
    // Your implementation here
    false
}

/// Check if system is locked
public fun is_locked(system: &CapabilitySystem): bool {
    system.is_locked
}

/// Get admin address
public fun admin(system: &CapabilitySystem): address {
    system.admin
}

/// Get capability holder
public fun cap_holder(cap: &AdminCap): address {
    cap.holder
}
}

#[test_only]
module suilings::witness3_tests {
use suilings::witness3::{Self, CapabilitySystem, AdminCap, WITNESS3};
use sui::test_scenario;

const ADMIN: address = @0xAD;
const USER1: address = @0x01;
const USER2: address = @0x02;

#[test]
fun test_system_initialization() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
        {
            witness3::init_system(
                witness3::create_witness_for_testing(),
                test_scenario::ctx(&mut scenario)
            );
        };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let system = test_scenario::take_shared<CapabilitySystem>(&scenario);
        assert!(witness3::admin(&system) == ADMIN, 0);
        assert!(!witness3::is_locked(&system), 1);
        assert!(!witness3::has_admin_cap(&system, USER1), 2);
        test_scenario::return_shared(system);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_grant_and_use_capability() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
        {
            witness3::init_system(
                witness3::create_witness_for_testing(),
                test_scenario::ctx(&mut scenario)
            );
        };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let mut system = test_scenario::take_shared<CapabilitySystem>(&scenario);
        witness3::grant_admin_cap(
            &mut system,
            USER1,
            test_scenario::ctx(&mut scenario)
        );
        test_scenario::return_shared(system);
    };

    test_scenario::next_tx(&mut scenario, USER1);
    {
        let cap = test_scenario::take_from_sender<AdminCap>(&scenario);
        let mut system = test_scenario::take_shared<CapabilitySystem>(&scenario);
        
        assert!(witness3::has_admin_cap(&system, USER1), 0);
        assert!(witness3::cap_holder(&cap) == USER1, 1);
        
        // Use the capability
        witness3::admin_operation(&mut system, &cap, test_scenario::ctx(&mut scenario));
        
        test_scenario::return_shared(system);
        transfer::public_transfer(cap, USER1);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_revoke_capability() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
        {
            witness3::init_system(
                witness3::create_witness_for_testing(),
                test_scenario::ctx(&mut scenario)
            );
        };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let mut system = test_scenario::take_shared<CapabilitySystem>(&scenario);
        witness3::grant_admin_cap(
            &mut system,
            USER1,
            test_scenario::ctx(&mut scenario)
        );
        test_scenario::return_shared(system);
    };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let mut system = test_scenario::take_shared<CapabilitySystem>(&scenario);
        witness3::revoke_admin_cap(
            &mut system,
            USER1,
            test_scenario::ctx(&mut scenario)
        );
        test_scenario::return_shared(system);
    };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let system = test_scenario::take_shared<CapabilitySystem>(&scenario);
        assert!(!witness3::has_admin_cap(&system, USER1), 0);
        test_scenario::return_shared(system);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_lock_system() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
        {
            witness3::init_system(
                witness3::create_witness_for_testing(),
                test_scenario::ctx(&mut scenario)
            );
        };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let mut system = test_scenario::take_shared<CapabilitySystem>(&scenario);
        witness3::lock_system(&mut system, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(system);
    };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let system = test_scenario::take_shared<CapabilitySystem>(&scenario);
        assert!(witness3::is_locked(&system), 0);
        test_scenario::return_shared(system);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = witness3::EAlreadyGranted)]
fun test_duplicate_grant_fails() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
        {
            witness3::init_system(
                witness3::create_witness_for_testing(),
                test_scenario::ctx(&mut scenario)
            );
        };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let mut system = test_scenario::take_shared<CapabilitySystem>(&scenario);
        witness3::grant_admin_cap(
            &mut system,
            USER1,
            test_scenario::ctx(&mut scenario)
        );
        // This should fail - already granted
        witness3::grant_admin_cap(
            &mut system,
            USER1,
            test_scenario::ctx(&mut scenario)
        );
        test_scenario::return_shared(system);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = witness3::ESystemLocked)]
fun test_grant_after_lock_fails() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
        {
            witness3::init_system(
                witness3::create_witness_for_testing(),
                test_scenario::ctx(&mut scenario)
            );
        };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let mut system = test_scenario::take_shared<CapabilitySystem>(&scenario);
        witness3::lock_system(&mut system, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(system);
    };

    test_scenario::next_tx(&mut scenario, ADMIN);
    {
        let mut system = test_scenario::take_shared<CapabilitySystem>(&scenario);
        // This should fail - system is locked
        witness3::grant_admin_cap(
            &mut system,
            USER1,
            test_scenario::ctx(&mut scenario)
        );
        test_scenario::return_shared(system);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = witness3::ENotAdmin)]
fun test_non_admin_cannot_grant() {
    let mut scenario = test_scenario::begin(ADMIN);

    test_scenario::next_tx(&mut scenario, ADMIN);
        {
            witness3::init_system(
                witness3::create_witness_for_testing(),
                test_scenario::ctx(&mut scenario)
            );
        };

    test_scenario::next_tx(&mut scenario, USER1);
    {
        let mut system = test_scenario::take_shared<CapabilitySystem>(&scenario);
        // This should fail - not admin
        witness3::grant_admin_cap(
            &mut system,
            USER2,
            test_scenario::ctx(&mut scenario)
        );
        test_scenario::return_shared(system);
    };

    test_scenario::end(scenario);
}
}

