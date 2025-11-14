// UID (Unique Identifier) and ID are fundamental types in Sui.
// - UID: Internal unique identifier for objects (used in struct definitions)
// - ID: Public identifier that can be used to reference objects
// - object::id(obj) converts UID to ID
// - object::uid_to_inner(&uid) converts UID to ID
//
// Your task:
// Learn to work with UID and ID types.

module suilings::uid_id1 {
    use sui::object::{Self, UID, ID};
    use sui::tx_context::TxContext;
    
    public struct Token has key {
        id: UID,
        symbol: vector<u8>,
        supply: u64,
    }
    
    public fun create_token(symbol: vector<u8>, supply: u64, ctx: &mut TxContext): Token {
        Token {
            id: object::new(ctx),
            symbol,
            supply,
        }
    }
    
    public fun get_token_id(token: &Token): ID {
        // TODO: Convert the token's UID to an ID
       
    }
    
    public fun get_token_symbol(token: &Token): vector<u8> {
        
    }
    
    public fun get_token_supply(token: &Token): u64 {
       
    }
    
    public fun compare_ids(id1: ID, id2: ID): bool {
        // TODO: Compare two IDs for equality
       
    }
}

#[test_only]
module suilings::uid_id1_tests {
    use suilings::uid_id1;
    use sui::test_scenario;
    use sui::test_utils;
    
    #[test]
    fun test_get_id() {
        let addr = @0xF;
        let mut scenario = test_scenario::begin(addr);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let token = uid_id1::create_token(b"SUI", 1000000, ctx);
            let token_id = uid_id1::get_token_id(&token);
            
            // ID should be valid (non-zero)
            assert!(uid_id1::compare_ids(token_id, token_id) == true, 0);
            
            test_utils::destroy(token);
        };
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_compare_ids() {
        let addr = @0x10;
        let mut scenario = test_scenario::begin(addr);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let token1 = uid_id1::create_token(b"TOKEN1", 100, ctx);
            let token2 = uid_id1::create_token(b"TOKEN2", 200, ctx);
            
            let id1 = uid_id1::get_token_id(&token1);
            let id2 = uid_id1::get_token_id(&token2);
            
            assert!(uid_id1::compare_ids(id1, id1) == true, 0);
            assert!(uid_id1::compare_ids(id1, id2) == false, 1);
            
            test_utils::destroy(token1);
            test_utils::destroy(token2);
        };
        test_scenario::end(scenario);
    }
}

