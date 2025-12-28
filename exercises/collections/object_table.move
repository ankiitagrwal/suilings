// Exercise: Collections - ObjectTable (NFT Collection)
//
// Build an NFT collection manager using ObjectTable to store NFTs.
// ObjectTable stores objects as values, maintaining their UIDs.
//
// Stuck? Check out: https://move-book.com/programmability/collections.html

#[allow(duplicate_alias)]
module suilings::nft_collection {
use sui::object::{Self, UID, ID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::object_table::{Self, ObjectTable};
use std::string::String;

// Error constants
const ENFTNotFound: u64 = 1;
const ENotOwner: u64 = 2;
const ENotCreator: u64 = 3;
const ENFTAlreadyExists: u64 = 4;
const ECollectionFull: u64 = 5;

/// An individual NFT in the collection
public struct NFT has key, store {
    id: UID,
    /// Name of the NFT
    name: String,
    /// Description or metadata
    description: String,
    /// URL to the NFT image/asset
    url: String,
}

/// A collection that manages multiple NFTs using ObjectTable
public struct NFTCollection has key {
    id: UID,
    /// Collection name
    name: String,
    /// ObjectTable mapping token_id (u64) to NFT objects
    nfts: ObjectTable<u64, NFT>,
    /// Next token ID to mint
    next_token_id: u64,
    /// Maximum supply (0 = unlimited)
    max_supply: u64,
    /// Collection creator
    creator: address,
}

/// Launch your NFT collection
///
/// Your art project needs an on-chain collection where NFTs are stored
/// centrally until distributed. ObjectTable keeps NFTs as objects (with UIDs)
/// unlike regular Table which only stores simple values.
///
/// Implementation Requirements:
/// - Create an empty ObjectTable using object_table::new()
/// - Set next_token_id to 1 (start counting from 1)
/// - Store the creator as tx_context::sender()
/// - Create NFTCollection with: id, name, nfts (empty), next_token_id, max_supply, creator
/// - Share the collection using transfer::share_object() (public minting)
public fun create_collection(
    name: String,
    max_supply: u64,
    ctx: &mut TxContext
) {
    // Your implementation here
}

    /// Mints a new NFT and adds it to the collection
    ///
    /// Create a new NFT and store it in the collection's ObjectTable.
    /// Like minting a new token in an NFT drop.
    ///
    /// Security Validations:
    /// - Only creator can mint (abort with ENotCreator)
    /// - Check max_supply if set (abort with ECollectionFull)
    ///
    /// Implementation:
    /// - Verify sender is creator
    /// - If max_supply > 0, verify next_token_id <= max_supply
    /// - Create NFT struct with: id, name, description, url
    /// - Add to ObjectTable: object_table::add(&mut collection.nfts, token_id, nft)
    /// - Increment collection.next_token_id
    public fun mint_nft(
        collection: &mut NFTCollection,
        name: String,
        description: String,
        url: String,
        ctx: &mut TxContext,
    ) {
        // Your implementation here
    }

    /// Transfers an NFT from the collection to a recipient
    ///
    /// Remove an NFT from the collection and transfer ownership.
    /// Like selling or gifting an NFT from the collection.
    ///
    /// Security Requirements:
    /// - Only creator can transfer (abort with ENotCreator)
    /// - NFT must exist (abort with ENFTNotFound)
    ///
    /// Implementation:
    /// - Verify sender is creator
    /// - Verify token_id exists using object_table::contains()
    /// - Remove NFT: object_table::remove(&mut collection.nfts, token_id)
    /// - Transfer NFT to recipient using transfer::public_transfer()
    public fun transfer_nft(
        collection: &mut NFTCollection,
        token_id: u64,
        recipient: address,
        ctx: &TxContext,
    ) {
        // Your implementation here
    }

    /// Burns an NFT from the collection
    ///
    /// Permanently remove and destroy an NFT.
    /// Like burning unsold tokens or removing from circulation.
    ///
    /// Security Requirements:
    /// - Only creator can burn (abort with ENotCreator)
    /// - NFT must exist (abort with ENFTNotFound)
    ///
    /// Implementation:
    /// - Verify sender is creator
    /// - Verify token_id exists
    /// - Remove NFT from ObjectTable
    /// - Unpack NFT struct and delete its UID using object::delete()
    public fun burn_nft(
        collection: &mut NFTCollection,
        token_id: u64,
        ctx: &TxContext,
    ) {
        // Your implementation here
    }

    /// Gets an immutable reference to an NFT in the collection
    ///
    /// View NFT details without removing it from the collection.
    /// Like browsing a gallery.
    ///
    /// Security Requirements:
    /// - NFT must exist (abort with ENFTNotFound)
    ///
    /// Implementation:
    /// - Verify token_id exists using object_table::contains()
    /// - Return immutable reference: object_table::borrow(&collection.nfts, token_id)
    public fun get_nft(collection: &NFTCollection, token_id: u64): &NFT {
        assert!(object_table::contains(&collection.nfts, token_id), ENFTNotFound);
        object_table::borrow(&collection.nfts, token_id)
    }

    // ==================== Getter Functions ====================

    public fun collection_name(collection: &NFTCollection): String {
        collection.name
    }

    public fun creator(collection: &NFTCollection): address {
        collection.creator
    }

    public fun total_supply(collection: &NFTCollection): u64 {
        object_table::length(&collection.nfts)
    }

    public fun max_supply(collection: &NFTCollection): u64 {
        collection.max_supply
    }

    public fun next_token_id(collection: &NFTCollection): u64 {
        collection.next_token_id
    }

    public fun nft_exists(collection: &NFTCollection, token_id: u64): bool {
        object_table::contains(&collection.nfts, token_id)
    }

    public fun nft_name(nft: &NFT): String {
        nft.name
    }

    public fun nft_description(nft: &NFT): String {
        nft.description
    }

    public fun nft_url(nft: &NFT): String {
        nft.url
    }

    public fun nft_id(nft: &NFT): ID {
        object::uid_to_inner(&nft.id)
    }
}

#[test_only]
module suilings::nft_collection_tests {
    use suilings::nft_collection::{Self, NFTCollection, NFT};
    use sui::test_scenario;
    use std::string;

