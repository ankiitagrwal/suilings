// ==== MODULE DECLARATION EXERCISE ====
// A Move module must be declared with `module <address>::<name> { … }`.
// In Move, functions are private by default. To call them from other modules,
// they must be marked as `public`.
//
// Your task:
// Make the `greet` function public so the test module can call it.
//
// When the file compiles **and** the test passes you are done.


module suilings::greeter {
    fun greet(name: vector<u8>): vector<u8> {
        // concatenate "Hello, " + name
        let hello = b"Hello, ";
        let mut result = hello;
        result.append(name);
        result
    }
}

// Test module - this is in a DIFFERENT module, so it requires greet() to be public
#[test_only]
module suilings::greeter_tests {
    use suilings::greeter;
    
    #[test]
    fun test_greet() {
        let name = b"Alice";
        let greeting = greeter::greet(name);
        assert!(greeting == b"Hello, Alice", 0);
    }
}