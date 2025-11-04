// In Move, you can use functions and types from other modules by importing them.
// The `use` statement allows you to bring items into scope.
//
// Your task:
// 1. Import the `vector` module from the standard library
// 2. Use it to create and return a vector with the numbers 1, 2, 3
//

module suilings::module_imports {
    // TODO: Add the use statement here
    
    public fun create_numbers(): vector<u64> {
        // TODO: Create a vector and add numbers 1, 2, 3
        // Hint: let mut v = vector::empty<u64>();
        //       vector::push_back(&mut v, 1);
        vector::empty()
    }
}

#[test_only]
module suilings::module_imports_tests {
    use suilings::module_imports;
    
    #[test]
    fun test_create_numbers() {
        let numbers = module_imports::create_numbers();
        assert!(vector::length(&numbers) == 3, 0);
        assert!(*vector::borrow(&numbers, 0) == 1, 1);
        assert!(*vector::borrow(&numbers, 1) == 2, 2);
        assert!(*vector::borrow(&numbers, 2) == 3, 3);
    }
}

