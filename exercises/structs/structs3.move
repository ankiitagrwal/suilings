// Exercise: Nested Structs
//
// Practice working with structs that contain other structs.
//
// Stuck? Check out: https://move-book.com/move-basics/struct.html

module suilings::nested_structs;

/// A street address with city
public struct Address has drop {
    street: vector<u8>,
    city: vector<u8>,
}

/// An employee with name, address, and salary
public struct Employee has drop {
    name: vector<u8>,
    // TODO: Add an 'address' field of type Address
    salary: u64,
}

/// A department with a name and manager
public struct Department has drop {
    name: vector<u8>,
    // TODO: Add a 'manager' field of type Employee
}

/// Creates a new address
public fun create_address(street: vector<u8>, city: vector<u8>): Address {
    Address { street, city }
}

/// Creates a new employee
public fun create_employee(
    name: vector<u8>, 
    address: Address, 
    salary: u64
): Employee {
    // TODO: Create and return an Employee with all fields
    Employee { 
        name,
        salary,
    }
}

/// Creates a new department
public fun create_department(name: vector<u8>, manager: Employee): Department {
    // TODO: Create and return a Department with all fields
    Department { 
        name,
    }
}

/// Returns the name of the department's manager
public fun manager_name(dept: &Department): vector<u8> {
    // TODO: Access nested field: dept.manager.name
    b""
}

/// Returns the city where the manager lives
public fun manager_city(dept: &Department): vector<u8> {
    // TODO: Access deeply nested field: dept.manager.address.city
    b""
}

#[test_only]
module suilings::nested_structs_tests;

use suilings::nested_structs;

#[test]
fun nested_struct_access_works() {
    let addr = nested_structs::create_address(b"123 Main St", b"Springfield");
    let emp = nested_structs::create_employee(b"Alice", addr, 50000);
    let dept = nested_structs::create_department(b"Engineering", emp);
    
    assert!(nested_structs::manager_name(&dept) == b"Alice");
    assert!(nested_structs::manager_city(&dept) == b"Springfield");
}