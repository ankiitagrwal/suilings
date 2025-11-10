// Advanced UID/ID operations: converting between types and using in events.
//
// Your task:
// Use UID and ID in various contexts including events and object references.

module suilings::uid_id3 {
    use sui::object::{Self, UID, ID};
    use sui::event;
    use sui::tx_context::TxContext;
    
    public struct Asset has key {
        id: UID,
        name: vector<u8>,
        owner: address,
    }
    
    public struct TransferEvent has copy, drop {
        asset_id: ID,
        from: address,
        to: address,
    }
    
    public fun create_asset(name: vector<u8>, owner: address, ctx: &mut TxContext): Asset {
        Asset {
            id: object::new(ctx),
            name,
            owner,
        }
    }
    
    public fun get_asset_id(asset: &Asset): ID {
        // TODO: Get the asset's ID
        object::id(asset)
    }
    
    public fun get_asset_id_from_uid(uid: &UID): ID {
        // TODO: Convert UID to ID using object::uid_to_inner
        object::uid_to_inner(uid)
    }
    
    public fun emit_transfer_event(asset: &Asset, from: address, to: address) {
        // TODO: Emit a TransferEvent with the asset's ID
        // Hint: Get asset ID, then event::emit(TransferEvent { ... })
        let asset_id = object::id(asset);
        event::emit(TransferEvent {
            asset_id,
            from,
            to,
        });
    }
    
    public fun get_asset_name(asset: &Asset): vector<u8> {
        asset.name
    }
    
    public fun get_asset_owner(asset: &Asset): address {
        asset.owner
    }
}

#[test_only]
module suilings::uid_id3_tests {
    use suilings::uid_id3;
    use sui::test_scenario;
    use sui::test_utils;
    
    #[test]
    fun test_get_id_from_uid() {
        let addr = @0x13;
        let mut scenario = test_scenario::begin(addr);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let asset = uid_id3::create_asset(b"Gold", addr, ctx);
            let asset_id1 = uid_id3::get_asset_id(&asset);
            let asset_id2 = uid_id3::get_asset_id_from_uid(&asset.id);
            
            assert!(asset_id1 == asset_id2, 0);
            
            test_utils::destroy(asset);
        };
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_emit_event() {
        let addr1 = @0x14;
        let addr2 = @0x15;
        let mut scenario = test_scenario::begin(addr1);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let asset = uid_id3::create_asset(b"Silver", addr1, ctx);
            
            // Event emission will be tested by the runtime
            uid_id3::emit_transfer_event(&asset, addr1, addr2);
            
            test_utils::destroy(asset);
        };
        test_scenario::end(scenario);
    }
}

