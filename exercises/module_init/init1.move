// Exercise: Module Initializer - Registry System
//
// Build a global registry system that initializes once when the module is published.
// The registry tracks all users and their registration status.
//
// Stuck? Check out: https://move-book.com/programmability/module-initializer.html

module suilings::init1 {

// Error constants
const EAlreadyRegistered: u64 = 1;

use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use std::vector;

/// Global registry that holds all registered users
public struct Registry has key {
    id: UID,
    registered_users: vector<address>,
    total_registrations: u64,
    admin: address,
}

/// Capability given to users upon registration
public struct RegistrationBadge has key, store {
    id: UID,
    user: address,
    registration_number: u64,
}

/// Module Initializer - Bootstrap the Global Registry
/// 
/// When your dApp is deployed, it needs a central registry that exists
/// from the very beginning. The `init` function runs exactly ONCE
/// when the module is first published to the blockchain.
///
/// Bootstrap Requirements:
/// - Create a single global Registry for all users
/// - The publisher becomes the admin (captured from transaction context)
/// - Start with empty registered_users vector and zero registrations
/// - Make the Registry publicly accessible (shared object)
///
/// Note: init functions cannot be called directly - they only run on publish
///
/// fun init(ctx: &mut TxContext) {
///     // Your implementation here
/// }

/// Register a new user in the system
/// 
/// Users can join your platform by registering in the global registry.
/// Each registration is unique - no double registrations allowed.
///
/// Registration Process:
/// - Verify the user isn't already registered (check vector membership)
/// - Add user address to the registry's user list
/// - Increment the total registration counter
/// - Issue a RegistrationBadge NFT as proof of membership
public fun register(registry: &mut Registry, ctx: &mut TxContext) {
    let user = tx_context::sender(ctx);
    
    // Your implementation here
    abort 0
}

/// Check if a user is registered
public fun is_registered(registry: &Registry, user: address): bool {
    // Check if the address exists in registered_users vector
    false
}

/// Get total number of registrations
public fun total_registrations(registry: &Registry): u64 {
    // Return the total_registrations count
    0
}

/// Get registry admin
public fun admin(registry: &Registry): address {
    // Return the admin address
    @0x0
}

/// Get badge details
public fun badge_info(badge: &RegistrationBadge): (address, u64) {
    // Return (user, registration_number)
    (@0x0, 0)
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    // Call the init function for testing
    // init(ctx);
}
}

#[test_only]
module suilings::init1_tests {
use suilings::init1::{Self, Registry, RegistrationBadge};
use sui::test_scenario;

#[test]
fun test_initialization() {
    let admin = @0xAD;
    let mut scenario = test_scenario::begin(admin);
    
    // Simulate module init
    {
        init1::init_for_testing(test_scenario::ctx(&mut scenario));
    };
    
    test_scenario::next_tx(&mut scenario, admin);
    {
        let registry = test_scenario::take_shared<Registry>(&scenario);
        assert!(init1::admin(&registry) == admin, 0);
        assert!(init1::total_registrations(&registry) == 0, 1);
        test_scenario::return_shared(registry);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_user_registration() {
    let admin = @0xAD;
    let user1 = @0xA;
    let mut scenario = test_scenario::begin(admin);
    
    // Init
    {
        init1::init_for_testing(test_scenario::ctx(&mut scenario));
    };
    
    // User registers
    test_scenario::next_tx(&mut scenario, user1);
    {
        let mut registry = test_scenario::take_shared<Registry>(&scenario);
        init1::register(&mut registry, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(registry);
    };
    
    // Check registration
    test_scenario::next_tx(&mut scenario, user1);
    {
        let registry = test_scenario::take_shared<Registry>(&scenario);
        let badge = test_scenario::take_from_sender<RegistrationBadge>(&scenario);
        
        assert!(init1::is_registered(&registry, user1), 0);
        assert!(init1::total_registrations(&registry) == 1, 1);
        
        let (user, number) = init1::badge_info(&badge);
        assert!(user == user1, 2);
        assert!(number == 1, 3);
        
        test_scenario::return_shared(registry);
        test_scenario::return_to_sender(&scenario, badge);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_multiple_registrations() {
    let admin = @0xAD;
    let user1 = @0xA;
    let user2 = @0xB;
    let mut scenario = test_scenario::begin(admin);
    
    // Init
    {
        init1::init_for_testing(test_scenario::ctx(&mut scenario));
    };
    
    // User1 registers
    test_scenario::next_tx(&mut scenario, user1);
    {
        let mut registry = test_scenario::take_shared<Registry>(&scenario);
        init1::register(&mut registry, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(registry);
    };
    
    // User2 registers
    test_scenario::next_tx(&mut scenario, user2);
    {
        let mut registry = test_scenario::take_shared<Registry>(&scenario);
        init1::register(&mut registry, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(registry);
    };
    
    // Verify both registered
    test_scenario::next_tx(&mut scenario, admin);
    {
        let registry = test_scenario::take_shared<Registry>(&scenario);
        assert!(init1::total_registrations(&registry) == 2, 0);
        assert!(init1::is_registered(&registry, user1), 1);
        assert!(init1::is_registered(&registry, user2), 2);
        test_scenario::return_shared(registry);
    };
    
    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = 1)]
fun test_double_registration_fails() {
    let admin = @0xAD;
    let user = @0xA;
    let mut scenario = test_scenario::begin(admin);
    
    // Init
    {
        init1::init_for_testing(test_scenario::ctx(&mut scenario));
    };
    
    // First registration
    test_scenario::next_tx(&mut scenario, user);
    {
        let mut registry = test_scenario::take_shared<Registry>(&scenario);
        init1::register(&mut registry, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(registry);
    };
    
    // Second registration (should fail)
    test_scenario::next_tx(&mut scenario, user);
    {
        let mut registry = test_scenario::take_shared<Registry>(&scenario);
        init1::register(&mut registry, test_scenario::ctx(&mut scenario)); // Should abort
        test_scenario::return_shared(registry);
    };
    
    test_scenario::end(scenario);
}
}
