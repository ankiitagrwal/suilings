// Exercise: Generic Witness - Supply Chain Verification
//
// Build a supply chain system using witness proofs for verification and tracking.
// Witness proofs guarantee that verification steps have been completed before allowing operations.
//
// Stuck? Check out: https://move-book.com/programmability/witness-pattern.html

module suilings::verification_system {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::type_name::{Self, TypeName};

    // Error codes
    const ENotVerified: u64 = 1;
    const EAlreadyVerified: u64 = 2;
    const EInvalidProof: u64 = 3;
    const EVerificationFailed: u64 = 4;

    /// Proof that a type T has been verified
    /// This is a zero-cost abstraction using phantom types
    public struct VerificationProof<phantom T> has copy, drop, store {
        verified: bool,
    }

    /// Certificate proving verification was performed
    public struct VerificationCertificate<phantom T> has key, store {
        id: UID,
        verifier: address,
        type_verified: TypeName,
    }

    /// A verified container that can only hold verified types
    public struct VerifiedContainer<T> has key, store {
        id: UID,
        value: T,
        verification_level: u8,
    }

    /// Verification registry tracking all verifications
    public struct VerificationRegistry has key {
        id: UID,
        total_verifications: u64,
        admin: address,
    }

    /// Launch your product verification system
    /// 
    /// You're building a supply chain platform for luxury goods (watches, bags, electronics).
    /// Brands need to verify their products are authentic before they enter the marketplace.
    /// Each product type (Rolex, Gucci, iPhone) gets verified with proof. Only verified
    /// products can be containerized and sold. This prevents counterfeits!
    /// 
    /// Implementation Requirements:
    /// - Create VerificationRegistry with new UID
    /// - Set total_verifications = 0 (track all verifications)
    /// - Set admin = sender (you run the verification service)
    /// - Share registry (public so everyone can check verification status)
    public fun create_registry(ctx: &mut TxContext) {
        // Your implementation here
    }

    /// Brand verifies their product type
    /// 
    /// Rolex calls verify_type<RolexWatch>(witness) from their official module.
    /// Only THEY can create the witness. This returns a VerificationProof<RolexWatch>
    /// that proves "yes, Rolex themselves verified this product type". The proof has
    /// copy ability so it can be used multiple times for different products.
    /// 
    /// Real-world: Like getting an official brand certification before selling.
    ///
    /// Implementation Requirements:
    /// - Create VerificationProof<W> with verified = true
    /// - Return the proof (can be copied and reused)
    public fun verify_type<W: drop>(_witness: W): VerificationProof<W> {
        // Your implementation here
        VerificationProof { verified: false }
    }

    /// Get official verification certificate
    /// 
    /// Rolex has the VerificationProof. Now they want an official certificate NFT
    /// to show to marketplaces/buyers. This certificate is stored on-chain permanently
    /// and proves "this product type passed verification at block X by verifier Y".
    /// Marketplaces can check: "does this seller have a RolexWatch certificate?"
    ///
    /// Implementation Requirements:
    /// - Check proof.verified == true - abort with ENotVerified if fake proof
    /// - Increment registry.total_verifications (track stats)
    /// - Create VerificationCertificate<T> NFT with verifier and type info
    /// - Transfer certificate to sender (Rolex keeps it)
    public fun issue_certificate<T>(
        registry: &mut VerificationRegistry,
        proof: VerificationProof<T>,
        ctx: &mut TxContext
    ) {
        // Your implementation here
    }

    /// Create a verified container
    /// 
    /// Proof Requirement:
    /// - Requires VerificationProof<T> to create container
    /// - The proof ensures T has been verified before containerization
    ///
    /// Implementation Requirements:
    /// - Check proof.verified == true
    /// - Abort with ENotVerified if not verified
    /// - Create VerifiedContainer<T> with new UID, value, and verification_level
    /// - Transfer container to sender
    public fun create_verified_container<T: store>(
        value: T,
        verification_level: u8,
        proof: VerificationProof<T>,
        ctx: &mut TxContext
    ) {
        // Your implementation here
    }

    /// Upgrade verification level
    /// 
    /// Certificate-Based Authorization:
    /// - Requires VerificationCertificate<T> to upgrade
    /// - Certificate proves the caller has verification authority
    ///
    /// Implementation Requirements:
    /// - Check container type matches certificate type
    /// - Require new_level > container.verification_level
    /// - Abort with EVerificationFailed if new_level <= current level
    /// - Update container.verification_level = new_level
    public fun upgrade_verification<T: store>(
        container: &mut VerifiedContainer<T>,
        _cert: &VerificationCertificate<T>,
        new_level: u8,
    ) {
        // Your implementation here
    }

    /// Extract value from verified container
    /// 
    /// Proof-Based Extraction:
    /// - Requires VerificationProof<T> matching container type
    /// - Proof ensures extraction is authorized
    ///
    /// Implementation Requirements:
    /// - Check proof.verified == true
    /// - Abort with ENotVerified if not verified
    /// - Destructure container: let VerifiedContainer { id, value, verification_level: _ } = container
    /// - Delete the UID: object::delete(id)
    /// - Return the value
    public fun extract_value<T: store>(
        container: VerifiedContainer<T>,
        proof: VerificationProof<T>,
    ): T {
        // Your implementation here
    }

    /// Check if a proof is valid
    /// 
    /// Implementation Requirements:
    /// - Return proof.verified
    public fun is_proof_valid<T>(proof: &VerificationProof<T>): bool {
        // Your implementation here
        false
    }

    /// Get verification level
    /// 
    /// Implementation Requirements:
    /// - Return container.verification_level
    public fun get_verification_level<T>(container: &VerifiedContainer<T>): u8 {
        // Your implementation here
        0
    }

