// Receiving multiple objects and processing them together.
// Entry functions can receive multiple objects as parameters.
//
// Your task:
// Handle multiple objects in entry functions.

module suilings::receiving2 {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    
    public struct Coin has key, store {
        id: UID,
        value: u64,
    }
    
    public struct Token has key, store {
        id: UID,
        symbol: vector<u8>,
        amount: u64,
    }
    
    public fun create_coin(value: u64, ctx: &mut TxContext): Coin {
        Coin {
            id: object::new(ctx),
            value,
        }
    }
    
    public fun create_token(symbol: vector<u8>, amount: u64, ctx: &mut TxContext): Token {
        Token {
            id: object::new(ctx),
            symbol,
            amount,
        }
    }
    
    public entry fun swap_assets(coin: Coin, token: Token, recipient: address) {
        // TODO: Transfer both coin and token to recipient
        // Hint: transfer::transfer for each object
        transfer::transfer(coin, recipient);
        transfer::transfer(token, recipient);
    }
    
    public entry fun combine_assets(coin1: Coin, coin2: Coin, ctx: &mut TxContext) {
        // TODO: Create a new coin with the sum of both values
        // Then transfer it to the sender
        let total_value = coin1.value + coin2.value;
        let Coin { id: _, value: _ } = coin1;
        let Coin { id: _, value: _ } = coin2;
        let new_coin = Coin {
            id: object::new(ctx),
            value: total_value,
        };
        transfer::transfer(new_coin, tx_context::sender(ctx));
    }
    
    public fun get_coin_value(coin: &Coin): u64 {
        coin.value
    }
}

#[test_only]
module suilings::receiving2_tests {
    use suilings::receiving2;
    use sui::test_scenario;
    use sui::test_utils;
    
    #[test]
    fun test_swap_assets() {
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
    fun test_combine_assets() {
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

