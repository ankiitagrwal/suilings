// Exercise: Sui Objects Basics
//
// Create basic Sui objects with UID and proper abilities (key, store).
//
// Stuck? Check out: https://move-book.com/storage/store-ability.html

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

/// Creates a new coin
public fun create_coin(value: u64, currency: vector<u8>, ctx: &mut TxContext): Coin {
    // TODO: Create a new Coin with object::new(ctx) for the UID
    abort 0
}

/// Creates a new wallet
public fun create_wallet(owner: address, ctx: &mut TxContext): Wallet {
    // TODO: Create a new Wallet with empty coins vector
    abort 0
}

/// Returns the coin's value
public fun coin_value(coin: &Coin): u64 {
    // TODO: Return the coin's value
    0
}

/// Returns the wallet's owner
public fun wallet_owner(wallet: &Wallet): address {
    // TODO: Return the wallet's owner
    @0x0
    }}

#[test_only]
module suilings::objects1_tests {

    use suilings::objects1;
    use sui::test_scenario;

    #[test]
    fun create_coin_works() {
    let addr = @0xA;
    let mut scenario = test_scenario::begin(addr);
    {
    let ctx = test_scenario::ctx(&mut scenario);
    let coin = objects1::create_coin(100, b"USD", ctx);
    assert!(objects1::coin_value(&coin) == 100);
    sui::test_utils::destroy(coin);
    };
    test_scenario::end(scenario);
}

#[test]
    fun create_wallet_works() {
        let addr = @0xB;
        let mut scenario = test_scenario::begin(addr);
        {
        let ctx = test_scenario::ctx(&mut scenario);
        let wallet = objects1::create_wallet(addr, ctx);
        assert!(objects1::wallet_owner(&wallet) == addr);
        sui::test_utils::destroy(wallet);
        };
        test_scenario::end(scenario);
}

}