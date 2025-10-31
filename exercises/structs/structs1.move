// ==== STRUCTS EXERCISE ====
// Structs allow you to create custom data types with named fields.
// Syntax: struct Name { field1: Type1, field2: Type2 }
//
// Your task:
// 1. Complete the Person struct with age and name fields
// 2. Implement the create_person function to instantiate the struct

module suilings::structs_basics {
    // TODO: Add the 'drop' ability so the struct can be destroyed
    public struct Person {
        // TODO: Add a 'name' field of type vector<u8>
        // TODO: Add an 'age' field of type u8
    }
    
    public fun create_person(name: vector<u8>, age: u8): Person {
        // TODO: Create and return a Person instance
        // Hint: Person { name, age }
        Person { }
    }
    
    public fun get_age(person: &Person): u8 {
        // TODO: Return the person's age
        // Hint: person.age
        0
    }
}

#[test_only]
module suilings::structs_basics_tests {
    use suilings::structs_basics;
    
    #[test]
    fun test_create_person() {
        let person = structs_basics::create_person(b"Alice", 25);
        let age = structs_basics::get_age(&person);
        assert!(age == 25, 0);
    }
}

