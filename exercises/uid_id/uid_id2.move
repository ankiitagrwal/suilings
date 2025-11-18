// Exercise: UID/ID in Object Relationships
//
// Store and retrieve object IDs in relationships between objects.
//
// Stuck? Check out: https://move-book.com/storage/uid-and-id.html

module suilings::uid_id2 {
use sui::object::{Self, UID, ID};
use sui::tx_context::TxContext;
use std::vector;

/// Wallet that tracks token IDs
public struct Wallet has key {
    id: UID,
    owner: address,
    token_ids: vector<ID>,
}

/// Token with symbol and value
public struct Token has key, store {
    id: UID,
    symbol: vector<u8>,
    value: u64,
}

/// Creates a new wallet
public fun create_wallet(owner: address, ctx: &mut TxContext): Wallet {
    Wallet {
    id: object::new(ctx),
    owner,
    token_ids: vector::empty<ID>(),
}
}

/// Creates a new token
    public fun create_token(symbol: vector<u8>, value: u64, ctx: &mut TxContext): Token {
        Token {
        id: object::new(ctx),
        symbol,
        value,
}
}

/// Adds a token's ID to the wallet
    public fun add_token_id(wallet: &mut Wallet, token: &Token) {
// TODO: Add the token's ID to the wallet's token_ids vector
}

/// Returns the number of token IDs in the wallet
    public fun token_count(wallet: &Wallet): u64 {
// TODO: Return the number of token IDs in the wallet
        0
}

/// Checks if a token ID exists in the wallet
    public fun has_token_id(wallet: &Wallet, token_id: ID): bool {
// TODO: Check if the token_id exists in wallet's token_ids
        false
}

/// Returns the wallet's owner
    public fun wallet_owner(wallet: &Wallet): address {
        wallet.owner
        }}

#[test_only]
module suilings::uid_id2_tests {

use suilings::uid_id2;
use sui::object::ID;
use sui::test_scenario;
use sui::test_utils;

#[test]
    fun add_token_id_works() {
        let addr = @0x11;
        let mut scenario = test_scenario::begin(addr);
        {
        let ctx = test_scenario::ctx(&mut scenario);
        let mut wallet = uid_id2::create_wallet(addr, ctx);
        let token = uid_id2::create_token(b"SUI", 100, ctx);
        let token_id = object::id(&token);

        uid_id2::add_token_id(&mut wallet, &token);

        assert!(uid_id2::token_count(&wallet) == 1);
        assert!(uid_id2::has_token_id(&wallet, token_id) == true);

        test_utils::destroy(token);
        test_utils::destroy(wallet);
        };
        test_scenario::end(scenario);
}

    #[test]
    fun has_token_id_works() {
        let addr = @0x12;
        let mut scenario = test_scenario::begin(addr);
        {
        let ctx = test_scenario::ctx(&mut scenario);
        let mut wallet = uid_id2::create_wallet(addr, ctx);
        let token1 = uid_id2::create_token(b"TOKEN1", 50, ctx);
        let token2 = uid_id2::create_token(b"TOKEN2", 75, ctx);
        let token1_id = object::id(&token1);
        let token2_id = object::id(&token2);

        uid_id2::add_token_id(&mut wallet, &token1);

        assert!(uid_id2::has_token_id(&wallet, token1_id) == true);
        assert!(uid_id2::has_token_id(&wallet, token2_id) == false);

        test_utils::destroy(token1);
        test_utils::destroy(token2);
        test_utils::destroy(wallet);
        };
        test_scenario::end(scenario);
}

}