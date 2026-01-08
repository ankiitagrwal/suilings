// Exercise: Dynamic Collections - User Profiles with Metadata
//
// Build a user profile system combining Table for storage with Dynamic Fields for custom metadata.
// This pattern combines structured storage (Table) with flexible custom attributes (Dynamic Fields).
//
// Stuck? Check out: https://move-book.com/programmability/dynamic-collections.html

module suilings::user_profile_system {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::table::{Self, Table};
    use sui::dynamic_field as df;
    use std::string::String;

    // Error codes
    const EProfileAlreadyExists: u64 = 1;
    const EProfileNotFound: u64 = 2;
    const ENotOwner: u64 = 3;
    const EFieldNotFound: u64 = 4;
    const EFieldAlreadyExists: u64 = 5;

    /// User profile with basic information
    public struct UserProfile has key, store {
        id: UID,
        username: String,
        owner: address,
    }

    /// Registry storing all user profiles
    /// Combines Table for main storage with Dynamic Fields for custom attributes
    public struct ProfileRegistry has key {
        id: UID,
        profiles: Table<address, UserProfile>,
        total_profiles: u64,
    }

    /// Create a new profile registry for your social platform
    /// 
    /// You're building a Web3 social platform where users need profiles.
    /// Basic info (username) is stored in a Table for efficient lookup,
    /// while users can add custom fields (portfolio link, twitter handle, etc.)
    /// without you having to update the core UserProfile struct.
    /// 
    /// Implementation Requirements:
    /// - Create new Table with table::new() to store profiles by address
    /// - Initialize total_profiles to 0
    /// - Share the registry with transfer::share_object() (public platform)
    public fun create_registry(ctx: &mut TxContext) {
        // Your implementation here
    }

    /// Register a new user on your social platform
    /// 
    /// When someone signs up, they claim their username and create a profile.
    /// Each wallet address can only have one profile (no duplicate accounts).
    /// 
    /// Implementation Requirements:
    /// - Check table::contains() - abort with EProfileAlreadyExists if already registered
    /// - Create UserProfile with new UID, username, and owner (sender's address)
    /// - Add profile to table using table::add()
    /// - Increment total_profiles counter to track platform growth
    public fun register_user(
        registry: &mut ProfileRegistry,
        username: String,
        ctx: &mut TxContext
    ) {
        // Your implementation here
    }

    /// Add a custom field to your profile (portfolio, social links, etc.)
    /// 
    /// Users want to add their GitHub link, Twitter handle, or portfolio URL
    /// without waiting for the platform to add new fields. Dynamic fields let them
    /// store any key-value data (e.g., "github" -> "myusername") on their profile.
    /// 
    /// Implementation Requirements:
    /// - Get profile from table using table::borrow_mut()
    /// - Abort with EProfileNotFound if profile doesn't exist
    /// - Abort with ENotOwner if sender doesn't own this profile
    /// - Check df::exists_() - abort with EFieldAlreadyExists if field already set
    /// - Add dynamic field: df::add(&mut profile.id, field_name, field_value)
    public fun add_custom_field(
        registry: &mut ProfileRegistry,
        field_name: String,
        field_value: String,
        ctx: &TxContext
    ) {
        // Your implementation here
    }

    /// Get a custom field value from a user's profile
    /// 
    /// Dynamic Field Operations:
    /// - Borrow profile: table::borrow()
    /// - Borrow dynamic field: df::borrow<String, String>(&profile.id, field_name)
    /// 
    /// Implementation Requirements:
    /// - Abort with EProfileNotFound if profile doesn't exist
    /// - Abort with EFieldNotFound if field doesn't exist
    /// - Return the field value
    public fun get_custom_field(
        registry: &ProfileRegistry,
        user: address,
        field_name: String
    ): String {
        // Your implementation here
        field_name // Placeholder
    }

