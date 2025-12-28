// Exercise: Collections - Table (User Registry)
//
// Build a user registry using Table to store usernames and profiles.
// Table is ideal for key-value storage with copy/drop types.
//
// Stuck? Check out: https://move-book.com/programmability/collections.html

#[allow(duplicate_alias)]
module suilings::user_registry {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::table::{Self, Table};
use std::string::String;

// Error constants
const EUsernameAlreadyExists: u64 = 1;
const EUserNotFound: u64 = 2;
const ENotOwner: u64 = 3;
const EInvalidAge: u64 = 4;

/// A user profile stored in the registry
public struct UserProfile has store, drop {
    /// Display name of the user
    name: String,
    /// User's age
    age: u8,
    /// User's bio
    bio: String,
}

/// A registry that maps usernames to user profiles using Table
public struct UserRegistry has key {
    id: UID,
    /// Table mapping username (String) to UserProfile
    users: Table<String, UserProfile>,
    /// Address of the registry owner (admin)
    owner: address,
}

/// Create a public user registry for your community
///
/// Your platform needs a user directory where anyone can register but
/// only the admin can remove users. Table provides efficient key-value
/// lookup by username.
///
/// Implementation Requirements:
/// - Create an empty Table using table::new()
/// - Store the creator as owner using tx_context::sender()
/// - Create UserRegistry with: id, users (empty table), owner
/// - Share the registry using transfer::share_object() (public access)
public fun create_registry(ctx: &mut TxContext) {
    // Your implementation here
}

/// Register a new user in the directory
///
/// When someone signs up for your platform, add their profile to the registry.
/// Each username must be unique across the system.
///
/// Security Validations:
/// - Username must not already exist (abort with EUsernameAlreadyExists)
/// - Age must be > 0 (abort with EInvalidAge)
///
/// Table Operations:
/// - Check if username exists using table::contains()
/// - Create UserProfile struct with: name, age, bio
/// - Add to table using table::add(&mut registry.users, username, profile)
public fun register_user(
    registry: &mut UserRegistry,
    username: String,
    name: String,
    age: u8,
    bio: String,
) {
    // Your implementation here
}

/// Update a user's profile information
///
/// Allow users to edit their display name, age, or bio after registration.
/// Username cannot be changed (it's the table key).
///
/// Security Requirements:
/// - User must exist (abort with EUserNotFound)
/// - Age must be > 0 (abort with EInvalidAge)
///
/// Table Operations:
/// - Verify username exists using table::contains()
/// - Get mutable reference: table::borrow_mut(&mut registry.users, username)
/// - Update the profile fields directly
public fun update_user(
    registry: &mut UserRegistry,
    username: String,
    name: String,
    age: u8,
    bio: String,
) {
    // Your implementation here
}

/// Remove a user from the registry (admin only)
///
/// Platform admins can ban users or remove inactive accounts.
/// This demonstrates admin-only operations in shared objects.
///
/// Security Requirements:
/// - Only owner can remove users (abort with ENotOwner)
/// - User must exist (abort with EUserNotFound)
///
/// Table Operations:
/// - Verify sender is owner using tx_context::sender()
/// - Verify username exists
/// - Remove from table: table::remove(&mut registry.users, username)
public fun remove_user(
    registry: &mut UserRegistry,
    username: String,
    ctx: &TxContext,
) {
    // Your implementation here
}

/// Get a user's profile (read-only)
///
/// Retrieve a user's profile information without modifying it.
/// Like viewing someone's profile page.
///
/// Security Requirements:
/// - User must exist (abort with EUserNotFound)
///
/// Table Operations:
/// - Verify username exists using table::contains()
/// - Return immutable reference: table::borrow(&registry.users, username)
public fun get_user(registry: &UserRegistry, username: String): &UserProfile {
    assert!(table::contains(&registry.users, username), EUserNotFound);
    table::borrow(&registry.users, username)
}

// ==================== Getter Functions ====================

public fun owner(registry: &UserRegistry): address {
    registry.owner
}

public fun user_count(registry: &UserRegistry): u64 {
    table::length(&registry.users)
}

public fun user_exists(registry: &UserRegistry, username: String): bool {
    table::contains(&registry.users, username)
}

public fun profile_name(profile: &UserProfile): String {
    profile.name
}

public fun profile_age(profile: &UserProfile): u8 {
    profile.age
}

public fun profile_bio(profile: &UserProfile): String {
    profile.bio
}
}

#[test_only]
module suilings::user_registry_tests {
    use suilings::user_registry::{Self, UserRegistry};
    use sui::test_scenario;
    use std::string;

    const ADMIN: address = @0xAD;
    const USER1: address = @0xB0B;

    #[test]
    fun test_create_registry() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            user_registry::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let registry = test_scenario::take_shared<UserRegistry>(&scenario);
            assert!(user_registry::owner(&registry) == ADMIN, 0);
            assert!(user_registry::user_count(&registry) == 0, 1);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_register_user() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            user_registry::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<UserRegistry>(&scenario);
            user_registry::register_user(
                &mut registry,
                string::utf8(b"alice"),
                string::utf8(b"Alice Smith"),
                25,
                string::utf8(b"Software Engineer"),
            );
            assert!(user_registry::user_count(&registry) == 1, 0);
            assert!(user_registry::user_exists(&registry, string::utf8(b"alice")), 1);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_update_user() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            user_registry::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<UserRegistry>(&scenario);
            user_registry::register_user(
                &mut registry,
                string::utf8(b"alice"),
                string::utf8(b"Alice"),
                25,
                string::utf8(b"Engineer"),
            );
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<UserRegistry>(&scenario);
            user_registry::update_user(
                &mut registry,
                string::utf8(b"alice"),
                string::utf8(b"Alice Johnson"),
                26,
                string::utf8(b"Senior Engineer"),
            );
            let profile = user_registry::get_user(&registry, string::utf8(b"alice"));
            assert!(user_registry::profile_age(profile) == 26, 0);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_remove_user() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            user_registry::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<UserRegistry>(&scenario);
            user_registry::register_user(
                &mut registry,
                string::utf8(b"alice"),
                string::utf8(b"Alice"),
                25,
                string::utf8(b"Bio"),
            );
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let mut registry = test_scenario::take_shared<UserRegistry>(&scenario);
            user_registry::remove_user(&mut registry, string::utf8(b"alice"), test_scenario::ctx(&mut scenario));
            assert!(user_registry::user_count(&registry) == 0, 0);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = user_registry::EUsernameAlreadyExists)]
    fun test_duplicate_username_fails() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            user_registry::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<UserRegistry>(&scenario);
            user_registry::register_user(&mut registry, string::utf8(b"alice"), string::utf8(b"Alice"), 25, string::utf8(b"Bio"));
            user_registry::register_user(&mut registry, string::utf8(b"alice"), string::utf8(b"Alice2"), 30, string::utf8(b"Bio2"));
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = user_registry::ENotOwner)]
    fun test_non_owner_remove_fails() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            user_registry::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<UserRegistry>(&scenario);
            user_registry::register_user(&mut registry, string::utf8(b"alice"), string::utf8(b"Alice"), 25, string::utf8(b"Bio"));
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<UserRegistry>(&scenario);
            user_registry::remove_user(&mut registry, string::utf8(b"alice"), test_scenario::ctx(&mut scenario));
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }
}

