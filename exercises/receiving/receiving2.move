// Exercise: Receiving Multiple Objects
//
// Handle multiple objects in entry functions.
//
// Stuck? Check out: https://move-book.com/storage/transfer-to-object.html

module suilings::receiving2 {
use sui::object::{Self, UID};
use sui::transfer;
use sui::tx_context::{Self, TxContext};

/// Coin with a value
public struct Coin has key, store {
    id: UID,
    value: u64,
}

/// Token with symbol and amount
public struct Token has key, store {
    id: UID,
    symbol: vector<u8>,
    amount: u64,
}

/// Creates a new coin
public fun create_coin(value: u64, ctx: &mut TxContext): Coin {
    Coin {
    id: object::new(ctx),
    value,
}
}

/// Creates a new token
    public fun create_token(symbol: vector<u8>, amount: u64, ctx: &mut TxContext): Token {
        Token {
        id: object::new(ctx),
        symbol,
        amount,
}
}

/// Swaps two assets and transfers them to a recipient
    public fun swap_assets(coin: Coin, token: Token, recipient: address) {
// TODO: Transfer both coin and token to recipient
}

/// Combines two coins into one
    public fun combine_assets(coin1: Coin, coin2: Coin, ctx: &mut TxContext) {
// TODO: Create a new coin with the sum of both values
// Then transfer it to the sender
}

/// Returns the coin's value
    public fun coin_value(coin: &Coin): u64 {
        coin.value
        }}

#[test_only]
module suilings::receiving2_tests {

use suilings::receiving2;
use sui::test_scenario;
use sui::test_utils;

#[test]
    fun swap_assets_works() {
        let sender = @0x23;
        let recipient = @0x24;
        let mut scenario = test_scenario::begin(sender);
        {
        let ctx = test_scenario::ctx(&mut scenario);
        let coin = receiving2::create_coin(100, ctx);
        let token = receiving2::create_token(b"SUI", 50, ctx);

        receiving2::swap_assets(coin, token, recipient);
        };
        test_scenario::end(scenario);
}

    #[test]
    fun combine_assets_works() {
        let addr = @0x25;
        let mut scenario = test_scenario::begin(addr);
        {
        let ctx = test_scenario::ctx(&mut scenario);
        let coin1 = receiving2::create_coin(30, ctx);
        let coin2 = receiving2::create_coin(70, ctx);

        receiving2::combine_assets(coin1, coin2, ctx);
// Combined coin is transferred to sender
        };
        test_scenario::end(scenario);
}

}