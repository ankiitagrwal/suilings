// Exercise: References and Struct Methods
//
// Practice working with struct references (& and &mut).
//
// Stuck? Check out: https://move-book.com/move-basics/references.html

module suilings::struct_methods;

/// A bank account with owner and balance
public struct BankAccount has drop {
    owner: vector<u8>,
    balance: u64,
}

/// Creates a new bank account
public fun create_account(owner: vector<u8>, initial_balance: u64): BankAccount {
    BankAccount { owner, balance: initial_balance }
}

/// Returns the account balance
public fun balance(account: &BankAccount): u64 {
    // TODO: Return account.balance
    0
}

/// Adds amount to the account
public fun deposit(account: &mut BankAccount, amount: u64) {
    // TODO: Increase balance by amount
}

/// Removes amount from the account
public fun withdraw(account: &mut BankAccount, amount: u64) {
    // TODO: Decrease balance by amount
    // Note: In production, check if balance >= amount
}

/// Transfers amount from one account to another
public fun transfer(from: &mut BankAccount, to: &mut BankAccount, amount: u64) {
    // TODO: Use withdraw and deposit functions
}

/// Checks if the given name matches the account owner
public fun is_owner(account: &BankAccount, name: vector<u8>): bool {
    // TODO: Compare account.owner with name
    false
}

#[test_only]
module suilings::struct_methods_tests;

use suilings::struct_methods;

#[test]
fun balance_returns_correct_value() {
    let account = struct_methods::create_account(b"Alice", 1000);
    assert!(struct_methods::balance(&account) == 1000);
}

#[test]
fun deposit_increases_balance() {
    let mut account = struct_methods::create_account(b"Bob", 500);
    struct_methods::deposit(&mut account, 200);
    assert!(struct_methods::balance(&account) == 700);
}

#[test]
fun withdraw_decreases_balance() {
    let mut account = struct_methods::create_account(b"Charlie", 1000);
    struct_methods::withdraw(&mut account, 300);
    assert!(struct_methods::balance(&account) == 700);
}

#[test]
fun transfer_moves_funds() {
    let mut account1 = struct_methods::create_account(b"Alice", 1000);
    let mut account2 = struct_methods::create_account(b"Bob", 500);
    
    struct_methods::transfer(&mut account1, &mut account2, 300);
    
    assert!(struct_methods::balance(&account1) == 700);
    assert!(struct_methods::balance(&account2) == 800);
}

#[test]
fun is_owner_checks_ownership() {
    let account = struct_methods::create_account(b"Alice", 1000);
    assert!(struct_methods::is_owner(&account, b"Alice") == true);
    assert!(struct_methods::is_owner(&account, b"Bob") == false);
}