    /// Get total verifications
    /// 
    /// Implementation Requirements:
    /// - Return registry.total_verifications
    public fun total_verifications(registry: &VerificationRegistry): u64 {
        // Your implementation here
        0
    }

    // Getter functions
    public fun certificate_verifier<T>(cert: &VerificationCertificate<T>): address {
        cert.verifier
    }

    public fun certificate_type<T>(cert: &VerificationCertificate<T>): TypeName {
        cert.type_verified
    }
}

#[test_only]
module suilings::verification_system_tests {
    use suilings::verification_system::{Self, VerificationRegistry, VerificationProof, VerificationCertificate, VerifiedContainer};
    use sui::test_scenario;
    use std::type_name;

    const ADMIN: address = @0xAD;
    const USER: address = @0x01;

    // Test types
    public struct TypeX has drop {}
    public struct TypeY has drop {}
    
    // Test data type
    public struct TestData has drop, store {
        value: u64,
    }

    #[test]
    fun test_create_registry() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            verification_system::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let registry = test_scenario::take_shared<VerificationRegistry>(&scenario);
            assert!(verification_system::total_verifications(&registry) == 0, 0);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_verify_type() {
        let proof = verification_system::verify_type(TypeX {});
        assert!(verification_system::is_proof_valid(&proof), 0);
    }

    #[test]
    fun test_issue_certificate() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            verification_system::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER);
        {
            let mut registry = test_scenario::take_shared<VerificationRegistry>(&scenario);
            let proof = verification_system::verify_type(TypeX {});
            
            verification_system::issue_certificate(
                &mut registry,
                proof,
                test_scenario::ctx(&mut scenario)
            );
            
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, USER);
        {
            let registry = test_scenario::take_shared<VerificationRegistry>(&scenario);
            assert!(verification_system::total_verifications(&registry) == 1, 0);
            
            let cert = test_scenario::take_from_sender<VerificationCertificate<TypeX>>(&scenario);
            assert!(verification_system::certificate_verifier(&cert) == USER, 1);
            assert!(verification_system::certificate_type(&cert) == type_name::with_original_ids<TypeX>(), 2);
            
            test_scenario::return_shared(registry);
            test_scenario::return_to_sender(&scenario, cert);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_create_verified_container() {
        let mut scenario = test_scenario::begin(USER);

        test_scenario::next_tx(&mut scenario, USER);
        {
            let proof = verification_system::verify_type(TestData { value: 0 });
            let data = TestData { value: 42 };
            
            verification_system::create_verified_container(
                data,
                1,
                proof,
                test_scenario::ctx(&mut scenario)
            );
        };

        test_scenario::next_tx(&mut scenario, USER);
        {
            let container = test_scenario::take_from_sender<VerifiedContainer<TestData>>(&scenario);
            assert!(verification_system::get_verification_level(&container) == 1, 0);
            test_scenario::return_to_sender(&scenario, container);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_upgrade_verification() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            verification_system::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER);
        {
            let mut registry = test_scenario::take_shared<VerificationRegistry>(&scenario);
            let proof = verification_system::verify_type(TestData { value: 0 });
            
            verification_system::issue_certificate(&mut registry, proof, test_scenario::ctx(&mut scenario));
            
            let data = TestData { value: 100 };
            verification_system::create_verified_container(data, 1, proof, test_scenario::ctx(&mut scenario));
            
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, USER);
        {
            let mut container = test_scenario::take_from_sender<VerifiedContainer<TestData>>(&scenario);
            let cert = test_scenario::take_from_sender<VerificationCertificate<TestData>>(&scenario);
            
            verification_system::upgrade_verification(&mut container, &cert, 3);
            
            assert!(verification_system::get_verification_level(&container) == 3, 0);
            
            test_scenario::return_to_sender(&scenario, container);
            test_scenario::return_to_sender(&scenario, cert);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_extract_value() {
        let mut scenario = test_scenario::begin(USER);

        test_scenario::next_tx(&mut scenario, USER);
        {
            let proof = verification_system::verify_type(TestData { value: 0 });
            let data = TestData { value: 999 };
            
            verification_system::create_verified_container(data, 2, proof, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER);
        {
            let container = test_scenario::take_from_sender<VerifiedContainer<TestData>>(&scenario);
            let proof = verification_system::verify_type(TestData { value: 0 });
            
            let data = verification_system::extract_value(container, proof);
            assert!(data.value == 999, 0);
            
            let TestData { value: _ } = data;
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_multiple_type_verifications() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            verification_system::create_registry(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER);
        {
            let mut registry = test_scenario::take_shared<VerificationRegistry>(&scenario);
            
            let proof_x = verification_system::verify_type(TypeX {});
            let proof_y = verification_system::verify_type(TypeY {});
            
            verification_system::issue_certificate(&mut registry, proof_x, test_scenario::ctx(&mut scenario));
            verification_system::issue_certificate(&mut registry, proof_y, test_scenario::ctx(&mut scenario));
            
            test_scenario::return_shared(registry);
        };

        test_scenario::next_tx(&mut scenario, USER);
        {
            let registry = test_scenario::take_shared<VerificationRegistry>(&scenario);
            assert!(verification_system::total_verifications(&registry) == 2, 0);
            test_scenario::return_shared(registry);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_proof_can_be_copied() {
        let proof = verification_system::verify_type(TypeX {});
        let proof_copy = proof;
        
        assert!(verification_system::is_proof_valid(&proof), 0);
        assert!(verification_system::is_proof_valid(&proof_copy), 1);
    }
}

