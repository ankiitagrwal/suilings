// Exercise: Generic Witness - Type-Safe Container Factory
//
// Build a container factory using generic witness pattern for type-safe initialization.
// Generic witness ensures containers can only be created with valid witness types.
//
// Stuck? Check out: https://move-book.com/programmability/witness-pattern.html


module suilings::type_registry {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::vec_map::{Self, VecMap};
    use std::type_name::{Self, TypeName};

    // Error codes
    const ETypeAlreadyRegistered: u64 = 1;
    const ETypeNotRegistered: u64 = 2;
    const ENotAuthorized: u64 = 3;
    const EInvalidWitness: u64 = 4;

    /// Central registry for type metadata
    /// Uses generic witness to ensure type safety
    public struct TypeRegistry has key {
        id: UID,
        /// Maps TypeName to metadata string
        registered_types: VecMap<TypeName, vector<u8>>,
        admin: address,
    }

    /// Capability proving type ownership
    /// Generic parameter T is the type being registered
    public struct TypeCapability<phantom T> has key, store {
        id: UID,
        type_name: TypeName,
    }

    /// Create a plugin registry for your DeFi protocol
    /// 
    /// You're building a DeFi protocol that allows third-party developers to create
    /// plugins (custom token types, strategies, etc.). The registry tracks which types
    /// are officially registered and their metadata. Only the actual module that defines
    /// a type can register it - preventing impersonation.
    /// 
    /// Implementation Requirements:
    /// - Create TypeRegistry with new UID
    /// - Initialize empty VecMap with vec_map::empty()
    /// - Set admin = tx_context::sender(ctx)
    /// - Share the registry (public so anyone can query registered types)
    public fun create_registry(ctx: &mut TxContext) {
        // Your implementation here
    }

    /// Register your plugin type in the protocol
    /// 
    /// A developer creates a new token type `MyToken` and wants to register it officially.
    /// They call register_type<MyToken>() with a witness from their module. The witness
    /// PROVES they actually own the MyToken type definition - no one else can create it.
    /// This prevents scammers from registering fake versions of your types.
    /// 
    /// Real-world example: Registering a new yield strategy, custom AMM curve, or token wrapper.
    ///
    /// Implementation Requirements:
    /// - Get type name: type_name::with_original_ids<T>()
    /// - Check vec_map::contains() - abort with ETypeAlreadyRegistered if already registered
    /// - Insert into vec_map: vec_map::insert(&mut registry.registered_types, type_name, metadata)
    /// - Create TypeCapability<T> (proves this module owns the registration)
    /// - Transfer capability to sender (they can use it to update metadata later)
    public fun register_type<T: drop>(
        registry: &mut TypeRegistry,
        _witness: T,
        metadata: vector<u8>,
        ctx: &mut TxContext
    ) {
        // Your implementation here
    }

    /// Update metadata for a registered type
    /// 
    /// Authorization Pattern:
    /// - Requires TypeCapability<T> proving ownership
    /// - Type T in capability must match the type being updated
    ///
    /// Implementation Requirements:
    /// - Get type name: type_name::with_original_ids<T>()
    /// - Verify vec_map::contains(&registry.registered_types, &type_name)
    /// - Abort with ETypeNotRegistered if not found
    /// - Get mutable ref: vec_map::get_mut(&mut registry.registered_types, &type_name)
    /// - Update the metadata
    public fun update_metadata<T>(
        registry: &mut TypeRegistry,
        _cap: &TypeCapability<T>,
        new_metadata: vector<u8>,
    ) {
        // Your implementation here
    }

    /// Get metadata for a type
    /// 
    /// Implementation Requirements:
    /// - Get type name: type_name::with_original_ids<T>()
    /// - Check vec_map::contains()
    /// - Abort with ETypeNotRegistered if not found
    /// - Return: *vec_map::get(&registry.registered_types, &type_name)
    public fun get_metadata<T>(registry: &TypeRegistry): vector<u8> {
        // Your implementation here
        vector::empty<u8>()
    }

    /// Check if a type is registered
    /// 
    /// Implementation Requirements:
    /// - Get type name: type_name::with_original_ids<T>()
    /// - Return vec_map::contains(&registry.registered_types, &type_name)
    public fun is_registered<T>(registry: &TypeRegistry): bool {
        // Your implementation here
        false
    }

    /// Get the count of registered types
    /// 
    /// Implementation Requirements:
    /// - Return vec_map::size(&registry.registered_types)
    public fun registry_size(registry: &TypeRegistry): u64 {
        // Your implementation here
        0
    }