    const CREATOR: address = @0xC8;
    const USER: address = @0xB0B;

    #[test]
    fun test_create_collection() {
        let mut scenario = test_scenario::begin(CREATOR);

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            nft_collection::create_collection(
                string::utf8(b"My NFT Collection"),
                100,
                test_scenario::ctx(&mut scenario)
            );
        };

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            let collection = test_scenario::take_shared<NFTCollection>(&scenario);
            assert!(nft_collection::creator(&collection) == CREATOR, 0);
            assert!(nft_collection::total_supply(&collection) == 0, 1);
            assert!(nft_collection::max_supply(&collection) == 100, 2);
            assert!(nft_collection::next_token_id(&collection) == 1, 3);
            test_scenario::return_shared(collection);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_mint_nft() {
        let mut scenario = test_scenario::begin(CREATOR);

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            nft_collection::create_collection(string::utf8(b"Collection"), 100, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            let mut collection = test_scenario::take_shared<NFTCollection>(&scenario);
            nft_collection::mint_nft(
                &mut collection,
                string::utf8(b"NFT #1"),
                string::utf8(b"First NFT"),
                string::utf8(b"https://example.com/1"),
                test_scenario::ctx(&mut scenario)
            );
            assert!(nft_collection::total_supply(&collection) == 1, 0);
            assert!(nft_collection::next_token_id(&collection) == 2, 1);
            assert!(nft_collection::nft_exists(&collection, 1), 2);
            test_scenario::return_shared(collection);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_multiple_mints() {
        let mut scenario = test_scenario::begin(CREATOR);

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            nft_collection::create_collection(string::utf8(b"Collection"), 10, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            let mut collection = test_scenario::take_shared<NFTCollection>(&scenario);
            nft_collection::mint_nft(&mut collection, string::utf8(b"NFT #1"), string::utf8(b"First"), string::utf8(b"url1"), test_scenario::ctx(&mut scenario));
            nft_collection::mint_nft(&mut collection, string::utf8(b"NFT #2"), string::utf8(b"Second"), string::utf8(b"url2"), test_scenario::ctx(&mut scenario));
            nft_collection::mint_nft(&mut collection, string::utf8(b"NFT #3"), string::utf8(b"Third"), string::utf8(b"url3"), test_scenario::ctx(&mut scenario));
            
            assert!(nft_collection::total_supply(&collection) == 3, 0);
            assert!(nft_collection::next_token_id(&collection) == 4, 1);
            test_scenario::return_shared(collection);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_nft() {
        let mut scenario = test_scenario::begin(CREATOR);

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            nft_collection::create_collection(string::utf8(b"Collection"), 100, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            let mut collection = test_scenario::take_shared<NFTCollection>(&scenario);
            nft_collection::mint_nft(&mut collection, string::utf8(b"NFT #1"), string::utf8(b"First"), string::utf8(b"url"), test_scenario::ctx(&mut scenario));
            test_scenario::return_shared(collection);
        };

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            let mut collection = test_scenario::take_shared<NFTCollection>(&scenario);
            nft_collection::transfer_nft(&mut collection, 1, USER, test_scenario::ctx(&mut scenario));
            assert!(nft_collection::total_supply(&collection) == 0, 0);
            assert!(!nft_collection::nft_exists(&collection, 1), 1);
            test_scenario::return_shared(collection);
        };

        test_scenario::next_tx(&mut scenario, USER);
        {
            let nft = test_scenario::take_from_sender<NFT>(&scenario);
            assert!(nft_collection::nft_name(&nft) == string::utf8(b"NFT #1"), 0);
            test_scenario::return_to_sender(&scenario, nft);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_burn_nft() {
        let mut scenario = test_scenario::begin(CREATOR);

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            nft_collection::create_collection(string::utf8(b"Collection"), 100, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            let mut collection = test_scenario::take_shared<NFTCollection>(&scenario);
            nft_collection::mint_nft(&mut collection, string::utf8(b"NFT #1"), string::utf8(b"First"), string::utf8(b"url"), test_scenario::ctx(&mut scenario));
            test_scenario::return_shared(collection);
        };

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            let mut collection = test_scenario::take_shared<NFTCollection>(&scenario);
            nft_collection::burn_nft(&mut collection, 1, test_scenario::ctx(&mut scenario));
            assert!(nft_collection::total_supply(&collection) == 0, 0);
            test_scenario::return_shared(collection);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft_collection::ECollectionFull)]
    fun test_exceed_max_supply_fails() {
        let mut scenario = test_scenario::begin(CREATOR);

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            nft_collection::create_collection(string::utf8(b"Collection"), 2, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            let mut collection = test_scenario::take_shared<NFTCollection>(&scenario);
            nft_collection::mint_nft(&mut collection, string::utf8(b"NFT #1"), string::utf8(b"First"), string::utf8(b"url"), test_scenario::ctx(&mut scenario));
            nft_collection::mint_nft(&mut collection, string::utf8(b"NFT #2"), string::utf8(b"Second"), string::utf8(b"url"), test_scenario::ctx(&mut scenario));
            nft_collection::mint_nft(&mut collection, string::utf8(b"NFT #3"), string::utf8(b"Third"), string::utf8(b"url"), test_scenario::ctx(&mut scenario));
            test_scenario::return_shared(collection);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = nft_collection::ENotCreator)]
    fun test_non_creator_mint_fails() {
        let mut scenario = test_scenario::begin(CREATOR);

        test_scenario::next_tx(&mut scenario, CREATOR);
        {
            nft_collection::create_collection(string::utf8(b"Collection"), 100, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, USER);
        {
            let mut collection = test_scenario::take_shared<NFTCollection>(&scenario);
            nft_collection::mint_nft(&mut collection, string::utf8(b"NFT #1"), string::utf8(b"Hack"), string::utf8(b"url"), test_scenario::ctx(&mut scenario));
            test_scenario::return_shared(collection);
        };

        test_scenario::end(scenario);
    }
}

