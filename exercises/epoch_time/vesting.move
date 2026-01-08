// Exercise: Epoch and Time - Token Vesting Schedule
//
// Build a linear token vesting schedule where tokens unlock gradually over time.
// Used for employee compensation, investor unlocks, or founder shares.
//
// Stuck? Check out: https://move-book.com/programmability/epoch-and-time.html

module suilings::vesting {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::clock::{Self, Clock};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};

    // Error constants
    const ENotBeneficiary: u64 = 1;
    const EVestingNotStarted: u64 = 2;
    const ENoTokensVested: u64 = 3;
    const EInsufficientBalance: u64 = 4;
    const EInvalidVestingSchedule: u64 = 5;

    /// A vesting schedule that releases tokens linearly over time
    /// Business Context: Employee stock options, investor token unlocks, 
    /// or any scenario where assets are released gradually over time.
    /// 
    /// Real-world Use Cases:
    /// - Employee compensation (4-year vesting, 1-year cliff)
    /// - Investor token unlocks (25% at TGE, rest over 18 months)
    /// - Founder shares (3-year vesting)
    /// - Partnership agreements (milestone-based releases)
    /// 
    /// Vesting Mechanics:
    /// - start_time: When vesting begins
    /// - end_time: When 100% is vested
    /// - total_amount: Total tokens to be vested
    /// - claimed_amount: How much has been withdrawn
    /// - Linear release: vested_amount = total * (current_time - start_time) / (end_time - start_time)
    public struct VestingSchedule has key {
        id: UID,
        /// The beneficiary who can claim vested tokens
        beneficiary: address,
        /// Total balance to be vested (stored as Balance<SUI> for proper handling)
        balance: Balance<SUI>,
        /// Amount already claimed
        claimed_amount: u64,
        /// When vesting starts (unix timestamp in milliseconds)
        start_time: u64,
        /// When vesting ends (100% vested)
        end_time: u64,
    }

    /// Creates a new vesting schedule
    /// 
    /// Set up a linear token vesting schedule where tokens unlock gradually over time.
    /// Used for employee compensation, investor unlocks, or founder shares.
    /// Example: 100 SUI vesting over 12 months.
    /// 
    /// Implementation Requirements:
    /// - Validate start_time < end_time (abort with EInvalidVestingSchedule)
    /// - Convert Coin<SUI> to Balance<SUI> using coin::into_balance()
    /// - Create VestingSchedule with: id, beneficiary, balance, claimed_amount (0), start_time, end_time
    /// - Transfer ownership to beneficiary using transfer::transfer()
    public fun create_vesting(
        beneficiary: address,
        payment: Coin<SUI>,
        start_time: u64,
        end_time: u64,
        ctx: &mut TxContext
    ) {
        // Your implementation here
    }

    /// Calculates how many tokens have vested at the current time
    /// 
    /// Calculate linear vesting: tokens unlock proportionally over time.
    /// Example: 100 tokens over 10 days = 30 tokens vested after 3 days.
    /// 
    /// Vesting Formula:
    /// - Before start_time: return 0
    /// - After end_time: return total_amount
    /// - In between: total_amount * (elapsed / duration)
    /// 
    /// Implementation:
    /// - Get current time from Clock
    /// - Calculate total_amount = balance::value() + claimed_amount
    /// - Handle edge cases (before start, after end)
    /// - For linear vesting: (total * elapsed_time) / total_duration
    public fun calculate_vested_amount(schedule: &VestingSchedule, clock: &Clock): u64 {
        // Your implementation here
        0 // Placeholder
    }

    /// Claims vested tokens
    /// 
    /// Allow beneficiary to withdraw tokens that have vested.
    /// Example: 30 vested, 10 claimed → can claim up to 20 more.
    /// 
    /// Security Validations:
    /// - Only beneficiary can claim (abort with ENotBeneficiary)
    /// - Vesting must have started (abort with EVestingNotStarted)
    /// - Must have tokens available to claim (abort with ENoTokensVested)
    /// - Amount must not exceed claimable (abort with EInsufficientBalance)
    /// 
    /// Implementation:
    /// - Calculate vested_amount using calculate_vested_amount()
    /// - Calculate claimable = vested_amount - claimed_amount
    /// - Split amount from balance using balance::split()
    /// - Convert to Coin using coin::from_balance()
    /// - Update claimed_amount
    /// - Transfer coin to beneficiary
    public fun claim_vested(
        schedule: &mut VestingSchedule,
        amount: u64,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        // Your implementation here
    }

    /// Claims all vested tokens at once (convenience function)
    public fun claim_all_vested(
        schedule: &mut VestingSchedule,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let vested_amount = calculate_vested_amount(schedule, clock);
        let claimable = vested_amount - schedule.claimed_amount;
        
        if (claimable > 0) {
            claim_vested(schedule, claimable, clock, ctx);
        }
    }

    // ==================== Getter Functions ====================

    /// Returns the beneficiary address
    public fun beneficiary(schedule: &VestingSchedule): address {
        schedule.beneficiary
    }

    /// Returns the total vesting amount (remaining + claimed)
    public fun total_amount(schedule: &VestingSchedule): u64 {
        balance::value(&schedule.balance) + schedule.claimed_amount
    }

    /// Returns the remaining balance
    public fun remaining_balance(schedule: &VestingSchedule): u64 {
        balance::value(&schedule.balance)
    }

    /// Returns the amount already claimed
    public fun claimed_amount(schedule: &VestingSchedule): u64 {
        schedule.claimed_amount
    }

    /// Returns the vesting start time
    public fun start_time(schedule: &VestingSchedule): u64 {
        schedule.start_time
    }

    /// Returns the vesting end time
    public fun end_time(schedule: &VestingSchedule): u64 {
        schedule.end_time
    }

    /// Returns the claimable amount at current time
    public fun claimable_amount(schedule: &VestingSchedule, clock: &Clock): u64 {
        let vested = calculate_vested_amount(schedule, clock);
        vested - schedule.claimed_amount
    }

    /// Returns the vesting progress as a percentage (0-100)
    public fun vesting_progress_percent(schedule: &VestingSchedule, clock: &Clock): u64 {
        let current_time = clock::timestamp_ms(clock);
        
        if (current_time < schedule.start_time) {
            return 0
        };
        
        if (current_time >= schedule.end_time) {
            return 100
        };
        
        let elapsed = current_time - schedule.start_time;
        let duration = schedule.end_time - schedule.start_time;
        (elapsed * 100) / duration
    }
}