    // Getter functions
    public fun capability_type_name<T>(cap: &TypeCapability<T>): TypeName {
        cap.type_name
    }
}

#[test_only]
module suilings::type_registry_tests {
    use suilings::type_registry::{Self, TypeRegistry, TypeCapability};
    use sui::test_scenario;
    use std::type_name;

    const ADMIN: address = @0xAD;

    // Test witness types
    public struct TypeA has drop {}
    public struct TypeB has drop {}
    public struct TypeC has drop {}

    #[test]
    fun test_create_registry() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            type_registry::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let registry = test_scenario::take_shared<TypeRegistry>(&scenario);
            assert!(type_registry::registry_size(&registry) == 0, 0);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_register_type() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            type_registry::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let mut registry = test_scenario::take_shared<TypeRegistry>(&scenario);
            type_registry::register_type(
                &mut registry,
                TypeA {},
                b"Type A metadata",
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let registry = test_scenario::take_shared<TypeRegistry>(&scenario);
            assert!(type_registry::is_registered<TypeA>(&registry), 0);
            assert!(type_registry::registry_size(&registry) == 1, 1);
            
            let cap = test_scenario::take_from_sender<TypeCapability<TypeA>>(&scenario);
            assert!(
                type_registry::capability_type_name(&cap) == type_name::with_original_ids<TypeA>(),
                2
            );
            
            test_scenario::return_shared(registry);
            test_scenario::return_to_sender(&scenario, cap);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_multiple_type_registration() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            type_registry::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let mut registry = test_scenario::take_shared<TypeRegistry>(&scenario);
            
            type_registry::register_type(
                &mut registry,
                TypeA {},
                b"Type A",
                test_scenario::ctx(&mut scenario)
            );
            
            type_registry::register_type(
                &mut registry,
                TypeB {},
                b"Type B",
                test_scenario::ctx(&mut scenario)
            );
            
            type_registry::register_type(
                &mut registry,
                TypeC {},
                b"Type C",
                test_scenario::ctx(&mut scenario)
            );
            
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let registry = test_scenario::take_shared<TypeRegistry>(&scenario);
            assert!(type_registry::is_registered<TypeA>(&registry), 0);
            assert!(type_registry::is_registered<TypeB>(&registry), 1);
            assert!(type_registry::is_registered<TypeC>(&registry), 2);
            assert!(type_registry::registry_size(&registry) == 3, 3);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_get_metadata() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            type_registry::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let mut registry = test_scenario::take_shared<TypeRegistry>(&scenario);
            type_registry::register_type(
                &mut registry,
                TypeA {},
                b"Custom metadata for Type A",
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let registry = test_scenario::take_shared<TypeRegistry>(&scenario);
            let metadata = type_registry::get_metadata<TypeA>(&registry);
            assert!(metadata == b"Custom metadata for Type A", 0);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_update_metadata() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            type_registry::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let mut registry = test_scenario::take_shared<TypeRegistry>(&scenario);
            type_registry::register_type(
                &mut registry,
                TypeA {},
                b"Original metadata",
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let mut registry = test_scenario::take_shared<TypeRegistry>(&scenario);
            let cap = test_scenario::take_from_sender<TypeCapability<TypeA>>(&scenario);
            
            type_registry::update_metadata(
                &mut registry,
                &cap,
                b"Updated metadata"
            );
            
            test_scenario::return_shared(registry);
            test_scenario::return_to_sender(&scenario, cap);
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let registry = test_scenario::take_shared<TypeRegistry>(&scenario);
            let metadata = type_registry::get_metadata<TypeA>(&registry);
            assert!(metadata == b"Updated metadata", 0);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = type_registry::ETypeAlreadyRegistered)]
    fun test_duplicate_registration_fails() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            type_registry::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let mut registry = test_scenario::take_shared<TypeRegistry>(&scenario);
            
            type_registry::register_type(
                &mut registry,
                TypeA {},
                b"First registration",
                test_scenario::ctx(&mut scenario)
            );
            
            // This should fail - type already registered
            type_registry::register_type(
                &mut registry,
                TypeA {},
                b"Second registration",
                test_scenario::ctx(&mut scenario)
            );
            
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = type_registry::ETypeNotRegistered)]
    fun test_get_unregistered_type_fails() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            type_registry::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let registry = test_scenario::take_shared<TypeRegistry>(&scenario);
            
            // This should fail - type not registered
            let _metadata = type_registry::get_metadata<TypeA>(&registry);
            
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }
}