    /// Update a custom field value
    /// 
    /// Dynamic Field Operations:
    /// - Borrow mutable: df::borrow_mut<String, String>(&mut profile.id, field_name)
    /// - Update value: *field_ref = new_value
    /// 
    /// Implementation Requirements:
    /// - Abort with EProfileNotFound if profile doesn't exist
    /// - Abort with ENotOwner if sender is not profile owner
    /// - Abort with EFieldNotFound if field doesn't exist
    /// - Update the field value
    public fun update_custom_field(
        registry: &mut ProfileRegistry,
        field_name: String,
        new_value: String,
        ctx: &TxContext
    ) {
        // Your implementation here
    }

    /// Remove a custom field from a user's profile
    /// 
    /// Dynamic Field Operations:
    /// - Remove field: df::remove<String, String>(&mut profile.id, field_name)
    /// - Returns the removed value
    /// 
    /// Implementation Requirements:
    /// - Abort with EProfileNotFound if profile doesn't exist
    /// - Abort with ENotOwner if sender is not profile owner
    /// - Abort with EFieldNotFound if field doesn't exist
    /// - Remove and return the field value
    public fun remove_custom_field(
        registry: &mut ProfileRegistry,
        field_name: String,
        ctx: &TxContext
    ): String {
        // Your implementation here
        field_name // Placeholder
    }

    /// Check if a custom field exists
    /// 
    /// Dynamic Field Operations:
    /// - Check exists: df::exists_<String>(&profile.id, field_name)
    /// 
    /// Implementation Requirements:
    /// - Return false if profile doesn't exist
    /// - Return df::exists_ result if profile exists
    public fun has_custom_field(
        registry: &ProfileRegistry,
        user: address,
        field_name: String
    ): bool {
        // Your implementation here
        false // Placeholder
    }

    // ==================== Getter Functions ====================
    public fun profile_username(profile: &UserProfile): String { profile.username }
    public fun profile_owner(profile: &UserProfile): address { profile.owner }
    public fun registry_total_profiles(registry: &ProfileRegistry): u64 { registry.total_profiles }
    public fun has_profile(registry: &ProfileRegistry, user: address): bool {
        table::contains(&registry.profiles, user)
    }
}

#[test_only]
module suilings::user_profile_system_tests {
    use suilings::user_profile_system::{Self, ProfileRegistry};
    use sui::test_scenario;
    use std::string;
    use sui::table;

    const USER1: address = @0x01;
    const USER2: address = @0x02;

