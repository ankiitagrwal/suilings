// Exercise: Collections - ObjectBag (Mixed Asset Vault)
//
// Build a vault that stores different types of objects using ObjectBag.
// ObjectBag combines Bag's heterogeneity with ObjectTable's object storage.
//
// Stuck? Check out: https://move-book.com/programmability/collections.html

#[allow(duplicate_alias)]
module suilings::asset_vault {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::object_bag::{Self, ObjectBag};
    use std::string::String;

    // Error constants
    const EAssetNotFound: u64 = 1;
    const ENotOwner: u64 = 2;
    const EAssetAlreadyExists: u64 = 3;
    const EVaultLocked: u64 = 4;

    /// A generic asset that can be stored in the vault
    public struct Asset<T: store> has key, store {
        id: UID,
        data: T,
    }

    /// A vault that can store different types of objects using ObjectBag
    public struct AssetVault has key {
        id: UID,
        /// ObjectBag storing different asset types by name (String -> Asset<T>)
        assets: ObjectBag,
        /// Vault owner
        owner: address,
        /// Whether the vault is locked (no withdrawals)
        is_locked: bool,
    }

    /// Creates a new asset vault
    ///
    /// Build a vault that stores different types of objects using ObjectBag.
    /// ObjectBag combines Bag's heterogeneity with ObjectTable's object storage.
    ///
    /// Implementation Requirements:
    /// - Create an empty ObjectBag using object_bag::new()
    /// - Store the creator as owner using tx_context::sender()
    /// - Create AssetVault with: id, assets (empty), owner, is_locked (false)
    /// - Transfer the vault to owner using transfer::transfer()
    public fun create_vault(ctx: &mut TxContext) {
        // Your implementation here
    }

    /// Deposits an asset into the vault
    ///
    /// Store a new object in the vault with a unique identifier.
    /// Like putting an item in a safe deposit box.
    ///
    /// Security Validations:
    /// - Only owner can deposit (abort with ENotOwner)
    /// - Asset name must not already exist (abort with EAssetAlreadyExists)
    ///
    /// Implementation:
    /// - Verify sender is owner
    /// - Verify asset_name doesn't exist using object_bag::contains()
    /// - Wrap data in Asset struct with new UID
    /// - Add to ObjectBag: object_bag::add(&mut vault.assets, asset_name, asset)
    public fun deposit<T: store>(
        vault: &mut AssetVault,
        asset_name: String,
        data: T,
        ctx: &mut TxContext,
    ) {
        // Your implementation here
        // REMOVE this temporary code after implementation:
        let temp_asset = Asset { id: object::new(ctx), data };
        transfer::public_transfer(temp_asset, vault.owner);
    }

    /// Withdraws an asset from the vault
    ///
    /// Remove an object from the vault and return its data.
    /// Like retrieving an item from a safe.
    ///
    /// Security Requirements:
    /// - Only owner can withdraw (abort with ENotOwner)
    /// - Vault must not be locked (abort with EVaultLocked)
    /// - Asset must exist (abort with EAssetNotFound)
    ///
    /// Implementation:
    /// - Verify sender is owner
    /// - Verify vault is not locked
    /// - Verify asset exists using object_bag::contains()
    /// - Remove asset: object_bag::remove(&mut vault.assets, asset_name)
    /// - Unpack Asset struct to get data and delete UID
    /// - Return the data T
    public fun withdraw<T: store>(
        vault: &mut AssetVault,
        asset_name: String,
        ctx: &TxContext,
    ): T {
        // Your implementation here
        abort 0 // Placeholder - replace with actual implementation
    }

    /// Locks the vault to prevent withdrawals
    ///
    /// Lock the vault so no assets can be withdrawn.
    /// Like locking a safe - can still see contents but can't remove.
    ///
    /// Security Requirements:
    /// - Only owner can lock (abort with ENotOwner)
    ///
    /// Implementation:
    /// - Verify sender is owner
    /// - Set vault.is_locked = true
    public fun lock_vault(vault: &mut AssetVault, ctx: &TxContext) {
        // Your implementation here
    }

