// Receiving objects in Sui entry functions.
// Entry functions can receive objects as parameters.
// Objects passed to entry functions are consumed (moved).
//
// Syntax: public entry fun function_name(obj: ObjectType, ctx: &mut TxContext)
//
// Your task:
// Create entry functions that receive and process objects.

module suilings::receiving1 {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    
    public struct Coin has key, store {
        id: UID,
        value: u64,
    }
    
    public fun create_coin(value: u64, ctx: &mut TxContext): Coin {
        Coin {
            id: object::new(ctx),
            value,
        }
    }
    
    public entry fun receive_coin(coin: Coin, recipient: address) {
        // TODO: Transfer the coin to the recipient
        // Hint: transfer::transfer(coin, recipient)
        transfer::transfer(coin, recipient);
    }
    
    public entry fun burn_coin(coin: Coin) {
        // TODO: Destroy the coin (it will be dropped at end of function)
        // Just let it go out of scope, or explicitly drop if needed
        let Coin { id: _, value: _ } = coin;
    }
    
    public fun get_coin_value(coin: &Coin): u64 {
        coin.value
    }
}

#[test_only]
module suilings::receiving1_tests {
    use suilings::receiving1;
    use sui::test_scenario;
    use sui::test_utils;
    
    #[test]
    fun test_receive_coin() {
        let sender = @0x20;
        let recipient = @0x21;
        let mut scenario = test_scenario::begin(sender);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let coin = receiving1::create_coin(100, ctx);
            
            // In tests, we simulate entry function calls
            receiving1::receive_coin(coin, recipient);
            
            // Verify coin was transferred (in real scenario, check recipient's balance)
        };
        test_scenario::end(scenario);
    }
    
    #[test]
    fun test_burn_coin() {
        let addr = @0x22;
        let mut scenario = test_scenario::begin(addr);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let coin = receiving1::create_coin(50, ctx);
            
            receiving1::burn_coin(coin);
            // Coin is destroyed
        };
        test_scenario::end(scenario);
    }
}

