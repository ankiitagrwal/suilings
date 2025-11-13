// Strings in Move come in two flavors: ASCII and UTF-8.
//
// Common operations:
// - string::utf8(bytes) - create UTF-8 string from bytes
// - ascii::string(bytes) - create ASCII string from bytes
// - string::length(s) - get length
// - string::is_empty(s) - check if empty
// - string::append(s1, s2) - concatenate strings
// - string::as_bytes(s) - get underlying bytes
//
// Your task:
// Implement basic string operations using Move's string module.

module suilings::strings1 {
    use std::string::{Self, String};
    use std::vector;
    
    public fun create_greeting(name: String): String {
        // TODO: Create a greeting string "Hello, {name}!"
        // Hint: Use string::utf8() to create strings and string::append()
        // Example: create_greeting(utf8(b"Alice")) = "Hello, Alice!"
        string::utf8(b"")
    }
    
    public fun get_length(s: String): u64 {
        // TODO: Return the length of the string
        0
    }
    
    public fun is_empty_string(s: String): bool {
        // TODO: Return true if the string is empty
        false
    }
    
    public fun concatenate_strings(s1: String, s2: String): String {
        // TODO: Concatenate two strings and return the result
        // Hint: string::append modifies the first string in place
        string::utf8(b"")
    }
    
    public fun repeat_string(s: String, times: u64): String {
        // TODO: Repeat the string 'times' times
        // Example: repeat_string(utf8(b"ha"), 3) = "hahaha"
        string::utf8(b"")
    }
}

#[test_only]
module suilings::strings1_tests {
    use suilings::strings1;
    use std::string;
    
    #[test]
    fun test_create_greeting() {
        let name = string::utf8(b"Alice");
        let greeting = strings1::create_greeting(name);
        let expected = string::utf8(b"Hello, Alice!");
        assert!(greeting == expected, 0);
    }
    
    #[test]
    fun test_get_length() {
        let s = string::utf8(b"Hello");
        assert!(strings1::get_length(s) == 5, 0);
        
        let empty = string::utf8(b"");
        assert!(strings1::get_length(empty) == 0, 1);
    }
    
    #[test]
    fun test_is_empty_string() {
        let empty = string::utf8(b"");
        assert!(strings1::is_empty_string(empty), 0);
        
        let non_empty = string::utf8(b"hello");
        assert!(!strings1::is_empty_string(non_empty), 1);
    }
    
    #[test]
    fun test_concatenate_strings() {
        let s1 = string::utf8(b"Hello, ");
        let s2 = string::utf8(b"World!");
        let result = strings1::concatenate_strings(s1, s2);
        let expected = string::utf8(b"Hello, World!");
        assert!(result == expected, 0);
    }
    
    #[test]
    fun test_repeat_string() {
        let s = string::utf8(b"ha");
        let result = strings1::repeat_string(s, 3);
        let expected = string::utf8(b"hahaha");
        assert!(result == expected, 0);
        
        let s2 = string::utf8(b"Go!");
        let result2 = strings1::repeat_string(s2, 0);
        let expected2 = string::utf8(b"");
        assert!(result2 == expected2, 1);
    }
}


