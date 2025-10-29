// ==== MODULE DECLARATION EXERCISE ====
// A Move module must be declared with `module <address>::<name> { … }`.
// The address can be a placeholder (`suilings`) because the runner-crate
// supplies a real address in its Move.toml.
//
// Your task:
// 1. Fix the syntax error in the module declaration.
// 2. Make the `greet` function public so the test can call it.
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

    #[test]
    fun test_greet() {
        let name = b"Alice";
        let greeting = greet(name);
        assert!(greeting == b"Hello, Alice", 0);
    }
}