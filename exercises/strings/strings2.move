// Advanced string operations in Move.
//
// String manipulation:
// - string::substring(s, start, end) - extract substring
// - string::index_of(s, substring) - find index of substring
// - Working with bytes for character operations
//
// Your task:
// Implement advanced string operations.

module suilings::strings2 {
    use std::string::{Self, String};
    use std::option;
    use std::vector;
    
    public fun substring(s: String, start: u64, end: u64): String {
        // TODO: Extract a substring from start to end (exclusive)
        // Hint: Use string::sub_string()
        // Example: substring(utf8(b"Hello"), 0, 3) = "Hel"
        string::utf8(b"")
    }
    
    public fun contains(haystack: String, needle: String): bool {
        // TODO: Check if haystack contains needle
        // Hint: Use string::index_of() which returns u64
        // Return true if found, false otherwise
        false
    }
    
    public fun starts_with(s: String, prefix: String): bool {
        // TODO: Check if string starts with prefix
        // Hint: Compare lengths first, then use substring
        false
    }
    
    public fun ends_with(s: String, suffix: String): bool {
        // TODO: Check if string ends with suffix
        false
    }
    
    public fun count_char(s: String, ch: u8): u64 {
        // TODO: Count occurrences of a character (byte) in string
        // Hint: Use string::as_bytes() to get &vector<u8>, then iterate
        // Example: count_char(utf8(b"hello"), 'l') = 2
        0
    }
    
    public fun to_uppercase_ascii(s: String): String {
        // TODO: Convert ASCII lowercase letters to uppercase
        // Hint: ASCII 'a' = 97, 'A' = 65, difference is 32
        // Only convert a-z to A-Z, leave others unchanged
        string::utf8(b"")
    }
}

#[test_only]
module suilings::strings2_tests {
    use suilings::strings2;
    use std::string;
    
    #[test]
    fun test_substring() {
        let s = string::utf8(b"Hello, World!");
        let sub = strings2::substring(s, 0, 5);
        assert!(sub == string::utf8(b"Hello"), 0);
        
        let s2 = string::utf8(b"Move Language");
        let sub2 = strings2::substring(s2, 5, 13);
        assert!(sub2 == string::utf8(b"Language"), 1);
    }
    
    #[test]
    fun test_contains() {
        let s = string::utf8(b"Hello, World!");
        assert!(strings2::contains(s, string::utf8(b"World")), 0);
        assert!(!strings2::contains(string::utf8(b"Hello, World!"), string::utf8(b"Rust")), 1);
    }
    
    #[test]
    fun test_starts_with() {
        let s = string::utf8(b"Hello, World!");
        assert!(strings2::starts_with(s, string::utf8(b"Hello")), 0);
        assert!(!strings2::starts_with(string::utf8(b"Hello, World!"), string::utf8(b"World")), 1);
    }
    
    #[test]
    fun test_ends_with() {
        let s = string::utf8(b"Hello, World!");
        assert!(strings2::ends_with(s, string::utf8(b"World!")), 0);
        assert!(!strings2::ends_with(string::utf8(b"Hello, World!"), string::utf8(b"Hello")), 1);
    }
    
    #[test]
    fun test_count_char() {
        let s = string::utf8(b"hello");
        assert!(strings2::count_char(s, 108) == 2, 0); // 'l' = 108
        
        let s2 = string::utf8(b"Mississippi");
        assert!(strings2::count_char(s2, 115) == 4, 1); // 's' = 115
        assert!(strings2::count_char(string::utf8(b"Mississippi"), 105) == 4, 2); // 'i' = 105
    }
    
    #[test]
    fun test_to_uppercase_ascii() {
        let s = string::utf8(b"hello");
        let upper = strings2::to_uppercase_ascii(s);
        assert!(upper == string::utf8(b"HELLO"), 0);
        
        let s2 = string::utf8(b"Hello World!");
        let upper2 = strings2::to_uppercase_ascii(s2);
        assert!(upper2 == string::utf8(b"HELLO WORLD!"), 1);
    }
}


