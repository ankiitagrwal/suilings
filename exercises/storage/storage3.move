// Storage with maps: storing and retrieving values by key using vectors.
//
// In Move, we can simulate key-value storage using vectors and helper functions.
//
// Your task:
// Work with key-value storage patterns for flexible data storage.

module suilings::storage3 {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use std::vector;
    
    public struct DataStore has key {
        id: UID,
        keys: vector<vector<u8>>,
        values: vector<DataValue>,
    }
    
    public struct DataValue has store {
        value: u64,
        label: vector<u8>,
    }
    
    public fun create_store(ctx: &mut TxContext): DataStore {
        DataStore {
            id: object::new(ctx),
            keys: vector::empty<vector<u8>>(),
            values: vector::empty<DataValue>(),
        }
    }
    
    public fun create_value(value: u64, label: vector<u8>): DataValue {
        DataValue {
            value,
            label,
        }
    }
    
    public fun add_field(store: &mut DataStore, key: vector<u8>, value: DataValue) {
        // TODO: Add key and value to respective vectors
        // Hint: vector::push_back for both keys and values
        vector::push_back(&mut store.keys, key);
        vector::push_back(&mut store.values, value);
    }
    
    public fun get_field_count(store: &DataStore): u64 {
        // TODO: Return the number of fields (should be same for keys and values)
        vector::length(&store.keys)
    }
    
    public fun get_value(data: &DataValue): u64 {
        data.value
    }
    
    public fun get_label(data: &DataValue): String {
        data.label
    }
}

#[test_only]
module suilings::storage3_tests {
    use suilings::storage3;
    use sui::test_scenario;
    use sui::test_utils;
    
    #[test]
    fun test_add_fields() {
        let addr = @0xE;
        let mut scenario = test_scenario::begin(addr);
        {
            let ctx = test_scenario::ctx(&mut scenario);
            let mut store = storage3::create_store(ctx);
            let value1 = storage3::create_value(100, b"test1");
            let value2 = storage3::create_value(200, b"test2");
            
            storage3::add_field(&mut store, b"key1", value1);
            storage3::add_field(&mut store, b"key2", value2);
            
            assert!(storage3::get_field_count(&store) == 2, 0);
            
            test_utils::destroy(store);
        };
        test_scenario::end(scenario);
    }
}

