// ==== NESTED STRUCTS EXERCISE ====
// Structs can contain other structs as fields.
// This allows you to build complex data structures.
//
// Your task:
// Complete the nested struct definitions and implement the functions

module suilings::nested_structs {
    public struct Address has drop {
        street: vector<u8>,
        city: vector<u8>,
    }
    
    public struct Employee has drop {
        name: vector<u8>,
        // TODO: Add an 'address' field of type Address
        salary: u64,
    }
    
    public struct Department has drop {
        name: vector<u8>,
        // TODO: Add a 'manager' field of type Employee
    }
    
    public fun create_address(street: vector<u8>, city: vector<u8>): Address {
        Address { street, city }
    }
    
    public fun create_employee(
        name: vector<u8>, 
        address: Address, 
        salary: u64
    ): Employee {
        // TODO: Create and return an Employee with the given fields
        Employee { 
            name,
            salary,
        }
    }
    
    public fun create_department(name: vector<u8>, manager: Employee): Department {
        // TODO: Create and return a Department with the given fields
        Department { 
            name,
        }
    }
    
    public fun get_manager_name(dept: &Department): vector<u8> {
        // TODO: Return the name of the department's manager
        // Hint: Access nested fields with dept.manager.name
        b""
    }
    
    public fun get_manager_city(dept: &Department): vector<u8> {
        // TODO: Return the city of the department manager's address
        // Hint: dept.manager.address.city
        b""
    }
}

#[test_only]
module suilings::nested_structs_tests {
    use suilings::nested_structs;
    
    #[test]
    fun test_nested_structs() {
        let addr = nested_structs::create_address(b"123 Main St", b"Springfield");
        let emp = nested_structs::create_employee(b"Alice", addr, 50000);
        let dept = nested_structs::create_department(b"Engineering", emp);
        
        assert!(nested_structs::get_manager_name(&dept) == b"Alice", 0);
        assert!(nested_structs::get_manager_city(&dept) == b"Springfield", 1);
    }
}

