// Exercise: Capability Pattern - Treasury Management
//
// Build a multi-level treasury system where different capabilities
// grant different spending limits and permissions.
//
// Stuck? Check out: https://move-book.com/programmability/capability.html

module suilings::capability2 {
use sui::object::{Self, UID};

// Error constants
const EInsufficientBalance: u64 = 1;
const EExceedsLimit: u64 = 2;

use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::balance::{Self, Balance};

/// Treasury that holds funds
public struct Treasury has key {
    id: UID,
    balance: u64,
    total_deposited: u64,
    total_withdrawn: u64,
    owner: address,
}

/// Master key - unlimited access
public struct MasterKey has key, store {
    id: UID,
    holder: address,
}

/// Manager capability - can withdraw up to a limit per transaction
public struct ManagerCap has key, store {
    id: UID,
    holder: address,
    withdrawal_limit: u64,
    total_withdrawn: u64,
}

/// Clerk capability - can only view, not withdraw
public struct ClerkCap has key, store {
    id: UID,
    holder: address,
}

/// Receipt for a withdrawal
public struct WithdrawalReceipt has key, store {
    id: UID,
    amount: u64,
    withdrawn_by: address,
    timestamp_epoch: u64,
}

/// Create a treasury for your organization
/// 
/// Your DAO needs a secure treasury to manage collective funds.
/// The creator receives the MasterKey with full control.
///
/// Treasury Initialization:
/// - Start with zero balance and clean accounting
/// - Creator becomes the treasury owner
///
/// Access Control:
/// - Create a MasterKey for unlimited access
/// - Make treasury publicly accessible for deposits
public fun create_treasury(ctx: &mut TxContext) {
    let owner = tx_context::sender(ctx);
    
    // Your implementation here
    abort 0
}

/// Deposit funds into the treasury
/// 
/// Anyone can deposit funds - this enables crowdfunding and donations.
///
/// Accounting:
/// - Increase current balance
/// - Track total deposited (for audit trail)
public fun deposit(treasury: &mut Treasury, amount: u64) {
    // Your implementation here
}

/// Grant manager capability with spending limits
/// 
/// The MasterKey holder can delegate limited spending authority.
/// Managers can withdraw, but only up to their assigned limit.
///
/// Manager Setup:
/// - Assign a per-transaction spending limit
/// - Start with zero total withdrawn (for tracking)
/// - Send capability to the new manager
public fun grant_manager(
    _master_key: &MasterKey,
    holder: address,
    withdrawal_limit: u64,
    ctx: &mut TxContext
) {
    // Your implementation here
    abort 0
}

/// Grant clerk capability (view-only access)
/// 
/// Clerks can view treasury balances for reporting purposes
/// but cannot withdraw any funds.
public fun grant_clerk(
    _master_key: &MasterKey,
    holder: address,
    ctx: &mut TxContext
) {
    // Your implementation here
    abort 0
}

/// Withdraw with MasterKey (unlimited authority)
/// 
/// The master key holder has unrestricted access to treasury funds.
///
/// Validation:
/// - Ensure sufficient balance exists
///
/// Transaction:
/// - Deduct from balance
/// - Track in total withdrawn
/// - Issue a WithdrawalReceipt for audit trail
public fun withdraw_with_master(
    _master_key: &MasterKey,
    treasury: &mut Treasury,
    amount: u64,
    ctx: &mut TxContext
) {
    // Your implementation here
    abort 0
}

/// Withdraw with ManagerCap (limited authority)
/// 
/// Managers can withdraw within their authorized limits.
///
/// Spending Controls:
/// - Amount must not exceed the manager's per-transaction limit
/// - Treasury must have sufficient balance
///
/// Manager Tracking:
/// - Update manager's total withdrawn (for accountability)
///
/// Audit Trail:
/// - Issue a WithdrawalReceipt
public fun withdraw_with_manager(
    manager_cap: &mut ManagerCap,
    treasury: &mut Treasury,
    amount: u64,
    ctx: &mut TxContext
) {
    // Your implementation here
    abort 0
}

/// View balance with clerk capability
public fun view_balance_with_clerk(_clerk_cap: &ClerkCap, treasury: &Treasury): u64 {
    // Return treasury balance
    0
}

/// View balance with manager capability
public fun view_balance_with_manager(_manager_cap: &ManagerCap, treasury: &Treasury): u64 {
    // Return treasury balance
    0
}

/// View balance with master key
public fun view_balance_with_master(_master_key: &MasterKey, treasury: &Treasury): u64 {
    // Return treasury balance
    0
}

/// Get treasury information
public fun treasury_info(treasury: &Treasury): (u64, u64, u64, address) {
    // Return (balance, total_deposited, total_withdrawn, owner)
    (0, 0, 0, @0x0)
}

/// Get manager statistics
public fun manager_stats(cap: &ManagerCap): (address, u64, u64) {
    // Return (holder, withdrawal_limit, total_withdrawn)
    (@0x0, 0, 0)
}

/// Get receipt information
public fun receipt_info(receipt: &WithdrawalReceipt): (u64, address, u64) {
    // Return (amount, withdrawn_by, timestamp_epoch)
    (0, @0x0, 0)
}

/// Revoke manager capability (MasterKey holder only)
/// 
/// Remove a manager's spending authority by destroying their capability.
public fun revoke_manager(_master_key: &MasterKey, manager_cap: ManagerCap) {
    let ManagerCap { id, holder: _, withdrawal_limit: _, total_withdrawn: _ } = manager_cap;
    object::delete(id);
}
}

