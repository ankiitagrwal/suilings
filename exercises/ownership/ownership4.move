// Advanced ownership: nested structures, borrowing fields, and ownership in collections.
//
// Your task:
// Handle ownership with complex data structures.

module suilings::ownership4 {
    use std::vector;
    
    public struct Wallet has drop {
        owner: address,
        balance: u64,
    }
    
    public struct Account has drop {
        wallet: Wallet,
        transactions: vector<u64>,
    }
    
    public fun create_wallet(owner: address, balance: u64): Wallet {
        Wallet { owner, balance }
    }
    
    public fun create_account(wallet: Wallet): Account {
        Account {
            wallet,
            transactions: vector::empty<u64>(),
        }
    }
    
    public fun get_balance(account: &Account): u64 {
        // TODO: Return the wallet's balance using a reference
        account.wallet.balance
    }
    
    public fun deposit(account: &mut Account, amount: u64) {
        // TODO: Add amount to wallet balance
        account.wallet.balance = account.wallet.balance + amount;
    }
    
    public fun add_transaction(account: &mut Account, amount: u64) {
        // TODO: Add transaction amount to transactions vector
        vector::push_back(&mut account.transactions, amount);
    }
    
    public fun extract_wallet(account: Account): Wallet {
        // TODO: Extract and return the wallet from account
        // This moves the wallet out of the account
        let Account { wallet, transactions: _ } = account;
        wallet
    }
}

#[test_only]
module suilings::ownership4_tests {
    use suilings::ownership4;
    use sui::test_scenario;
    
    #[test]
    fun test_account_operations() {
        let addr = @0x123;
        let wallet = ownership4::create_wallet(addr, 100);
        let mut account = ownership4::create_account(wallet);
        
        assert!(ownership4::get_balance(&account) == 100, 0);
        
        ownership4::deposit(&mut account, 50);
        assert!(ownership4::get_balance(&account) == 150, 1);
        
        ownership4::add_transaction(&mut account, 25);
        ownership4::add_transaction(&mut account, 30);
        
        let extracted_wallet = ownership4::extract_wallet(account);
        // account is now consumed
    }
}

