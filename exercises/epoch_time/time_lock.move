// Exercise: Epoch and Time - Time-Locked Vault
//
// Build a time-locked vault where funds can't be withdrawn until a future time.
// Similar to an escrow or savings account with withdrawal restrictions.
//
// Stuck? Check out: https://move-book.com/programmability/epoch-and-time.html

#[allow(duplicate_alias)]
module suilings::time_lock {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::clock::{Self, Clock};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::balance;

    // Error constants
    const ENotOwner: u64 = 1;
    const EStillLocked: u64 = 2;
    const EAlreadyWithdrawn: u64 = 3;
    const EInvalidLockDuration: u64 = 4;

    /// A time-locked vault that holds SUI coins
    /// Business Context: Similar to a savings account with withdrawal restrictions
    /// or escrow that releases funds after a specific time period.
    /// 
    /// Real-world Use Cases:
    /// - Employee bonus vesting after 1 year
    /// - Escrow for property purchase
    /// - Timed savings accounts
    /// - Contest prize distribution
    public struct TimeLock has key, store {
        id: UID,
        /// The owner who can withdraw after unlock_time
        owner: address,
        /// Unix timestamp (in milliseconds) when funds can be withdrawn
        unlock_time: u64,
        /// The locked balance (in MIST, 1 SUI = 10^9 MIST)
        balance: u64,
        /// Whether funds have been withdrawn
        is_withdrawn: bool,
    }

    /// Creates a new time-locked vault
    /// 
    /// Build a time-locked vault where funds can't be withdrawn until a future time.
    /// Similar to an escrow or savings account with withdrawal restrictions.
    /// 
    /// Implementation Requirements:
    /// - Validate lock_duration_ms > 0 (abort with EInvalidLockDuration)
    /// - Get current blockchain time using clock::timestamp_ms()
    /// - Calculate unlock_time = current_time + lock_duration_ms
    /// - Extract coin value and convert to balance using coin::into_balance()
    /// - For testing: destroy the balance and store just the u64 value
    /// - Create TimeLock with: id, owner, unlock_time, balance, is_withdrawn
    /// - Transfer the TimeLock object to the sender
    public fun create_time_lock(
        payment: Coin<SUI>,
        lock_duration_ms: u64,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        // Your implementation here
        // REMOVE this temporary line:
        transfer::public_transfer(payment, tx_context::sender(ctx));
    }

    /// Withdraws funds from the time lock if unlock_time has passed
    /// 
    /// Allow the owner to withdraw their locked funds after the time period expires.
    /// Like withdrawing from a savings account after the lock period ends.
    /// 
    /// Security Validations:
    /// - Verify sender is the owner (abort with ENotOwner)
    /// - Current time must be >= unlock_time (abort with EStillLocked)
    /// - Funds can only be withdrawn once (abort with EAlreadyWithdrawn)
    /// 
    /// Implementation:
    /// - Get current time from Clock
    /// - Perform all security checks
    /// - Create Coin from balance: balance::create_for_testing() + coin::from_balance()
    /// - Mark is_withdrawn = true
    /// - Transfer coin to owner
    public fun withdraw(
        time_lock: &mut TimeLock,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        // Your implementation here
    }

    /// Destroys an empty time lock (after withdrawal)
    /// 
    /// Clean up the TimeLock object after funds have been withdrawn.
    /// Like closing an empty account to free up storage.
    /// 
    /// Security Requirements:
    /// - Only owner can destroy
    /// - Can only destroy if funds have been withdrawn
    /// 
    /// Implementation:
    /// - Verify time_lock.is_withdrawn is true
    /// - Verify sender is owner
    /// - Unpack the TimeLock struct
    /// - Delete the UID using object::delete()
    public fun destroy(time_lock: TimeLock, ctx: &TxContext) {
        // Your implementation here
        let TimeLock { id, owner: _, unlock_time: _, balance: _, is_withdrawn: _ } = time_lock;
        object::delete(id);
    }

    // ==================== Getter Functions ====================

    /// Returns the owner of the time lock
    public fun owner(time_lock: &TimeLock): address {
        time_lock.owner
    }

    /// Returns the unlock timestamp (in milliseconds)
    public fun unlock_time(time_lock: &TimeLock): u64 {
        time_lock.unlock_time
    }

    /// Returns the locked balance
    public fun balance(time_lock: &TimeLock): u64 {
        time_lock.balance
    }

    /// Returns whether funds have been withdrawn
    public fun is_withdrawn(time_lock: &TimeLock): bool {
        time_lock.is_withdrawn
    }

