// Exercise: Dynamic Fields - Metadata System
//
// Build a metadata system using dynamic fields to attach flexible data to objects.
// Dynamic fields allow adding key-value pairs at runtime without modifying struct definitions.
//
// Stuck? Check out: https://move-book.com/programmability/dynamic-fields.html

module suilings::metadata_system {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::dynamic_field;
use std::string::String;

// Error constants
const EMetadataNotFound: u64 = 1;
const EMetadataAlreadyExists: u64 = 2;

/// A base NFT that can have metadata attached dynamically
public struct NFT has key, store {
    id: UID,
    name: String,
    creator: address,
}

/// Create a new NFT
///
/// Your NFT platform needs flexible metadata that can be added
/// after minting. Dynamic fields allow attaching arbitrary data
/// without modifying the NFT struct definition.
///
/// Implementation Requirements:
/// - Create NFT with new UID
/// - Set name and creator (tx_context::sender())
/// - Transfer to creator
public fun create_nft(
    name: String,
    ctx: &mut TxContext
): NFT {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Add metadata to an NFT using dynamic fields
///
/// Attach key-value pairs to NFTs dynamically. This allows adding
/// attributes like "color", "rarity", "edition" without hardcoding
/// them in the NFT struct.
///
/// Dynamic Field Operations:
/// - Check if metadata already exists: dynamic_field::exists_<String>(&nft.id, key)
/// - Abort if exists (EMetadataAlreadyExists)
/// - Add to dynamic field: dynamic_field::add(&mut nft.id, key, value)
///
/// Note: Store the String value directly (no need for a wrapper struct)
public fun add_metadata(
    nft: &mut NFT,
    key: String,
    value: String,
) {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Get metadata value by key
///
/// Retrieve a specific metadata entry from an NFT.
/// Returns the value associated with the given key.
///
/// Security Requirements:
/// - Metadata must exist (abort with EMetadataNotFound)
///
/// Dynamic Field Operations:
/// - Check if exists: dynamic_field::exists_<String>(&nft.id, key)
/// - Borrow the field: dynamic_field::borrow<String, String>(&nft.id, key)
/// - Dereference and return: *dynamic_field::borrow<String, String>(&nft.id, key)
public fun get_metadata(nft: &NFT, key: String): String {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Update existing metadata
///
/// Modify the value of an existing metadata entry.
/// Useful for updating attributes like "level" or "status".
///
/// Security Requirements:
/// - Metadata must exist (abort with EMetadataNotFound)
///
/// Dynamic Field Operations:
/// - Verify exists
/// - Get mutable reference: dynamic_field::borrow_mut<String, String>(&mut nft.id, key)
/// - Update the value: *metadata = new_value
public fun update_metadata(
    nft: &mut NFT,
    key: String,
    new_value: String,
) {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Remove metadata from an NFT
///
/// Delete a metadata entry completely. This frees up storage
/// and removes the key-value pair.
///
/// Security Requirements:
/// - Metadata must exist (abort with EMetadataNotFound)
///
/// Dynamic Field Operations:
/// - Verify exists
/// - Remove: dynamic_field::remove<String, String>(&mut nft.id, key)
/// - Returns the String value
public fun remove_metadata(
    nft: &mut NFT,
    key: String,
): String {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Check if metadata exists
///
/// Query whether a specific metadata key exists on an NFT.
/// Useful for conditional logic and UI display.
///
/// Dynamic Field Operations:
/// - Use dynamic_field::exists_<String>(&nft.id, key)
public fun has_metadata(nft: &NFT, key: String): bool {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

// ==================== Getter Functions ====================

public fun nft_name(nft: &NFT): String {
    nft.name
}

public fun nft_creator(nft: &NFT): address {
    nft.creator
}
}

#[test_only]
module suilings::metadata_system_tests {
use suilings::metadata_system;
use sui::test_scenario;
use std::string;
use sui::transfer;

const CREATOR: address = @0xC8;

#[test]
fun test_create_nft() {
    let mut scenario = test_scenario::begin(CREATOR);

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let nft = metadata_system::create_nft(
            string::utf8(b"Cool NFT"),
            test_scenario::ctx(&mut scenario)
        );
        assert!(metadata_system::nft_name(&nft) == string::utf8(b"Cool NFT"), 0);
        assert!(metadata_system::nft_creator(&nft) == CREATOR, 1);
        transfer::public_transfer(nft, CREATOR);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_add_and_get_metadata() {
    let mut scenario = test_scenario::begin(CREATOR);

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let mut nft = metadata_system::create_nft(
            string::utf8(b"Rare NFT"),
            test_scenario::ctx(&mut scenario)
        );
        
        metadata_system::add_metadata(
            &mut nft,
            string::utf8(b"color"),
            string::utf8(b"blue")
        );
        
        assert!(metadata_system::has_metadata(&nft, string::utf8(b"color")), 0);
        assert!(
            metadata_system::get_metadata(&nft, string::utf8(b"color")) == string::utf8(b"blue"),
            1
        );
        
        transfer::public_transfer(nft, CREATOR);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_update_metadata() {
    let mut scenario = test_scenario::begin(CREATOR);

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let mut nft = metadata_system::create_nft(
            string::utf8(b"Upgradeable NFT"),
            test_scenario::ctx(&mut scenario)
        );
        
        metadata_system::add_metadata(
            &mut nft,
            string::utf8(b"level"),
            string::utf8(b"1")
        );
        
        metadata_system::update_metadata(
            &mut nft,
            string::utf8(b"level"),
            string::utf8(b"5")
        );
        
        assert!(
            metadata_system::get_metadata(&nft, string::utf8(b"level")) == string::utf8(b"5"),
            0
        );
        
        transfer::public_transfer(nft, CREATOR);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_remove_metadata() {
    let mut scenario = test_scenario::begin(CREATOR);

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let mut nft = metadata_system::create_nft(
            string::utf8(b"Temporary NFT"),
            test_scenario::ctx(&mut scenario)
        );
        
        metadata_system::add_metadata(
            &mut nft,
            string::utf8(b"temp"),
            string::utf8(b"data")
        );
        
        assert!(metadata_system::has_metadata(&nft, string::utf8(b"temp")), 0);
        
        let _metadata = metadata_system::remove_metadata(&mut nft, string::utf8(b"temp"));
        assert!(!metadata_system::has_metadata(&nft, string::utf8(b"temp")), 1);
        
        transfer::public_transfer(nft, CREATOR);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = metadata_system::EMetadataAlreadyExists)]
fun test_duplicate_metadata_fails() {
    let mut scenario = test_scenario::begin(CREATOR);

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let mut nft = metadata_system::create_nft(
            string::utf8(b"Test NFT"),
            test_scenario::ctx(&mut scenario)
        );
        
        metadata_system::add_metadata(
            &mut nft,
            string::utf8(b"key"),
            string::utf8(b"value1")
        );
        
        // This should fail - duplicate key
        metadata_system::add_metadata(
            &mut nft,
            string::utf8(b"key"),
            string::utf8(b"value2")
        );
        
        transfer::public_transfer(nft, CREATOR);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = metadata_system::EMetadataNotFound)]
fun test_get_nonexistent_metadata_fails() {
    let mut scenario = test_scenario::begin(CREATOR);

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let nft = metadata_system::create_nft(
            string::utf8(b"Empty NFT"),
            test_scenario::ctx(&mut scenario)
        );
        
        // This should fail - metadata doesn't exist
        let _ = metadata_system::get_metadata(&nft, string::utf8(b"nonexistent"));
        
        transfer::public_transfer(nft, CREATOR);
    };

    test_scenario::end(scenario);
}
}

