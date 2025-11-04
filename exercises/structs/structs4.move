// In Move, you can pass structs by reference (&) or mutable reference (&mut).
// - & allows reading but not modifying
// - &mut allows both reading and modifying
//
// Your task:
// Implement functions that work with struct references

module suilings::struct_methods {
    public struct BankAccount has drop {
        owner: vector<u8>,
        balance: u64,
    }
    
    public fun create_account(owner: vector<u8>, initial_balance: u64): BankAccount {
        BankAccount { owner, balance: initial_balance }
    }
    
    public fun get_balance(account: &BankAccount): u64 {
        // TODO: Return the account's balance
        0
    }
    
    public fun deposit(account: &mut BankAccount, amount: u64) {
        // TODO: Add amount to the account's balance
        // Hint: account.balance = account.balance + amount;
    }
    
    public fun withdraw(account: &mut BankAccount, amount: u64) {
        // TODO: Subtract amount from the account's balance
        // Note: In production, you'd check if balance >= amount
    }
    
    public fun transfer(from: &mut BankAccount, to: &mut BankAccount, amount: u64) {
        // TODO: Withdraw from 'from' account and deposit to 'to' account
        // Hint: Use the withdraw and deposit functions
    }
    
    public fun is_owner(account: &BankAccount, name: vector<u8>): bool {
        // TODO: Return true if the account owner matches the given name
        // Hint: account.owner == name
        false
    }
}

#[test_only]
module suilings::struct_methods_tests {
    use suilings::struct_methods;
    
    #[test]
    fun test_balance() {
        let account = struct_methods::create_account(b"Alice", 1000);
        assert!(struct_methods::get_balance(&account) == 1000, 0);
    }
    
    #[test]
    fun test_deposit() {
        let mut account = struct_methods::create_account(b"Bob", 500);
        struct_methods::deposit(&mut account, 200);
        assert!(struct_methods::get_balance(&account) == 700, 0);
    }
    
    #[test]
    fun test_withdraw() {
        let mut account = struct_methods::create_account(b"Charlie", 1000);
        struct_methods::withdraw(&mut account, 300);
        assert!(struct_methods::get_balance(&account) == 700, 0);
    }
    
    #[test]
    fun test_transfer() {
        let mut account1 = struct_methods::create_account(b"Alice", 1000);
        let mut account2 = struct_methods::create_account(b"Bob", 500);
        
        struct_methods::transfer(&mut account1, &mut account2, 300);
        
        assert!(struct_methods::get_balance(&account1) == 700, 0);
        assert!(struct_methods::get_balance(&account2) == 800, 1);
    }
    
    #[test]
    fun test_is_owner() {
        let account = struct_methods::create_account(b"Alice", 1000);
        assert!(struct_methods::is_owner(&account, b"Alice") == true, 0);
        assert!(struct_methods::is_owner(&account, b"Bob") == false, 1);
    }
}