#[test_only]
module suilings::vesting_tests {
    use suilings::vesting::{Self, VestingSchedule};
    use sui::test_scenario;
    use sui::clock::{Self, Clock};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;

    const BENEFICIARY: address = @0xBEEF;
    const ONE_SUI: u64 = 1_000_000_000; // 1 SUI in MIST

    #[test]
    fun test_create_vesting() {
        let creator = @0xA;
        let mut scenario = test_scenario::begin(creator);
        
        let clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, creator);
        {
            let payment = coin::mint_for_testing<SUI>(100 * ONE_SUI, test_scenario::ctx(&mut scenario));
            vesting::create_vesting(
                BENEFICIARY,
                payment,
                1000, // start at 1 second
                11000, // end at 11 seconds (10 second duration)
                test_scenario::ctx(&mut scenario)
            );
        };

        // Verify VestingSchedule created
        test_scenario::next_tx(&mut scenario, BENEFICIARY);
        {
            let schedule = test_scenario::take_from_sender<VestingSchedule>(&scenario);
            assert!(vesting::beneficiary(&schedule) == BENEFICIARY, 0);
            assert!(vesting::total_amount(&schedule) == 100 * ONE_SUI, 1);
            assert!(vesting::claimed_amount(&schedule) == 0, 2);
            assert!(vesting::start_time(&schedule) == 1000, 3);
            assert!(vesting::end_time(&schedule) == 11000, 4);
            test_scenario::return_to_sender(&scenario, schedule);
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_linear_vesting() {
        let creator = @0xA;
        let mut scenario = test_scenario::begin(creator);
        
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, creator);
        {
            let payment = coin::mint_for_testing<SUI>(100 * ONE_SUI, test_scenario::ctx(&mut scenario));
            vesting::create_vesting(BENEFICIARY, payment, 1000, 11000, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, BENEFICIARY);
        {
            let schedule = test_scenario::take_from_sender<VestingSchedule>(&scenario);
            
            // At start: 0% vested
            clock::set_for_testing(&mut clock, 1000);
            assert!(vesting::calculate_vested_amount(&schedule, &clock) == 0, 0);
            
            // At 25% duration: 25 SUI vested
            clock::set_for_testing(&mut clock, 3500); // 1000 + 2500 (25% of 10000)
            assert!(vesting::calculate_vested_amount(&schedule, &clock) == 25 * ONE_SUI, 1);
            
            // At 50% duration: 50 SUI vested
            clock::set_for_testing(&mut clock, 6000); // 1000 + 5000
            assert!(vesting::calculate_vested_amount(&schedule, &clock) == 50 * ONE_SUI, 2);
            
            // At 100% duration: 100 SUI vested
            clock::set_for_testing(&mut clock, 11000);
            assert!(vesting::calculate_vested_amount(&schedule, &clock) == 100 * ONE_SUI, 3);
            
            test_scenario::return_to_sender(&scenario, schedule);
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_claim_vested_tokens() {
        let creator = @0xA;
        let mut scenario = test_scenario::begin(creator);
        
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));
        clock::set_for_testing(&mut clock, 1000);

        test_scenario::next_tx(&mut scenario, creator);
        {
            let payment = coin::mint_for_testing<SUI>(100 * ONE_SUI, test_scenario::ctx(&mut scenario));
            vesting::create_vesting(BENEFICIARY, payment, 1000, 11000, test_scenario::ctx(&mut scenario));
        };

        // Claim 25% after 25% time elapsed
        test_scenario::next_tx(&mut scenario, BENEFICIARY);
        {
            let mut schedule = test_scenario::take_from_sender<VestingSchedule>(&scenario);
            clock::set_for_testing(&mut clock, 3500);
            vesting::claim_vested(&mut schedule, 25 * ONE_SUI, &clock, test_scenario::ctx(&mut scenario));
            assert!(vesting::claimed_amount(&schedule) == 25 * ONE_SUI, 0);
            test_scenario::return_to_sender(&scenario, schedule);
        };

        // Verify coin received
        test_scenario::next_tx(&mut scenario, BENEFICIARY);
        {
            let claimed_coin = test_scenario::take_from_sender<Coin<SUI>>(&scenario);
            assert!(coin::value(&claimed_coin) == 25 * ONE_SUI, 0);
            test_scenario::return_to_sender(&scenario, claimed_coin);
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = vesting::EVestingNotStarted)]
    fun test_claim_before_start_fails() {
        let creator = @0xA;
        let mut scenario = test_scenario::begin(creator);
        
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));
        clock::set_for_testing(&mut clock, 500); // Before start