    /// Returns remaining time until unlock (0 if already unlocked)
    public fun time_until_unlock(time_lock: &TimeLock, clock: &Clock): u64 {
        let current_time = clock::timestamp_ms(clock);
        if (current_time >= time_lock.unlock_time) {
            0
        } else {
            time_lock.unlock_time - current_time
        }
    }
}

#[test_only]
module suilings::time_lock_tests {
    use suilings::time_lock::{Self, TimeLock};
    use sui::test_scenario;
    use sui::clock::{Self, Clock};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;

    #[test]
    fun test_create_time_lock() {
        let user = @0xA;
        let mut scenario = test_scenario::begin(user);
        
        // Create clock
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));
        clock::set_for_testing(&mut clock, 1000); // Set to 1 second

        // Create payment
        test_scenario::next_tx(&mut scenario, user);
        {
            let payment = coin::mint_for_testing<SUI>(1000000000, test_scenario::ctx(&mut scenario)); // 1 SUI
            time_lock::create_time_lock(
                payment,
                5000, // Lock for 5 seconds
                &clock,
                test_scenario::ctx(&mut scenario)
            );
        };

        // Verify TimeLock created
        test_scenario::next_tx(&mut scenario, user);
        {
            let time_lock = test_scenario::take_from_sender<TimeLock>(&scenario);
            assert!(time_lock::owner(&time_lock) == user, 0);
            assert!(time_lock::unlock_time(&time_lock) == 6000, 1); // 1000 + 5000
            assert!(time_lock::balance(&time_lock) == 1000000000, 2);
            assert!(!time_lock::is_withdrawn(&time_lock), 3);
            test_scenario::return_to_sender(&scenario, time_lock);
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = time_lock::EStillLocked)]
    fun test_withdraw_before_unlock_fails() {
        let user = @0xA;
        let mut scenario = test_scenario::begin(user);
        
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));
        clock::set_for_testing(&mut clock, 1000);

        test_scenario::next_tx(&mut scenario, user);
        {
            let payment = coin::mint_for_testing<SUI>(1000000000, test_scenario::ctx(&mut scenario));
            time_lock::create_time_lock(payment, 5000, &clock, test_scenario::ctx(&mut scenario));
        };

        // Try to withdraw immediately (should fail)
        test_scenario::next_tx(&mut scenario, user);
        {
            let mut time_lock = test_scenario::take_from_sender<TimeLock>(&scenario);
            clock::set_for_testing(&mut clock, 3000); // Only 2 seconds passed
            time_lock::withdraw(&mut time_lock, &clock, test_scenario::ctx(&mut scenario)); // Should abort
            test_scenario::return_to_sender(&scenario, time_lock);
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_successful_withdraw() {
        let user = @0xA;
        let mut scenario = test_scenario::begin(user);
        
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));
        clock::set_for_testing(&mut clock, 1000);

        test_scenario::next_tx(&mut scenario, user);
        {
            let payment = coin::mint_for_testing<SUI>(1000000000, test_scenario::ctx(&mut scenario));
            time_lock::create_time_lock(payment, 5000, &clock, test_scenario::ctx(&mut scenario));
        };

        // Advance time and withdraw
        test_scenario::next_tx(&mut scenario, user);
        {
            let mut time_lock = test_scenario::take_from_sender<TimeLock>(&scenario);
            clock::set_for_testing(&mut clock, 7000); // 6 seconds passed
            time_lock::withdraw(&mut time_lock, &clock, test_scenario::ctx(&mut scenario));
            assert!(time_lock::is_withdrawn(&time_lock), 0);
            test_scenario::return_to_sender(&scenario, time_lock);
        };

        // Verify coin received
        test_scenario::next_tx(&mut scenario, user);
        {
            let withdrawn_coin = test_scenario::take_from_sender<Coin<SUI>>(&scenario);
            assert!(coin::value(&withdrawn_coin) == 1000000000, 0);
            test_scenario::return_to_sender(&scenario, withdrawn_coin);
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = time_lock::EInvalidLockDuration)]
    fun test_zero_lock_duration_fails() {
        let user = @0xA;
        let mut scenario = test_scenario::begin(user);
        
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));
        clock::set_for_testing(&mut clock, 1000);

        test_scenario::next_tx(&mut scenario, user);
        {
            let payment = coin::mint_for_testing<SUI>(1000000000, test_scenario::ctx(&mut scenario));
            time_lock::create_time_lock(payment, 0, &clock, test_scenario::ctx(&mut scenario)); // Should fail
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }
}