    /// Unlocks the vault to allow withdrawals
    ///
    /// Unlock the vault to resume normal operations.
    /// Like unlocking a safe with the key.
    ///
    /// Security Requirements:
    /// - Only owner can unlock (abort with ENotOwner)
    ///
    /// Implementation:
    /// - Verify sender is owner
    /// - Set vault.is_locked = false
    public fun unlock_vault(vault: &mut AssetVault, ctx: &TxContext) {
        // Your implementation here
    }

    /// Checks if an asset exists in the vault
    ///
    /// See if a specific asset is stored in the vault.
    /// Like checking if a safe deposit box has a specific item.
    ///
    /// Implementation:
    /// - Return object_bag::contains(&vault.assets, asset_name)
    public fun has_asset(vault: &AssetVault, asset_name: String): bool {
        object_bag::contains<String>(&vault.assets, asset_name)
    }

    /// Borrows an immutable reference to an asset
    ///
    /// View asset data without removing it from the vault.
    /// Like looking at an item through a window without taking it out.
    ///
    /// Security Requirements:
    /// - Asset must exist (abort with EAssetNotFound)
    ///
    /// Implementation:
    /// - Verify asset exists using object_bag::contains()
    /// - Borrow asset: object_bag::borrow(&vault.assets, asset_name)
    /// - Return reference to asset.data
    public fun borrow_asset<T: store>(vault: &AssetVault, asset_name: String): &T {
        assert!(object_bag::contains<String>(&vault.assets, asset_name), EAssetNotFound);
        let asset = object_bag::borrow<String, Asset<T>>(&vault.assets, asset_name);
        &asset.data
    }

    // ==================== Getter Functions ====================

    public fun owner(vault: &AssetVault): address {
        vault.owner
    }

    public fun is_locked(vault: &AssetVault): bool {
        vault.is_locked
    }

    public fun asset_count(vault: &AssetVault): u64 {
        object_bag::length(&vault.assets)
    }
}

#[test_only]
module suilings::asset_vault_tests {
    use suilings::asset_vault::{Self, AssetVault};
    use sui::test_scenario;
    use std::string;

    const OWNER: address = @0xA11CE;
    const OTHER: address = @0xB0B;

    // Mock data types for testing
    public struct Document has store {
        title: vector<u8>,
        content: vector<u8>,
    }

    public struct Certificate has store {
        issuer: vector<u8>,
        year: u64,
    }

