// ==== SUI OBJECTS - BASICS ====
// In Sui, objects are the fundamental unit of storage.
// Objects have unique IDs and can be owned by addresses or shared.
//
// Key abilities for Sui objects:
// - key: can be used as a key in global storage (required for objects)
// - store: can be stored inside other structs
//
// UID is a unique identifier for objects.
// Use object::new(ctx) to create a new UID.
//
// Your task:
// Create basic Sui objects with proper abilities.

module suilings::objects1 {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    
    // TODO: Define a Coin struct with:
    // - id: UID
    // - value: u64
    // - currency: vector<u8>
    // Add the 'key' ability (required for objects)
    // Add the 'store' ability (so it can be stored in other objects)
    
    // TODO: Define a Wallet struct with:
    // - id: UID
    // - owner: address
    // - coins: vector<Coin>
    // Add 'key' ability
    
    public fun create_coin(value: u64, currency: vector<u8>, ctx: &mut TxContext): Coin {
        // TODO: Create a new Coin with object::new(ctx) for the UID
        abort 0
    }
    
    public fun create_wallet(owner: address, ctx: &mut TxContext): Wallet {
        // TODO: Create a new Wallet with empty coins vector
        abort 0
    }
    
    public fun get_coin_value(coin: &Coin): u64 {
        // TODO: Return the coin's value
        0
    }
    
    public fun get_wallet_owner(wallet: &Wallet): address {
        // TODO: Return the wallet's owner
        @0x0
    }
}

#[test_only]
module suilings::objects1_tests {
    use suilings::objects1;
    use sui::test_scenario;
    
    #[test]
    fun test_create_coin() {
        let addr = @0xA;
        let mut scenario = test_scenario::begin(addr);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let coin = objects1::create_coin(100, b"USD", ctx);
            assert!(objects1::get_coin_value(&coin) == 100, 0);
            sui::test_utils::destroy(coin);
        };
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_create_wallet() {
        let addr = @0xB;
        let mut scenario = test_scenario::begin(addr);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let wallet = objects1::create_wallet(addr, ctx);
            assert!(objects1::get_wallet_owner(&wallet) == addr, 0);
            sui::test_utils::destroy(wallet);
        };
        test_scenario::end(scenario);
    }
}

