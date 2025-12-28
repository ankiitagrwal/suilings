// Exercise: Wrapper Type - Flash Loan System (Hot Potato)
//
// Build a flash loan system using the Hot Potato pattern.
// Hot Potato structs MUST be consumed, enforcing specific function call sequences.
//
// Stuck? Check out: https://move-book.com/programmability/hot-potato-pattern.html

#[allow(duplicate_alias)]
module suilings::flash_loan {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::coin::{Self, Coin};
use sui::balance::{Self, Balance};
use sui::sui::SUI;

// Error constants
const ELoanNotRepaid: u64 = 1;
const EInsufficientRepayment: u64 = 2;
const EInsufficientLiquidity: u64 = 3;

/// A liquidity pool that provides flash loans
public struct LiquidityPool has key {
    id: UID,
    /// Total liquidity available for loans
    liquidity: Balance<SUI>,
    /// Total fees collected
    fees_collected: u64,
    /// Fee rate in basis points (100 = 1%)
    fee_rate_bps: u64,
}

/// Hot Potato: A flash loan receipt that MUST be consumed
/// This struct has NO abilities, so it cannot be dropped, stored, or copied
/// The only way to get rid of it is to call repay_flash_loan()
public struct FlashLoan {
    /// Amount borrowed
    amount: u64,
    /// Fee that must be paid
    fee: u64,
    /// Pool ID for verification
    pool_id: address,
}

/// Create a new liquidity pool for flash loans
///
/// Your DeFi protocol needs flash loans - uncollateralized loans that
/// must be repaid in the same transaction. The Hot Potato pattern enforces
/// this: the loan receipt has NO abilities, forcing immediate repayment.
///
/// Implementation Requirements:
/// - Create LiquidityPool with new UID
/// - Convert initial_liquidity Coin to Balance using coin::into_balance()
/// - Set fees_collected to 0
/// - Set fee_rate_bps (typical: 30 = 0.3%)
/// - Share the pool (anyone can borrow)
public fun create_pool(
    initial_liquidity: Coin<SUI>,
    fee_rate_bps: u64,
    ctx: &mut TxContext
) {
    // Your implementation here
    // REMOVE this temporary line after implementation:
    transfer::public_transfer(initial_liquidity, tx_context::sender(ctx));
}

/// Borrow coins via flash loan
///
/// Provide instant loans without collateral. The borrower receives coins
/// AND a FlashLoan receipt. Since FlashLoan has NO abilities, it CANNOT
/// be dropped - the transaction MUST call repay_flash_loan() to consume it.
///
/// Security Requirements:
/// - Pool must have sufficient liquidity (abort with EInsufficientLiquidity)
///
/// Flash Loan Mechanics:
/// - Check pool has enough: balance::value(&pool.liquidity) >= amount
/// - Calculate fee: (amount * pool.fee_rate_bps) / 10000
/// - Split liquidity: balance::split(&mut pool.liquidity, amount)
/// - Convert to Coin: coin::from_balance()
/// - Create FlashLoan receipt (Hot Potato!) with amount, fee, pool_id
/// - Return BOTH the borrowed coins AND the receipt
public fun borrow_flash_loan(
    pool: &mut LiquidityPool,
    amount: u64,
    ctx: &mut TxContext
): (Coin<SUI>, FlashLoan) {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Repay the flash loan (consumes the Hot Potato)
///
/// This is the ONLY way to consume the FlashLoan receipt. The borrower
/// must return the borrowed amount PLUS the fee. This function "burns"
/// the Hot Potato, completing the required action sequence.
///
/// Security Requirements:
/// - Repayment must be >= loan amount + fee (abort with EInsufficientRepayment)
///
/// Repayment Operations:
/// - Calculate required_amount = flash_loan.amount + flash_loan.fee
/// - Verify coin::value(repayment) >= required_amount
/// - Split exact repayment if overpaid: coin::split()
/// - Add repayment to pool: balance::join(&mut pool.liquidity, ...)
/// - Add fee to fees_collected
/// - Destroy the FlashLoan struct (consume the Hot Potato!)
/// - Return any excess as change
public fun repay_flash_loan(
    pool: &mut LiquidityPool,
    mut repayment: Coin<SUI>,
    flash_loan: FlashLoan,
    ctx: &mut TxContext
): Coin<SUI> {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Add liquidity to the pool
///
/// Liquidity providers deposit coins to earn fees.
/// This increases the pool's lending capacity.
///
/// Pool Operations:
/// - Convert deposit Coin to Balance
/// - Join with pool liquidity: balance::join(&mut pool.liquidity, ...)
public fun add_liquidity(
    pool: &mut LiquidityPool,
    deposit: Coin<SUI>,
) {
    // Your implementation here
    // REMOVE this temporary line after implementation:
    transfer::public_freeze_object(deposit);
}

// ==================== Getter Functions ====================

public fun total_liquidity(pool: &LiquidityPool): u64 {
    balance::value(&pool.liquidity)
}

public fun fees_collected(pool: &LiquidityPool): u64 {
    pool.fees_collected
}

public fun fee_rate_bps(pool: &LiquidityPool): u64 {
    pool.fee_rate_bps
}

public fun loan_amount(loan: &FlashLoan): u64 {
    loan.amount
}

public fun loan_fee(loan: &FlashLoan): u64 {
    loan.fee
}
}

#[test_only]
module suilings::flash_loan_tests {
use suilings::flash_loan::{Self, LiquidityPool};
use sui::test_scenario;
use sui::coin;
use sui::sui::SUI;

const PROVIDER: address = @0xA11CE;
const BORROWER: address = @0xB0B;
const ONE_SUI: u64 = 1_000_000_000;

#[test]
fun test_create_pool() {
    let mut scenario = test_scenario::begin(PROVIDER);

    test_scenario::next_tx(&mut scenario, PROVIDER);
    {
        let initial = coin::mint_for_testing<SUI>(100 * ONE_SUI, test_scenario::ctx(&mut scenario));
        flash_loan::create_pool(initial, 30, test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, PROVIDER);
    {
        let pool = test_scenario::take_shared<LiquidityPool>(&scenario);
        assert!(flash_loan::total_liquidity(&pool) == 100 * ONE_SUI, 0);
        assert!(flash_loan::fee_rate_bps(&pool) == 30, 1);
        assert!(flash_loan::fees_collected(&pool) == 0, 2);
        test_scenario::return_shared(pool);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_flash_loan_borrow_and_repay() {
    let mut scenario = test_scenario::begin(PROVIDER);

    test_scenario::next_tx(&mut scenario, PROVIDER);
    {
        let initial = coin::mint_for_testing<SUI>(100 * ONE_SUI, test_scenario::ctx(&mut scenario));
        flash_loan::create_pool(initial, 30, test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, BORROWER);
    {
        let mut pool = test_scenario::take_shared<LiquidityPool>(&scenario);
        let borrow_amount = 10 * ONE_SUI;
        
        // Borrow flash loan
        let (borrowed_coins, flash_loan) = flash_loan::borrow_flash_loan(&mut pool, borrow_amount, test_scenario::ctx(&mut scenario));
        
        assert!(coin::value(&borrowed_coins) == borrow_amount, 0);
        assert!(flash_loan::loan_amount(&flash_loan) == borrow_amount, 1);
        
        // Calculate fee: 10 SUI * 30 / 10000 = 0.03 SUI = 30_000_000 MIST
        let expected_fee = (borrow_amount * 30) / 10000;
        assert!(flash_loan::loan_fee(&flash_loan) == expected_fee, 2);
        
        // Repay: borrowed amount + fee
        let mut repayment = coin::mint_for_testing<SUI>(borrow_amount + expected_fee, test_scenario::ctx(&mut scenario));
        coin::join(&mut repayment, borrowed_coins);
        
        let change = flash_loan::repay_flash_loan(&mut pool, repayment, flash_loan, test_scenario::ctx(&mut scenario));
        
        // Verify pool state
        assert!(flash_loan::total_liquidity(&pool) == 100 * ONE_SUI + expected_fee, 3);
        assert!(flash_loan::fees_collected(&pool) == expected_fee, 4);
        
        coin::burn_for_testing(change);
        test_scenario::return_shared(pool);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_add_liquidity() {
    let mut scenario = test_scenario::begin(PROVIDER);

    test_scenario::next_tx(&mut scenario, PROVIDER);
    {
        let initial = coin::mint_for_testing<SUI>(50 * ONE_SUI, test_scenario::ctx(&mut scenario));
        flash_loan::create_pool(initial, 30, test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, PROVIDER);
    {
        let mut pool = test_scenario::take_shared<LiquidityPool>(&scenario);
        let additional = coin::mint_for_testing<SUI>(50 * ONE_SUI, test_scenario::ctx(&mut scenario));
        flash_loan::add_liquidity(&mut pool, additional);
        assert!(flash_loan::total_liquidity(&pool) == 100 * ONE_SUI, 0);
        test_scenario::return_shared(pool);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = flash_loan::EInsufficientLiquidity)]
fun test_insufficient_liquidity_fails() {
    let mut scenario = test_scenario::begin(PROVIDER);

    test_scenario::next_tx(&mut scenario, PROVIDER);
    {
        let initial = coin::mint_for_testing<SUI>(10 * ONE_SUI, test_scenario::ctx(&mut scenario));
        flash_loan::create_pool(initial, 30, test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, BORROWER);
    {
        let mut pool = test_scenario::take_shared<LiquidityPool>(&scenario);
        // This should fail before returning, so unreachable code
        let (_coins, _loan) = flash_loan::borrow_flash_loan(&mut pool, 100 * ONE_SUI, test_scenario::ctx(&mut scenario));
        coin::burn_for_testing(_coins);
        // Can't deconstruct FlashLoan - it's a Hot Potato! Must use repay_flash_loan()
        abort 999
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = flash_loan::EInsufficientRepayment)]
fun test_insufficient_repayment_fails() {
    let mut scenario = test_scenario::begin(PROVIDER);

    test_scenario::next_tx(&mut scenario, PROVIDER);
    {
        let initial = coin::mint_for_testing<SUI>(100 * ONE_SUI, test_scenario::ctx(&mut scenario));
        flash_loan::create_pool(initial, 30, test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, BORROWER);
    {
        let mut pool = test_scenario::take_shared<LiquidityPool>(&scenario);
        let borrow_amount = 10 * ONE_SUI;
        
        let (borrowed_coins, flash_loan) = flash_loan::borrow_flash_loan(&mut pool, borrow_amount, test_scenario::ctx(&mut scenario));
        
        // Try to repay less than borrowed
        let insufficient = coin::mint_for_testing<SUI>(borrow_amount / 2, test_scenario::ctx(&mut scenario));
        coin::burn_for_testing(borrowed_coins);
        
        let change = flash_loan::repay_flash_loan(&mut pool, insufficient, flash_loan, test_scenario::ctx(&mut scenario));
        coin::destroy_zero(change);
        test_scenario::return_shared(pool);
    };

    test_scenario::end(scenario);
}
}

