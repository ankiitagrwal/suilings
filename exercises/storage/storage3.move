// Exercise: Storage with Key-Value Patterns
//
// Work with key-value storage patterns using vectors for flexible data storage.
//
// Stuck? Check out: https://move-book.com/storage/storage-functions.html

module suilings::storage3;
use sui::object::{Self, UID};
use sui::tx_context::TxContext;
use std::vector;
    
/// Data store that holds key-value pairs
public struct DataStore has key {
    id: UID,
    keys: vector<vector<u8>>,
    values: vector<DataValue>,
}
    
/// Value stored in the data store
public struct DataValue has store {
    value: u64,
    label: vector<u8>,
}
    
/// Creates a new data store
public fun create_store(ctx: &mut TxContext): DataStore {
    DataStore {
        id: object::new(ctx),
        keys: vector::empty<vector<u8>>(),
        values: vector::empty<DataValue>(),
    }
}
    
/// Creates a new data value
public fun create_value(value: u64, label: vector<u8>): DataValue {
    DataValue {
        value,
        label,
    }
}
    
/// Adds a key-value pair to the store
public fun add_field(store: &mut DataStore, key: vector<u8>, value: DataValue) {
    // TODO: Add key and value to respective vectors
}
    
/// Returns the number of fields in the store
public fun field_count(store: &DataStore): u64 {
    // TODO: Return the number of fields (should be same for keys and values)
    0
}
    
/// Returns the value from a DataValue
public fun value(data: &DataValue): u64 {
    // TODO: Return the value from DataValue
    0
}
    
/// Returns the label from a DataValue
public fun label(data: &DataValue): vector<u8> {
   // TODO: Return the label from DataValue
   b""
}

#[test_only]
module suilings::storage3_tests;

use suilings::storage3;
use sui::test_scenario;
use sui::test_utils;

#[test]
fun add_fields_works() {
    let addr = @0xE;
    let mut scenario = test_scenario::begin(addr);
    {
        let ctx = test_scenario::ctx(&mut scenario);
        let mut store = storage3::create_store(ctx);
        let value1 = storage3::create_value(100, b"test1");
        let value2 = storage3::create_value(200, b"test2");
        
        storage3::add_field(&mut store, b"key1", value1);
        storage3::add_field(&mut store, b"key2", value2);
        
        assert!(storage3::field_count(&store) == 2);
        
        test_utils::destroy(store);
    };
    test_scenario::end(scenario);
}