    #[test]
    fun test_create_vault() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            asset_vault::create_vault(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let vault = test_scenario::take_from_sender<AssetVault>(&scenario);
            assert!(asset_vault::owner(&vault) == OWNER, 0);
            assert!(asset_vault::asset_count(&vault) == 0, 1);
            assert!(!asset_vault::is_locked(&vault), 2);
            test_scenario::return_to_sender(&scenario, vault);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_deposit_and_has_asset() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            asset_vault::create_vault(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut vault = test_scenario::take_from_sender<AssetVault>(&scenario);
            let doc = Document { title: b"Title", content: b"Content" };
            asset_vault::deposit(&mut vault, string::utf8(b"doc1"), doc, test_scenario::ctx(&mut scenario));
            
            assert!(asset_vault::asset_count(&vault) == 1, 0);
            assert!(asset_vault::has_asset(&vault, string::utf8(b"doc1")), 1);
            test_scenario::return_to_sender(&scenario, vault);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_multiple_asset_types() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            asset_vault::create_vault(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut vault = test_scenario::take_from_sender<AssetVault>(&scenario);
            let doc = Document { title: b"Contract", content: b"Agreement" };
            let cert = Certificate { issuer: b"University", year: 2024 };
            
            asset_vault::deposit(&mut vault, string::utf8(b"doc1"), doc, test_scenario::ctx(&mut scenario));
            asset_vault::deposit(&mut vault, string::utf8(b"cert1"), cert, test_scenario::ctx(&mut scenario));
            
            assert!(asset_vault::asset_count(&vault) == 2, 0);
            assert!(asset_vault::has_asset(&vault, string::utf8(b"doc1")), 1);
            assert!(asset_vault::has_asset(&vault, string::utf8(b"cert1")), 2);
            test_scenario::return_to_sender(&scenario, vault);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_withdraw() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            asset_vault::create_vault(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut vault = test_scenario::take_from_sender<AssetVault>(&scenario);
            let doc = Document { title: b"Title", content: b"Content" };
            asset_vault::deposit(&mut vault, string::utf8(b"doc1"), doc, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, vault);
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut vault = test_scenario::take_from_sender<AssetVault>(&scenario);
            let doc = asset_vault::withdraw<Document>(&mut vault, string::utf8(b"doc1"), test_scenario::ctx(&mut scenario));
            
            assert!(asset_vault::asset_count(&vault) == 0, 0);
            let Document { title: _, content: _ } = doc;
            test_scenario::return_to_sender(&scenario, vault);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_lock_unlock() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            asset_vault::create_vault(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut vault = test_scenario::take_from_sender<AssetVault>(&scenario);
            asset_vault::lock_vault(&mut vault, test_scenario::ctx(&mut scenario));
            assert!(asset_vault::is_locked(&vault), 0);
            test_scenario::return_to_sender(&scenario, vault);
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut vault = test_scenario::take_from_sender<AssetVault>(&scenario);
            asset_vault::unlock_vault(&mut vault, test_scenario::ctx(&mut scenario));
            assert!(!asset_vault::is_locked(&vault), 0);
            test_scenario::return_to_sender(&scenario, vault);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_borrow_asset() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            asset_vault::create_vault(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut vault = test_scenario::take_from_sender<AssetVault>(&scenario);
            let cert = Certificate { issuer: b"MIT", year: 2024 };
            asset_vault::deposit(&mut vault, string::utf8(b"cert1"), cert, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, vault);
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let vault = test_scenario::take_from_sender<AssetVault>(&scenario);
            let cert_ref = asset_vault::borrow_asset<Certificate>(&vault, string::utf8(b"cert1"));
            assert!(cert_ref.year == 2024, 0);
            test_scenario::return_to_sender(&scenario, vault);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = asset_vault::EVaultLocked)]
    fun test_withdraw_locked_vault_fails() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            asset_vault::create_vault(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut vault = test_scenario::take_from_sender<AssetVault>(&scenario);
            let doc = Document { title: b"Title", content: b"Content" };
            asset_vault::deposit(&mut vault, string::utf8(b"doc1"), doc, test_scenario::ctx(&mut scenario));
            asset_vault::lock_vault(&mut vault, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, vault);
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut vault = test_scenario::take_from_sender<AssetVault>(&scenario);
            let doc = asset_vault::withdraw<Document>(&mut vault, string::utf8(b"doc1"), test_scenario::ctx(&mut scenario));
            let Document { title: _, content: _ } = doc;
            test_scenario::return_to_sender(&scenario, vault);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = asset_vault::EAssetAlreadyExists)]
    fun test_duplicate_asset_name_fails() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            asset_vault::create_vault(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut vault = test_scenario::take_from_sender<AssetVault>(&scenario);
            let doc1 = Document { title: b"Doc1", content: b"Content1" };
            let doc2 = Document { title: b"Doc2", content: b"Content2" };
            
            asset_vault::deposit(&mut vault, string::utf8(b"doc"), doc1, test_scenario::ctx(&mut scenario));
            asset_vault::deposit(&mut vault, string::utf8(b"doc"), doc2, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender(&scenario, vault);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = asset_vault::ENotOwner)]
    fun test_non_owner_deposit_fails() {
        let mut scenario = test_scenario::begin(OWNER);

        test_scenario::next_tx(&mut scenario, OWNER);
        {
            asset_vault::create_vault(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, OTHER);
        {
            let mut vault = test_scenario::take_from_address<AssetVault>(&scenario, OWNER);
            let doc = Document { title: b"Hack", content: b"Attempt" };
            asset_vault::deposit(&mut vault, string::utf8(b"doc1"), doc, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_address(OWNER, vault);
        };

        test_scenario::end(scenario);
    }
}

