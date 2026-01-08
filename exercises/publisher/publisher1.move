// Exercise: Publisher Pattern - NFT Collection with Display
//
// Build an NFT collection using Publisher pattern to set display metadata.
// Publisher proves package ownership and allows you to define how NFTs appear in wallets.
//
// Stuck? Check out: https://move-book.com/programmability/publisher.html

module suilings::publisher1 {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::package::{Self, Publisher};
use sui::display::{Self, Display};
use std::string::{Self, String};

// Error constants
const ENotPublisher: u64 = 1;
const EInvalidMetadata: u64 = 2;
const EExceedsSupply: u64 = 3;

/// One-Time Witness for claiming Publisher
/// Must match module name in UPPERCASE
public struct PUBLISHER1 has drop {}

/// NFT that will have rich display metadata
public struct ArtNFT has key, store {
    id: UID,
    name: String,
    description: String,
    image_url: String,
    creator: address,
    edition: u64,
}

/// Collection info stored as shared object
public struct Collection has key {
    id: UID,
    name: String,
    total_supply: u64,
    minted: u64,
}

/// Launch your NFT art collection
///
/// You're an artist launching a collection of 1000 pieces. You want them to look
/// beautiful in wallets (Sui Wallet, Suiet, Ethos) with proper images, descriptions,
/// and metadata. Publisher lets you claim official ownership of your collection,
/// and Display defines how NFTs appear across all Sui wallets and marketplaces.
///
/// Real-world use: Every NFT project (Sui 8192, Prime Machin, etc.) uses this pattern.
///
/// Implementation Requirements:
/// 1. Claim Publisher: package::claim(otw, ctx) - proves YOU own this package
/// 2. Create Display template: display::new<ArtNFT>(&publisher, ctx)
/// 3. Set display fields (how wallets show your NFTs):
///    - "name": "{name}" - shows the NFT name
///    - "description": "{description}" - shows description
///    - "image_url": "{image_url}" - shows the artwork
///    - "creator": "{creator}" - shows artist address
///    - "edition": "Edition #{edition}" - shows "Edition #1", "Edition #2", etc.
/// 4. Update display: display::update_version(&mut display)
/// 5. Create Collection (shared object to track minting progress)
/// 6. Transfer Publisher and Display to yourself (you keep control)
public fun init_collection(
    otw: PUBLISHER1,
    collection_name: String,
    ctx: &mut TxContext
) {
    // Your implementation here
    // Step 1: Claim Publisher
    // Step 2: Create Display and set fields
    // Step 3: Create Collection
    // Step 4: Transfer objects
}

/// Mint a new NFT from the collection
///
/// Create an NFT with metadata. The Display object (created during init)
/// automatically defines how this NFT appears in wallets and explorers.
///
/// Security Requirements:
/// - Collection must have available supply (minted < total_supply)
///
/// Minting Operations:
/// - Increment collection.minted
/// - Create ArtNFT with provided metadata and new UID
/// - Transfer NFT to recipient
public fun mint_nft(
    collection: &mut Collection,
    name: String,
    description: String,
    image_url: String,
    recipient: address,
    ctx: &mut TxContext
) {
    // Your implementation here
}

// ==================== Getter Functions ====================

public fun nft_name(nft: &ArtNFT): String { nft.name }
public fun nft_description(nft: &ArtNFT): String { nft.description }
public fun nft_image_url(nft: &ArtNFT): String { nft.image_url }
public fun nft_creator(nft: &ArtNFT): address { nft.creator }
public fun nft_edition(nft: &ArtNFT): u64 { nft.edition }

public fun collection_name(collection: &Collection): String { collection.name }
public fun collection_total_supply(collection: &Collection): u64 { collection.total_supply }
public fun collection_minted(collection: &Collection): u64 { collection.minted }

#[test_only]
public fun create_witness_for_testing(): PUBLISHER1 {
    PUBLISHER1 {}
}

#[test_only]
public fun create_publisher_for_testing(ctx: &mut TxContext): Publisher {
    package::test_claim(create_witness_for_testing(), ctx)
}
}

#[test_only]
module suilings::publisher1_tests {
use suilings::publisher1::{Self, Collection, ArtNFT};
use sui::test_scenario;
use sui::package::Publisher;
use sui::display::Display;
use std::string;

const CREATOR: address = @0xC1;
const USER: address = @0x01;

#[test]
fun test_collection_initialization() {
    let mut scenario = test_scenario::begin(CREATOR);

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        publisher1::init_collection(
            publisher1::create_witness_for_testing(),
            string::utf8(b"Awesome Art Collection"),
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let collection = test_scenario::take_shared<Collection>(&scenario);
        assert!(publisher1::collection_name(&collection) == string::utf8(b"Awesome Art Collection"), 0);
        assert!(publisher1::collection_total_supply(&collection) == 1000, 1);
        assert!(publisher1::collection_minted(&collection) == 0, 2);
        
        // Check Publisher and Display were created
        assert!(test_scenario::has_most_recent_for_sender<Publisher>(&scenario), 3);
        assert!(test_scenario::has_most_recent_for_sender<Display<ArtNFT>>(&scenario), 4);
        
        test_scenario::return_shared(collection);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_mint_nft() {
    let mut scenario = test_scenario::begin(CREATOR);

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        publisher1::init_collection(
            publisher1::create_witness_for_testing(),
            string::utf8(b"Art Collection"),
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let mut collection = test_scenario::take_shared<Collection>(&scenario);
        publisher1::mint_nft(
            &mut collection,
            string::utf8(b"Sunset #1"),
            string::utf8(b"Beautiful sunset over mountains"),
            string::utf8(b"https://example.com/sunset1.jpg"),
            USER,
            test_scenario::ctx(&mut scenario)
        );
        assert!(publisher1::collection_minted(&collection) == 1, 0);
        test_scenario::return_shared(collection);
    };

    test_scenario::next_tx(&mut scenario, USER);
    {
        let nft = test_scenario::take_from_sender<ArtNFT>(&scenario);
        assert!(publisher1::nft_name(&nft) == string::utf8(b"Sunset #1"), 0);
        assert!(publisher1::nft_description(&nft) == string::utf8(b"Beautiful sunset over mountains"), 1);
        assert!(publisher1::nft_creator(&nft) == CREATOR, 2);
        assert!(publisher1::nft_edition(&nft) == 1, 3);
        test_scenario::return_to_sender(&scenario, nft);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_multiple_mints() {
    let mut scenario = test_scenario::begin(CREATOR);

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        publisher1::init_collection(
            publisher1::create_witness_for_testing(),
            string::utf8(b"Art Collection"),
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let mut collection = test_scenario::take_shared<Collection>(&scenario);
        
        publisher1::mint_nft(
            &mut collection,
            string::utf8(b"Art #1"),
            string::utf8(b"First piece"),
            string::utf8(b"https://example.com/1.jpg"),
            USER,
            test_scenario::ctx(&mut scenario)
        );
        
        publisher1::mint_nft(
            &mut collection,
            string::utf8(b"Art #2"),
            string::utf8(b"Second piece"),
            string::utf8(b"https://example.com/2.jpg"),
            USER,
            test_scenario::ctx(&mut scenario)
        );
        
        assert!(publisher1::collection_minted(&collection) == 2, 0);
        test_scenario::return_shared(collection);
    };

    test_scenario::end(scenario);
}
}

