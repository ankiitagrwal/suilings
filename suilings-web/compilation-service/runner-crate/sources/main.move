module suilings::warmup {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::transfer;
    
    public struct TestObject has key {
        id: UID,
        value: u64
    }
    
    public fun create_test(ctx: &mut TxContext) {
        let obj = TestObject {
            id: object::new(ctx),
            value: 42
        };
        transfer::transfer(obj, tx_context::sender(ctx))
    }
    
    #[test]
    fun test_create() {
        use sui::test_scenario;
        let mut scenario = test_scenario::begin(@0xA);
        {
            create_test(test_scenario::ctx(&mut scenario));
        };
        test_scenario::end(scenario);
    }
}