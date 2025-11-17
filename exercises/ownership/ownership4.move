// Exercise: Advanced Ownership Patterns
//
// Handle ownership with complex nested data structures.
//
// Stuck? Check out: https://move-book.com/move-basics/ownership-and-scope.html

module suilings::ownership4;
use std::vector;
    
/// Wallet with owner and balance
public struct Wallet has drop {
    owner: address,
    balance: u64,
}
    
/// Account containing a wallet and transaction history
public struct Account has drop {
    wallet: Wallet,
    transactions: vector<u64>,
}
    
/// Creates a new wallet
public fun create_wallet(owner: address, balance: u64): Wallet {
    Wallet { owner, balance }
}
    
/// Creates a new account with a wallet
public fun create_account(wallet: Wallet): Account {
    Account {
        wallet,
        transactions: vector::empty<u64>(),
    }
}
    
/// Returns the wallet's balance
public fun balance(account: &Account): u64 {
    // TODO: Return the wallet's balance using a reference
    0
}
    
/// Deposits an amount into the account
public fun deposit(account: &mut Account, amount: u64) {
    // TODO: Add amount to wallet balance
}
    
/// Adds a transaction to the history
public fun add_transaction(account: &mut Account, amount: u64) {
    // TODO: Add transaction amount to transactions vector
}
    
/// Extracts the wallet from the account
public fun extract_wallet(account: Account): Wallet {
    // TODO: Extract and return the wallet from account
    // This moves the wallet out of the account
    abort 0
}

#[test_only]
module suilings::ownership4_tests;

use suilings::ownership4;
use sui::test_scenario;

#[test]
fun account_operations_work() {
    let addr = @0x123;
    let wallet = ownership4::create_wallet(addr, 100);
    let mut account = ownership4::create_account(wallet);
    
    assert!(ownership4::balance(&account) == 100);
    
    ownership4::deposit(&mut account, 50);
    assert!(ownership4::balance(&account) == 150);
    
    ownership4::add_transaction(&mut account, 25);
    ownership4::add_transaction(&mut account, 30);
    
    let extracted_wallet = ownership4::extract_wallet(account);
    // account is now consumed
}
