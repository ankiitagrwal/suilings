// Enums can have associated data (like Rust's enum variants with data).
// Syntax: public enum EnumName { Variant1(Type1), Variant2(Type2) }
//
// When matching, you destructure the data: Variant1(value) => ...
//
// Your task:
// Work with enums that contain data.

module suilings::enums3 {
    public enum Result<T, E> {
        Ok(T),
        Err(E),
    }
    
    public enum Option<T> {
        Some(T),
        None,
    }
    
    public enum Message {
        Text(vector<u8>),
        Number(u64),
        Empty,
    }
    
    public fun create_ok<T>(value: T): Result<T, u8> {
        // TODO: Return Result::Ok with the value
        abort 0
    }
    
    public fun create_err<E>(error: E): Result<u64, E> {
        // TODO: Return Result::Err with the error
        abort 0
    }
    
    public fun unwrap_ok<T>(result: Result<T, u8>): T {
        // TODO: Use match to extract the value from Ok variant
        // If it's Err, abort with error code 1
        abort 0
    }
    
    public fun get_message_content(msg: Message): vector<u8> {
        // TODO: Use match to extract content from Message
        // Text(content) => return content
        // Number(n) => convert to string (for now, return b"number")
        // Empty => return b""
        b""
    }
}

#[test_only]
module suilings::enums3_tests {
    use suilings::enums3;
    
    #[test]
    fun test_result_ok() {
        let result = enums3::create_ok(42);
        let value = enums3::unwrap_ok(result);
        assert!(value == 42, 0);
    }
    
    #[test]
    #[expected_failure(abort_code = 1)]
    fun test_result_err() {
        let result = enums3::create_err(99);
        let _ = enums3::unwrap_ok(result); // Should abort
    }
    
    #[test]
    fun test_message_text() {
        let msg = enums3::Message::Text(b"Hello");
        let content = enums3::get_message_content(msg);
        assert!(content == b"Hello", 0);
    }
    
    #[test]
    fun test_message_empty() {
        let msg = enums3::Message::Empty;
        let content = enums3::get_message_content(msg);
        assert!(content == b"", 0);
    }
}

