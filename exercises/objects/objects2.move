// ==== SUI OBJECTS - TRANSFER AND OWNERSHIP ====
// Sui objects can be transferred between addresses.
//
// Transfer functions:
// - transfer::transfer(obj, recipient) - transfer owned object
// - transfer::share_object(obj) - make object shared (anyone can use)
// - transfer::freeze_object(obj) - make object immutable
//
// TxContext functions:
// - tx_context::sender(ctx) - get the transaction sender
//
// Your task:
// Implement object transfers and ownership changes.

module suilings::objects2 {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    
    // A simple NFT
    public struct NFT has key, store {
        id: UID,
        name: vector<u8>,
        creator: address,
    }
    
    // A collectible card game card
    public struct Card has key, store {
        id: UID,
        power: u64,
        rarity: u8,
    }
    
    // A shared counter that anyone can increment
    public struct Counter has key {
        id: UID,
        value: u64,
    }
    
    public fun mint_nft(name: vector<u8>, ctx: &mut TxContext) {
        // TODO: Create an NFT with the sender as creator
        // Then transfer it to the sender using transfer::transfer
        abort 0
    }
    
    public fun transfer_nft(nft: NFT, recipient: address) {
        // TODO: Transfer the NFT to the recipient
        abort 0
    }
    
    public fun create_shared_counter(ctx: &mut TxContext) {
        // TODO: Create a Counter with value 0
        // Then share it using transfer::share_object
        abort 0
    }
    
    public fun increment_counter(counter: &mut Counter) {
        // TODO: Increment the counter's value by 1
    }
    
    public fun freeze_card(card: Card) {
        // TODO: Freeze the card so it becomes immutable
        // Use transfer::freeze_object
        abort 0
    }
    
    public fun get_counter_value(counter: &Counter): u64 {
        counter.value
    }
}

#[test_only]
module suilings::objects2_tests {
    use suilings::objects2;
    use sui::test_scenario;
    
    #[test]
    fun test_mint_and_transfer_nft() {
        let addr1 = @0xA;
        let addr2 = @0xB;
        let mut scenario = test_scenario::begin(addr1);
        
        // Mint NFT
        {
            let ctx = test_scenario::ctx(&mut scenario);
            objects2::mint_nft(b"Cool NFT", ctx);
        };
        
        // Check addr1 owns it
        test_scenario::next_tx(&mut scenario, addr1);
        {
            let nft = test_scenario::take_from_sender<objects2::NFT>(&scenario);
            
            // Transfer to addr2
            objects2::transfer_nft(nft, addr2);
        };
        
        // Check addr2 owns it
        test_scenario::next_tx(&mut scenario, addr2);
        {
            assert!(test_scenario::has_most_recent_for_address<objects2::NFT>(addr2), 0);
        };
        
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_shared_counter() {
        let addr = @0xC;
        let mut scenario = test_scenario::begin(addr);
        
        // Create shared counter
        {
            let ctx = test_scenario::ctx(&mut scenario);
            objects2::create_shared_counter(ctx);
        };
        
        // Increment it
        test_scenario::next_tx(&mut scenario, addr);
        {
            let mut counter = test_scenario::take_shared<objects2::Counter>(&scenario);
            objects2::increment_counter(&mut counter);
            assert!(objects2::get_counter_value(&counter) == 1, 0);
            
            objects2::increment_counter(&mut counter);
            assert!(objects2::get_counter_value(&counter) == 2, 1);
            
            test_scenario::return_shared(counter);
        };
        
        test_scenario::end(scenario);
    }
}

