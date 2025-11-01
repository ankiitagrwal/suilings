// ==== EVENTS IN SUI ====
// Events allow smart contracts to emit notifications about state changes.
// Events are structs with the 'copy' and 'drop' abilities.
//
// To emit an event:
// - event::emit(event_struct)
//
// Events can be queried off-chain to track contract activity.
//
// Your task:
// Define and emit events for various contract actions.

module suilings::events1 {
    use sui::event;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    
    // TODO: Define a TransferEvent struct with copy, drop abilities
    // Fields: from: address, to: address, amount: u64
    
    // TODO: Define a MintEvent struct with copy, drop abilities
    // Fields: recipient: address, token_id: u64
    
    // TODO: Define a BurnEvent struct with copy, drop abilities
    // Fields: owner: address, token_id: u64
    
    // A simple token for demonstration
    public struct Token has key, store {
        id: UID,
        value: u64,
    }
    
    public fun transfer_tokens(from: address, to: address, amount: u64) {
        // TODO: Emit a TransferEvent with the given parameters
        // Use event::emit()
        abort 0
    }
    
    public fun mint_token(value: u64, ctx: &mut TxContext) {
        let sender = tx_context::sender(ctx);
        let token = Token {
            id: object::new(ctx),
            value,
        };
        
        // TODO: Emit a MintEvent before transferring
        // token_id can be derived from object::uid_to_inner(&token.id)
        
        transfer::transfer(token, sender);
    }
    
    public fun burn_token(token: Token, ctx: &TxContext) {
        let sender = tx_context::sender(ctx);
        let Token { id, value: _ } = token;
        
        // TODO: Emit a BurnEvent before destroying
        // token_id can be derived from object::uid_to_inner(&id)
        
        object::delete(id);
    }
}

#[test_only]
module suilings::events1_tests {
    use suilings::events1;
    use sui::test_scenario;
    
    #[test]
    fun test_transfer_event() {
        let addr1 = @0xA;
        let addr2 = @0xB;
        let mut scenario = test_scenario::begin(addr1);
        
        {
            events1::transfer_tokens(addr1, addr2, 100);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_mint_token() {
        let addr = @0xC;
        let mut scenario = test_scenario::begin(addr);
        
        {
            let ctx = test_scenario::ctx(&mut scenario);
            events1::mint_token(50, ctx);
        };
        
        test_scenario::next_tx(&mut scenario, addr);
        {
            let token = test_scenario::take_from_sender<events1::Token>(&scenario);
            test_scenario::return_to_sender(&scenario, token);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_burn_token() {
        let addr = @0xD;
        let mut scenario = test_scenario::begin(addr);
        
        // First mint a token
        {
            let ctx = test_scenario::ctx(&mut scenario);
            events1::mint_token(75, ctx);
        };
        
        // Then burn it
        test_scenario::next_tx(&mut scenario, addr);
        {
            let token = test_scenario::take_from_sender<events1::Token>(&scenario);
            let ctx = test_scenario::ctx(&mut scenario);
            events1::burn_token(token, ctx);
        };
        
        test_scenario::end(scenario);
    }
}

