// Exercise: Modules and Visibility
//
// Practice module visibility. Make the greet function public.
//
// Stuck? Check out: https://move-book.com/move-basics/visibility-modifiers.html

module suilings::greeter;

/// Greets a person by name, returning "Hello, <name>"
fun greet(name: vector<u8>): vector<u8> {
    // TODO: Make this function public
    let hello = b"Hello, ";
    let mut result = hello;
    result.append(name);
    result
}

#[test_only]

use suilings::greeter;

#[test]
fun greet() {
    let name = b"Alice";
    let greeting = greeter::greet(name);
    assert!(greeting == b"Hello, Alice");
}