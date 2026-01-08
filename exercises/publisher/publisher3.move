// Exercise: Publisher Pattern - Package Verification & Transfer Policies
//
// Build a package verification system using Publisher to prove authenticity.
// Learn how Publisher enables transfer policies and package ownership verification.
//
// Stuck? Check out: https://move-book.com/programmability/publisher.html

module suilings::publisher3 {
use sui::object::{Self, UID, ID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::package::{Self, Publisher};
use sui::display::{Self, Display};
use std::string::{Self, String};
use std::option::{Self, Option};

// Error constants
const ENotVerified: u64 = 1;
const ENotAuthorized: u64 = 2;
const EAlreadyVerified: u64 = 3;

/// One-Time Witness for claiming Publisher
public struct PUBLISHER3 has drop {}

/// Certificate proving an item is from verified publisher
public struct VerificationCertificate has key, store {
    id: UID,
    item_type: String,
    verified_by: ID,  // Publisher object ID
    verified_at: u64, // Timestamp (simplified as u64)
}

/// Verified item that requires certificate
public struct VerifiedItem has key, store {
    id: UID,
    name: String,
    category: String,
    certificate: Option<VerificationCertificate>,
}

/// Registry tracking all verified packages
public struct VerificationRegistry has key {
    id: UID,
    total_verified: u64,
    verified_packages: vector<ID>,
}

/// Initialize verification system with Publisher
///
/// Publisher is used to:
/// 1. Prove package ownership
/// 2. Create verification certificates
/// 3. Enable transfer policies
/// 4. Set display metadata
///
/// Implementation Requirements:
/// 1. Claim Publisher using package::claim(otw, ctx)
/// 2. Create Display<VerifiedItem> with fields:
///    - "name": "{name}"
///    - "description": "Verified {category} from authenticated publisher"
///    - "category": "{category}"
///    - "verified": "true"
///    - "image_url": "https://verified.io/badge.png"
/// 3. Create Display<VerificationCertificate> with fields:
///    - "name": "Verification Certificate"
///    - "description": "Certificate for {item_type}"
///    - "type": "{item_type}"
/// 4. Update both displays
/// 5. Create VerificationRegistry shared object
/// 6. Transfer Publisher to sender
/// 7. Transfer both Display objects to sender
public fun init_verification_system(
    otw: PUBLISHER3,
    ctx: &mut TxContext
) {
    // Your implementation here
}

/// Issue verification certificate using Publisher
///
/// Only package owner (who holds Publisher) can issue certificates.
/// This proves items are authentic and from trusted source.
///
/// Security Requirements:
/// - Requires Publisher reference (proves ownership)
///
/// Certificate Operations:
/// - Create VerificationCertificate with new UID
/// - Set item_type, verified_by = object::id(publisher)
/// - Set verified_at (use tx_context::epoch(ctx) or arbitrary u64)
/// - Transfer certificate to recipient
public fun issue_certificate(
    publisher: &Publisher,
    registry: &mut VerificationRegistry,
    item_type: String,
    recipient: address,
    ctx: &mut TxContext
) {
    // Your implementation here
}

/// Create verified item with certificate
///
/// Items can only be verified if caller has a valid certificate.
/// This pattern ensures authenticity and provenance.
///
/// Security Requirements:
/// - Certificate must be provided (not None)
///
/// Creation Operations:
/// - Create VerifiedItem with new UID
/// - Set name, category
/// - Attach certificate using option::some(certificate)
/// - Transfer item to owner
public fun create_verified_item(
    _name: String,
    _category: String,
    certificate: VerificationCertificate,
    _owner: address,
    _ctx: &mut TxContext
) {
    // Your implementation here
    // Remove this temporary line after implementation:
    let VerificationCertificate { id, item_type: _, verified_by: _, verified_at: _ } = certificate;
    object::delete(id);
}

/// Check if item is verified
///
/// Verify that item has a valid certificate from trusted publisher.
/// Returns true if certificate exists and is valid.
public fun is_verified(item: &VerifiedItem): bool {
    // Your implementation here
    // Use option::is_some(&item.certificate)
    false
}

/// Get certificate info if verified
///
/// Extract certificate details for verification purposes.
/// Aborts if item is not verified.
///
/// Security Requirements:
/// - Item must have certificate (abort with ENotVerified)
public fun get_certificate_info(item: &VerifiedItem): (String, ID) {
    // Your implementation here
    // Use option::borrow(&item.certificate)
    (string::utf8(b""), object::id_from_address(@0x0))
}

/// Transfer verified item (simplified transfer policy)
///
/// In production, Publisher enables complex transfer policies.
/// This simplified version shows the concept.
///
/// Security Requirements:
/// - Item must be verified (has certificate)
public fun transfer_verified_item(
    item: VerifiedItem,
    _recipient: address,
) {
    // Your implementation here
    // Remove these temporary lines after implementation:
    let VerifiedItem { id, name: _, category: _, certificate } = item;
    if (option::is_some(&certificate)) {
        let VerificationCertificate { 
            id: cert_id, 
            item_type: _, 
            verified_by: _, 
            verified_at: _ 
        } = option::destroy_some(certificate);
        object::delete(cert_id);
    } else {
        option::destroy_none(certificate);
    };
    object::delete(id);
}

// ==================== Getter Functions ====================

public fun item_name(item: &VerifiedItem): String { item.name }
public fun item_category(item: &VerifiedItem): String { item.category }

public fun certificate_item_type(cert: &VerificationCertificate): String { cert.item_type }
public fun certificate_verified_by(cert: &VerificationCertificate): ID { cert.verified_by }
public fun certificate_verified_at(cert: &VerificationCertificate): u64 { cert.verified_at }

public fun registry_total_verified(registry: &VerificationRegistry): u64 { registry.total_verified }

#[test_only]
public fun create_witness_for_testing(): PUBLISHER3 {
    PUBLISHER3 {}
}

#[test_only]
public fun create_publisher_for_testing(ctx: &mut TxContext): Publisher {
    package::test_claim(create_witness_for_testing(), ctx)
}
}

#[test_only]
module suilings::publisher3_tests {
use suilings::publisher3::{Self, VerificationRegistry, VerifiedItem, VerificationCertificate};
use sui::test_scenario;
use sui::package::Publisher;
use sui::display::Display;
use std::string;

const PUBLISHER_OWNER: address = @0xAD;
const USER1: address = @0x01;
const USER2: address = @0x02;

#[test]
fun test_verification_system_init() {
    let mut scenario = test_scenario::begin(PUBLISHER_OWNER);

    test_scenario::next_tx(&mut scenario, PUBLISHER_OWNER);
    {
        publisher3::init_verification_system(
            publisher3::create_witness_for_testing(),
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, PUBLISHER_OWNER);
    {
        let registry = test_scenario::take_shared<VerificationRegistry>(&scenario);
        assert!(publisher3::registry_total_verified(&registry) == 0, 0);
        
        // Verify Publisher and Displays were created
        assert!(test_scenario::has_most_recent_for_sender<Publisher>(&scenario), 1);
        assert!(test_scenario::has_most_recent_for_sender<Display<VerifiedItem>>(&scenario), 2);
        assert!(test_scenario::has_most_recent_for_sender<Display<VerificationCertificate>>(&scenario), 3);
        
        test_scenario::return_shared(registry);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_issue_certificate() {
    let mut scenario = test_scenario::begin(PUBLISHER_OWNER);

    test_scenario::next_tx(&mut scenario, PUBLISHER_OWNER);
    {
        publisher3::init_verification_system(
            publisher3::create_witness_for_testing(),
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, PUBLISHER_OWNER);
    {
        let publisher = test_scenario::take_from_sender<Publisher>(&scenario);
        let mut registry = test_scenario::take_shared<VerificationRegistry>(&scenario);
        
        publisher3::issue_certificate(
            &publisher,
            &mut registry,
            string::utf8(b"Premium NFT"),
            USER1,
            test_scenario::ctx(&mut scenario)
        );
        
        test_scenario::return_to_sender(&scenario, publisher);
        test_scenario::return_shared(registry);
    };

    test_scenario::next_tx(&mut scenario, USER1);
    {
        let cert = test_scenario::take_from_sender<VerificationCertificate>(&scenario);
        assert!(publisher3::certificate_item_type(&cert) == string::utf8(b"Premium NFT"), 0);
        test_scenario::return_to_sender(&scenario, cert);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_create_verified_item() {
    let mut scenario = test_scenario::begin(PUBLISHER_OWNER);

    test_scenario::next_tx(&mut scenario, PUBLISHER_OWNER);
    {
        publisher3::init_verification_system(
            publisher3::create_witness_for_testing(),
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, PUBLISHER_OWNER);
    {
        let publisher = test_scenario::take_from_sender<Publisher>(&scenario);
        let mut registry = test_scenario::take_shared<VerificationRegistry>(&scenario);
        
        publisher3::issue_certificate(
            &publisher,
            &mut registry,
            string::utf8(b"Art NFT"),
            USER1,
            test_scenario::ctx(&mut scenario)
        );
        
        test_scenario::return_to_sender(&scenario, publisher);
        test_scenario::return_shared(registry);
    };

    test_scenario::next_tx(&mut scenario, USER1);
    {
        let cert = test_scenario::take_from_sender<VerificationCertificate>(&scenario);
        
        publisher3::create_verified_item(
            string::utf8(b"Verified Artwork"),
            string::utf8(b"Digital Art"),
            cert,
            USER1,
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, USER1);
    {
        let item = test_scenario::take_from_sender<VerifiedItem>(&scenario);
        assert!(publisher3::item_name(&item) == string::utf8(b"Verified Artwork"), 0);
        assert!(publisher3::is_verified(&item), 1);
        test_scenario::return_to_sender(&scenario, item);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_transfer_verified_item() {
    let mut scenario = test_scenario::begin(PUBLISHER_OWNER);

    // Initialize and create verified item
    test_scenario::next_tx(&mut scenario, PUBLISHER_OWNER);
    {
        publisher3::init_verification_system(
            publisher3::create_witness_for_testing(),
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, PUBLISHER_OWNER);
    {
        let publisher = test_scenario::take_from_sender<Publisher>(&scenario);
        let mut registry = test_scenario::take_shared<VerificationRegistry>(&scenario);
        
        publisher3::issue_certificate(
            &publisher,
            &mut registry,
            string::utf8(b"Collectible"),
            USER1,
            test_scenario::ctx(&mut scenario)
        );
        
        test_scenario::return_to_sender(&scenario, publisher);
        test_scenario::return_shared(registry);
    };

    test_scenario::next_tx(&mut scenario, USER1);
    {
        let cert = test_scenario::take_from_sender<VerificationCertificate>(&scenario);
        publisher3::create_verified_item(
            string::utf8(b"Rare Item"),
            string::utf8(b"Collectible"),
            cert,
            USER1,
            test_scenario::ctx(&mut scenario)
        );
    };

    // Transfer to USER2
    test_scenario::next_tx(&mut scenario, USER1);
    {
        let item = test_scenario::take_from_sender<VerifiedItem>(&scenario);
        publisher3::transfer_verified_item(item, USER2);
    };

    // Verify USER2 received it
    test_scenario::next_tx(&mut scenario, USER2);
    {
        assert!(test_scenario::has_most_recent_for_sender<VerifiedItem>(&scenario), 0);
        let item = test_scenario::take_from_sender<VerifiedItem>(&scenario);
        assert!(publisher3::is_verified(&item), 1);
        test_scenario::return_to_sender(&scenario, item);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_multiple_certificates() {
    let mut scenario = test_scenario::begin(PUBLISHER_OWNER);

    test_scenario::next_tx(&mut scenario, PUBLISHER_OWNER);
    {
        publisher3::init_verification_system(
            publisher3::create_witness_for_testing(),
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, PUBLISHER_OWNER);
    {
        let publisher = test_scenario::take_from_sender<Publisher>(&scenario);
        let mut registry = test_scenario::take_shared<VerificationRegistry>(&scenario);
        
        // Issue multiple certificates
        publisher3::issue_certificate(
            &publisher,
            &mut registry,
            string::utf8(b"Type A"),
            USER1,
            test_scenario::ctx(&mut scenario)
        );
        
        publisher3::issue_certificate(
            &publisher,
            &mut registry,
            string::utf8(b"Type B"),
            USER2,
            test_scenario::ctx(&mut scenario)
        );
        
        test_scenario::return_to_sender(&scenario, publisher);
        test_scenario::return_shared(registry);
    };

    test_scenario::end(scenario);
}
}

