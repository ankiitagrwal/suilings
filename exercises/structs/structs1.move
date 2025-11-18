// Exercise: Basic Structs
//
// Practice creating and using structs with named fields.
//
// Stuck? Check out: https://move-book.com/move-basics/struct.html

module suilings::structs_basics {

// TODO: Add the 'drop' ability so the struct can be destroyed
/// Represents a person with a name and age
public struct Person {
    // TODO: Add a 'name' field of type vector<u8>
    // TODO: Add an 'age' field of type u8
}

/// Creates a new Person instance
public fun create_person(name: vector<u8>, age: u8): Person {
    // TODO: Create and return a Person instance
    Person { }
}

/// Returns the person's age
public fun age(person: &Person): u8 {
    // TODO: Return the person's age using dot notation
    0
    }}

#[test_only]
module suilings::structs_basics_tests {

    use suilings::structs_basics;

    #[test]
    fun creates_person_with_correct_age() {
    let person = structs_basics::create_person(b"Alice", 25);
    let age = structs_basics::age(&person);
    assert!(age == 25);
}
}