    #[test]
    fun test_create_registry() {
        let mut scenario = test_scenario::begin(USER1);

        test_scenario::next_tx(&mut scenario, USER1);
        {
            user_profile_system::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let registry = test_scenario::take_shared<ProfileRegistry>(&scenario);
            assert!(user_profile_system::registry_total_profiles(&registry) == 0, 0);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_register_user() {
        let mut scenario = test_scenario::begin(USER1);

        test_scenario::next_tx(&mut scenario, USER1);
        {
            user_profile_system::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<ProfileRegistry>(&scenario);
            user_profile_system::register_user(
                &mut registry,
                string::utf8(b"Alice"),
                test_scenario::ctx(&mut scenario)
            );
            assert!(user_profile_system::registry_total_profiles(&registry) == 1, 0);
            assert!(user_profile_system::has_profile(&registry, USER1), 1);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_add_custom_field() {
        let mut scenario = test_scenario::begin(USER1);

        test_scenario::next_tx(&mut scenario, USER1);
        {
            user_profile_system::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<ProfileRegistry>(&scenario);
            user_profile_system::register_user(
                &mut registry,
                string::utf8(b"Alice"),
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<ProfileRegistry>(&scenario);
            user_profile_system::add_custom_field(
                &mut registry,
                string::utf8(b"bio"),
                string::utf8(b"Move developer"),
                test_scenario::ctx(&mut scenario)
            );
            assert!(
                user_profile_system::has_custom_field(&registry, USER1, string::utf8(b"bio")),
                0
            );
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_get_custom_field() {
        let mut scenario = test_scenario::begin(USER1);

        test_scenario::next_tx(&mut scenario, USER1);
        {
            user_profile_system::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<ProfileRegistry>(&scenario);
            user_profile_system::register_user(
                &mut registry,
                string::utf8(b"Alice"),
                test_scenario::ctx(&mut scenario)
            );
            user_profile_system::add_custom_field(
                &mut registry,
                string::utf8(b"location"),
                string::utf8(b"San Francisco"),
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let registry = test_scenario::take_shared<ProfileRegistry>(&scenario);
            let location = user_profile_system::get_custom_field(
                &registry,
                USER1,
                string::utf8(b"location")
            );
            assert!(location == string::utf8(b"San Francisco"), 0);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_update_custom_field() {
        let mut scenario = test_scenario::begin(USER1);

        test_scenario::next_tx(&mut scenario, USER1);
        {
            user_profile_system::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<ProfileRegistry>(&scenario);
            user_profile_system::register_user(
                &mut registry,
                string::utf8(b"Alice"),
                test_scenario::ctx(&mut scenario)
            );
            user_profile_system::add_custom_field(
                &mut registry,
                string::utf8(b"status"),
                string::utf8(b"Active"),
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<ProfileRegistry>(&scenario);
            user_profile_system::update_custom_field(
                &mut registry,
                string::utf8(b"status"),
                string::utf8(b"Busy"),
                test_scenario::ctx(&mut scenario)
            );
            let status = user_profile_system::get_custom_field(
                &registry,
                USER1,
                string::utf8(b"status")
            );
            assert!(status == string::utf8(b"Busy"), 0);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_remove_custom_field() {
        let mut scenario = test_scenario::begin(USER1);

        test_scenario::next_tx(&mut scenario, USER1);
        {
            user_profile_system::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<ProfileRegistry>(&scenario);
            user_profile_system::register_user(
                &mut registry,
                string::utf8(b"Alice"),
                test_scenario::ctx(&mut scenario)
            );
            user_profile_system::add_custom_field(
                &mut registry,
                string::utf8(b"temp"),
                string::utf8(b"temporary data"),
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<ProfileRegistry>(&scenario);
            let removed = user_profile_system::remove_custom_field(
                &mut registry,
                string::utf8(b"temp"),
                test_scenario::ctx(&mut scenario)
            );
            assert!(removed == string::utf8(b"temporary data"), 0);
            assert!(
                !user_profile_system::has_custom_field(&registry, USER1, string::utf8(b"temp")),
                1
            );
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = user_profile_system::EProfileAlreadyExists)]
    fun test_duplicate_registration_fails() {
        let mut scenario = test_scenario::begin(USER1);

        test_scenario::next_tx(&mut scenario, USER1);
        {
            user_profile_system::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<ProfileRegistry>(&scenario);
            user_profile_system::register_user(
                &mut registry,
                string::utf8(b"Alice"),
                test_scenario::ctx(&mut scenario)
            );
            // This should fail
            user_profile_system::register_user(
                &mut registry,
                string::utf8(b"Alice2"),
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = user_profile_system::EFieldAlreadyExists)]
    fun test_duplicate_field_fails() {
        let mut scenario = test_scenario::begin(USER1);

        test_scenario::next_tx(&mut scenario, USER1);
        {
            user_profile_system::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER1);
        {
            let mut registry = test_scenario::take_shared<ProfileRegistry>(&scenario);
            user_profile_system::register_user(
                &mut registry,
                string::utf8(b"Alice"),
                test_scenario::ctx(&mut scenario)
            );
            user_profile_system::add_custom_field(
                &mut registry,
                string::utf8(b"email"),
                string::utf8(b"alice@example.com"),
                test_scenario::ctx(&mut scenario)
            );
            // This should fail
            user_profile_system::add_custom_field(
                &mut registry,
                string::utf8(b"email"),
                string::utf8(b"alice2@example.com"),
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }
}

