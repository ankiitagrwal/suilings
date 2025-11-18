// Exercise: Standard Library Imports
//
// Practice importing from the standard library.
//
// Stuck? Check out: https://move-book.com/move-basics/importing-modules.html

module suilings::module_imports {

// TODO: Add the use statement here

/// Creates and returns a vector with numbers 1, 2, 3
public fun create_numbers(): vector<u64> {
    // TODO: Create a vector with literal syntax: vector[1, 2, 3]
    // Or use vector::empty() and push_back
    vector::empty()
    }}

#[test_only]
module suilings::module_imports_tests {

    use suilings::module_imports;

    #[test]
    fun create_numbers_works() {
    let numbers = module_imports::create_numbers();
    assert!(numbers.length() == 3);
    assert!(numbers[0] == 1);
    assert!(numbers[1] == 2);
    assert!(numbers[2] == 3);
}
}