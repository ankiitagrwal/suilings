// Exercise: Advanced UID/ID Operations
//
// Use UID and ID in various contexts including events and conversions.
//
// Stuck? Check out: https://move-book.com/storage/uid-and-id.html

module suilings::uid_id3;
use sui::object::{Self, UID, ID};
use sui::event;
use sui::tx_context::TxContext;
    
    /// Asset with name and owner
public struct Asset has key {
    id: UID,
    name: vector<u8>,
    owner: address,
}
    
    /// Event emitted when an asset is transferred
public struct TransferEvent has copy, drop {
    asset_id: ID,
    from: address,
    to: address,
}
    
    /// Creates a new asset
public fun create_asset(name: vector<u8>, owner: address, ctx: &mut TxContext): Asset {
    Asset {
        id: object::new(ctx),
        name,
        owner,
    }
}
    
    /// Returns the asset's ID
public fun asset_id(asset: &Asset): ID {
        // TODO: Get the asset's ID
    abort 0
}
    
    /// Converts a UID to an ID
public fun asset_id_from_uid(uid: &UID): ID {
        // TODO: Convert UID to ID using object::uid_to_inner
    abort 0
}
    
    /// Emits a transfer event
public fun emit_transfer_event(asset: &Asset, from: address, to: address) {
        // TODO: Emit a TransferEvent with the asset's ID
}
    
    /// Returns the asset's name
public fun asset_name(asset: &Asset): vector<u8> {
    asset.name
}
    
    /// Returns the asset's owner
public fun asset_owner(asset: &Asset): address {
    asset.owner
}
    
#[test]
fun get_id_from_uid_works() {
    use sui::test_scenario;
    use sui::test_utils;
        
    let addr = @0x13;
    let mut scenario = test_scenario::begin(addr);
    {
        let ctx = test_scenario::ctx(&mut scenario);
        let asset = create_asset(b"Gold", addr, ctx);
        let asset_id1 = asset_id(&asset);
        let asset_id2 = asset_id_from_uid(&asset.id);
            
        assert!(asset_id1 == asset_id2);
            
        test_utils::destroy(asset);
    };
    test_scenario::end(scenario);
}
    
#[test]
fun emit_event_works() {
    use sui::test_scenario;
    use sui::test_utils;
        
    let addr1 = @0x14;
    let addr2 = @0x15;
    let mut scenario = test_scenario::begin(addr1);
    {
        let ctx = test_scenario::ctx(&mut scenario);
        let asset = create_asset(b"Silver", addr1, ctx);
            
            // Event emission will be tested by the runtime
        emit_transfer_event(&asset, addr1, addr2);
            
        test_utils::destroy(asset);
    };
    test_scenario::end(scenario);
}
