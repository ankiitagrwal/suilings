// Exercise: Enums with Associated Data
//
// Work with enums that contain data, like Result<T, E> and Option<T>.
//
// Stuck? Check out: https://move-book.com/move-basics/enum-and-match.html

module suilings::enums3 {
/// Result type with Ok and Err variants
public enum Result<T, E> has copy, drop {
    Ok(T),
    Err(E),
}

/// Option type with Some and None variants
public enum Option<T> has copy, drop {
    Some(T),
    None,
}

/// Message type with different content variants
public enum Message has copy, drop {
    Text(vector<u8>),
    Number(u64),
    Empty,
}

/// Creates a Result::Ok with the given value
public fun create_ok<T>(value: T): Result<T, u8> {
    // TODO: Return Result::Ok with the value
    abort 0
}

/// Creates a Result::Err with the given error
public fun create_err<E>(error: E): Result<u64, E> {
    // TODO: Return Result::Err with the error
    abort 0
}

const EResultIsErr: u64 = 1;

/// Extracts the value from Result::Ok, aborts if Err
public fun unwrap_ok<T>(result: Result<T, u8>): T {
    // TODO: Use match to extract the value from Ok variant
    // If it's Err, abort with EResultIsErr
    abort 0
}

/// Extracts content from Message enum
public fun message_content(msg: Message): vector<u8> {
    // TODO: Use match to extract content from Message
    // Text(content) => return content
    // Number(_) => return b"number"
    // Empty => return b""
    abort 0
}

#[test]
    fun result_ok_works() {
        let result = create_ok(42);
        let value = unwrap_ok(result);
        assert!(value == 42);
}

    #[test, expected_failure(abort_code = EResultIsErr)]
    fun result_err_aborts() {
        let result = create_err(99);
        let _ = unwrap_ok(result); // Should abort
}

    #[test]
    fun message_text_extracts_content() {
        let msg = Message::Text(b"Hello");
        let content = message_content(msg);
        assert!(content == b"Hello");
}

    #[test]
    fun message_empty_returns_empty() {
        let msg = Message::Empty;
        let content = message_content(msg);
        assert!(content == b"");
}

}