#[test_only]
module suilings::capability2_tests {
use suilings::capability2::{Self, Treasury, MasterKey, ManagerCap, ClerkCap, WithdrawalReceipt};
use sui::test_scenario;

#[test]
fun test_create_and_deposit() {
    let owner = @0xCAFE;
    let mut scenario = test_scenario::begin(owner);
    
    // Create treasury
    {
        capability2::create_treasury(test_scenario::ctx(&mut scenario));
    };
    
    // Deposit funds
    test_scenario::next_tx(&mut scenario, owner);
    {
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        capability2::deposit(&mut treasury, 1000);
        
        let (balance, deposited, withdrawn, _) = capability2::treasury_info(&treasury);
        assert!(balance == 1000, 0);
        assert!(deposited == 1000, 1);
        assert!(withdrawn == 0, 2);
        
        test_scenario::return_shared(treasury);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_master_withdrawal() {
    let owner = @0xCAFE;
    let mut scenario = test_scenario::begin(owner);
    
    // Setup
    {
        capability2::create_treasury(test_scenario::ctx(&mut scenario));
    };
    
    test_scenario::next_tx(&mut scenario, owner);
    {
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        capability2::deposit(&mut treasury, 1000);
        test_scenario::return_shared(treasury);
    };
    
    // Withdraw
    test_scenario::next_tx(&mut scenario, owner);
    {
        let master_key = test_scenario::take_from_sender<MasterKey>(&scenario);
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        
        capability2::withdraw_with_master(&master_key, &mut treasury, 500, test_scenario::ctx(&mut scenario));
        
        let (balance, _, withdrawn, _) = capability2::treasury_info(&treasury);
        assert!(balance == 500, 0);
        assert!(withdrawn == 500, 1);
        
        test_scenario::return_shared(treasury);
        test_scenario::return_to_sender(&scenario, master_key);
    };
    
    // Check receipt
    test_scenario::next_tx(&mut scenario, owner);
    {
        let receipt = test_scenario::take_from_sender<WithdrawalReceipt>(&scenario);
        let (amount, by, _) = capability2::receipt_info(&receipt);
        assert!(amount == 500, 0);
        assert!(by == owner, 1);
        test_scenario::return_to_sender(&scenario, receipt);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_manager_withdrawal() {
    let owner = @0xCAFE;
    let manager = @0xA;
    let mut scenario = test_scenario::begin(owner);
    
    // Setup
    {
        capability2::create_treasury(test_scenario::ctx(&mut scenario));
    };
    
    test_scenario::next_tx(&mut scenario, owner);
    {
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        let master_key = test_scenario::take_from_sender<MasterKey>(&scenario);
        
        capability2::deposit(&mut treasury, 1000);
        capability2::grant_manager(&master_key, manager, 100, test_scenario::ctx(&mut scenario));
        
        test_scenario::return_shared(treasury);
        test_scenario::return_to_sender(&scenario, master_key);
    };
    
    // Manager withdraws
    test_scenario::next_tx(&mut scenario, manager);
    {
        let mut manager_cap = test_scenario::take_from_address<ManagerCap>(&scenario, manager);
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        
        capability2::withdraw_with_manager(&mut manager_cap, &mut treasury, 50, test_scenario::ctx(&mut scenario));
        
        let (_, limit, withdrawn) = capability2::manager_stats(&manager_cap);
        assert!(limit == 100, 0);
        assert!(withdrawn == 50, 1);
        
        test_scenario::return_shared(treasury);
        test_scenario::return_to_address(manager, manager_cap);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_clerk_can_view() {
    let owner = @0xCAFE;
    let clerk = @0xB;
    let mut scenario = test_scenario::begin(owner);
    
    // Setup
    {
        capability2::create_treasury(test_scenario::ctx(&mut scenario));
    };
    
    test_scenario::next_tx(&mut scenario, owner);
    {
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        let master_key = test_scenario::take_from_sender<MasterKey>(&scenario);
        
        capability2::deposit(&mut treasury, 500);
        capability2::grant_clerk(&master_key, clerk, test_scenario::ctx(&mut scenario));
        
        test_scenario::return_shared(treasury);
        test_scenario::return_to_sender(&scenario, master_key);
    };
    
    // Clerk views balance
    test_scenario::next_tx(&mut scenario, clerk);
    {
        let clerk_cap = test_scenario::take_from_address<ClerkCap>(&scenario, clerk);
        let treasury = test_scenario::take_shared<Treasury>(&scenario);
        
        let balance = capability2::view_balance_with_clerk(&clerk_cap, &treasury);
        assert!(balance == 500, 0);
        
        test_scenario::return_shared(treasury);
        test_scenario::return_to_address(clerk, clerk_cap);
    };
    
    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = 2)]
fun test_manager_exceeds_limit() {
    let owner = @0xCAFE;
    let manager = @0xA;
    let mut scenario = test_scenario::begin(owner);
    
    // Setup
    {
        capability2::create_treasury(test_scenario::ctx(&mut scenario));
    };
    
    test_scenario::next_tx(&mut scenario, owner);
    {
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        let master_key = test_scenario::take_from_sender<MasterKey>(&scenario);
        
        capability2::deposit(&mut treasury, 1000);
        capability2::grant_manager(&master_key, manager, 100, test_scenario::ctx(&mut scenario));
        
        test_scenario::return_shared(treasury);
        test_scenario::return_to_sender(&scenario, master_key);
    };
    
    // Manager tries to withdraw more than limit
    test_scenario::next_tx(&mut scenario, manager);
    {
        let mut manager_cap = test_scenario::take_from_address<ManagerCap>(&scenario, manager);
        let mut treasury = test_scenario::take_shared<Treasury>(&scenario);
        
        capability2::withdraw_with_manager(&mut manager_cap, &mut treasury, 150, test_scenario::ctx(&mut scenario)); // Should fail
        
        test_scenario::return_shared(treasury);
        test_scenario::return_to_address(manager, manager_cap);
    };
    
    test_scenario::end(scenario);
}
}