        test_scenario::next_tx(&mut scenario, creator);
        {
            let payment = coin::mint_for_testing<SUI>(100 * ONE_SUI, test_scenario::ctx(&mut scenario));
            vesting::create_vesting(BENEFICIARY, payment, 1000, 11000, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, BENEFICIARY);
        {
            let mut schedule = test_scenario::take_from_sender<VestingSchedule>(&scenario);
            vesting::claim_vested(&mut schedule, 10 * ONE_SUI, &clock, test_scenario::ctx(&mut scenario)); // Should fail
            test_scenario::return_to_sender(&scenario, schedule);
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = vesting::EInsufficientBalance)]
    fun test_claim_more_than_vested_fails() {
        let creator = @0xA;
        let mut scenario = test_scenario::begin(creator);
        
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, creator);
        {
            let payment = coin::mint_for_testing<SUI>(100 * ONE_SUI, test_scenario::ctx(&mut scenario));
            vesting::create_vesting(BENEFICIARY, payment, 1000, 11000, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, BENEFICIARY);
        {
            let mut schedule = test_scenario::take_from_sender<VestingSchedule>(&scenario);
            clock::set_for_testing(&mut clock, 3500); // 25% vested
            vesting::claim_vested(&mut schedule, 50 * ONE_SUI, &clock, test_scenario::ctx(&mut scenario)); // Try to claim 50%, should fail
            test_scenario::return_to_sender(&scenario, schedule);
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }
}

