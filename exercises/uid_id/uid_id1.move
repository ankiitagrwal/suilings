// Exercise: UID and ID Basics
//
// Learn to work with UID (Unique Identifier) and ID types in Sui.
//
// Stuck? Check out: https://move-book.com/storage/uid-and-id.html

module suilings::uid_id1 {
use sui::object::{Self, UID, ID};
use sui::tx_context::TxContext;

/// Token with UID, symbol, and supply
public struct Token has key {
    id: UID,
    symbol: vector<u8>,
    supply: u64,
}

/// Creates a new token
public fun create_token(symbol: vector<u8>, supply: u64, ctx: &mut TxContext): Token {
    Token {
    id: object::new(ctx),
    symbol,
    supply,
}
}

/// Returns the token's ID
    public fun token_id(token: &Token): ID {
// TODO: Convert the token's UID to an ID
// Use object::id() or object::uid_to_inner()
        abort 0
}

/// Returns the token's symbol
    public fun token_symbol(token: &Token): vector<u8> {
// TODO: Return the token's symbol
        b""
}

/// Returns the token's supply
    public fun token_supply(token: &Token): u64 {
// TODO: Return the token's supply
        0
}

/// Compares two IDs for equality
    public fun compare_ids(id1: ID, id2: ID): bool {
// TODO: Compare two IDs for equality
        false
        }}

#[test_only]
module suilings::uid_id1_tests {

use suilings::uid_id1;
use sui::test_scenario;
use sui::test_utils;

#[test]
    fun get_id_works() {
        let addr = @0xF;
        let mut scenario = test_scenario::begin(addr);
        {
        let ctx = test_scenario::ctx(&mut scenario);
        let token = uid_id1::create_token(b"SUI", 1000000, ctx);
        let token_id = uid_id1::token_id(&token);

// ID should be valid (non-zero)
        assert!(uid_id1::compare_ids(token_id, token_id) == true);

        test_utils::destroy(token);
        };
        test_scenario::end(scenario);
}

    #[test]
    fun compare_ids_works() {
        let addr = @0x10;
        let mut scenario = test_scenario::begin(addr);
        {
        let ctx = test_scenario::ctx(&mut scenario);
        let token1 = uid_id1::create_token(b"TOKEN1", 100, ctx);
        let token2 = uid_id1::create_token(b"TOKEN2", 200, ctx);

        let id1 = uid_id1::token_id(&token1);
        let id2 = uid_id1::token_id(&token2);

        assert!(uid_id1::compare_ids(id1, id1) == true);
        assert!(uid_id1::compare_ids(id1, id2) == false);

        test_utils::destroy(token1);
        test_utils::destroy(token2);
        };
        test_scenario::end(scenario);
}

}