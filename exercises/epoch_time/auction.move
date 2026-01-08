// Exercise: Epoch and Time - Dutch Auction
//
// Build a Dutch auction where price decreases over time until someone buys.
// Used for NFT sales, IPO pricing, and fair price discovery.
//
// Stuck? Check out: https://move-book.com/programmability/epoch-and-time.html

module suilings::auction {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::clock::{Self, Clock};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::balance::{Self, Balance};

    // Error constants
    const EAuctionNotStarted: u64 = 1;
    const EAuctionEnded: u64 = 2;
    const EInsufficientPayment: u64 = 3;
    const ENotSeller: u64 = 4;
    const EAuctionNotEnded: u64 = 5;
    const EInvalidAuctionParams: u64 = 6;
    const EAlreadySold: u64 = 7;

    /// A Dutch auction where price decreases linearly over time
    public struct DutchAuction has key {
        id: UID,
        seller: address,
        item_name: vector<u8>,
        starting_price: u64,
        reserve_price: u64,
        start_time: u64,
        end_time: u64,
        is_sold: bool,
        proceeds: Balance<SUI>,
    }

    /// Creates a new Dutch auction
    /// 
    /// Build a Dutch auction where price decreases over time until someone buys.
    /// Used for NFT sales, IPO pricing, and fair price discovery.
    /// First buyer at any price wins.
    /// 
    /// Implementation Requirements:
    /// - Validate starting_price > reserve_price (abort with EInvalidAuctionParams)
    /// - Validate start_time < end_time (abort with EInvalidAuctionParams)
    /// - Create DutchAuction with: id, seller, item_name, prices, times, is_sold (false), proceeds (empty)
    /// - Share the auction using transfer::share_object() (anyone can buy)
    public fun create_auction(
        item_name: vector<u8>,
        starting_price: u64,
        reserve_price: u64,
        start_time: u64,
        end_time: u64,
        ctx: &mut TxContext
    ) {
        // Your implementation here
    }

    /// Calculates the current price based on time elapsed
    /// 
    /// Calculate linearly decreasing price for Dutch auction.
    /// Example: 100 SUI → 10 SUI over 10 min. At 5 min = 55 SUI.
    /// 
    /// Pricing Formula:
    /// - Before start: starting_price
    /// - After end: reserve_price
    /// - During: starting_price - (price_drop * elapsed / duration)
    /// 
    /// Implementation:
    /// - Get current time from Clock
    /// - Handle edge cases: before start, after end
    /// - Calculate: price_drop = starting_price - reserve_price
    /// - Calculate: price_decrease = (price_drop * elapsed_time) / total_duration
    /// - Return: starting_price - price_decrease (ensure >= reserve_price)
    public fun calculate_current_price(auction: &DutchAuction, clock: &Clock): u64 {
        // Your implementation here
        0 // Placeholder
    }

    /// Buys the item at the current price
    /// 
    /// Purchase the item at the current price. First buyer wins.
    /// Overpayment is automatically refunded.
    /// 
    /// Security Validations:
    /// - Auction must have started (abort with EAuctionNotStarted)
    /// - Auction must not have ended (abort with EAuctionEnded)
    /// - Item must not be sold (abort with EAlreadySold)
    /// - Payment must be >= current_price (abort with EInsufficientPayment)
    /// 
    /// Implementation:
    /// - Calculate current_price using calculate_current_price()
    /// - Split payment: coin::split(&mut payment, current_price, ctx)
    /// - Add price to proceeds: balance::join(&mut auction.proceeds, price_balance)
    /// - Handle refund: transfer if > 0, coin::destroy_zero() if empty
    /// - Mark auction.is_sold = true
    public fun buy(
        auction: &mut DutchAuction,
        mut payment: Coin<SUI>,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        // Your implementation here
    }

    /// Allows seller to claim proceeds after successful sale
    /// 
    /// Seller collects payment after the item is sold.
    /// Proceeds are safely stored in auction until claimed.
    /// 
    /// Security Requirements:
    /// - Only seller can claim (abort with ENotSeller)
    /// - Item must be sold (abort with EAuctionNotEnded)
    /// 
    /// Implementation:
    /// - Verify sender is seller
    /// - Verify auction.is_sold is true
    /// - Withdraw all proceeds: balance::withdraw_all(&mut auction.proceeds)
    /// - Convert to Coin: coin::from_balance()
    /// - Transfer to seller
    public fun claim_proceeds(
        auction: &mut DutchAuction,
        ctx: &mut TxContext
    ) {
        // Your implementation here
    }

    /// Allows seller to cancel/withdraw auction if not sold and ended
    /// 
    /// Seller can cancel the auction before it starts or after it ends without a sale.
    /// 
    /// Security Requirements:
    /// - Only seller can cancel
    /// - Auction must not be sold
    /// - Must be either before start_time or after end_time
    public fun cancel_auction(
        auction: &DutchAuction,
        clock: &Clock,
        ctx: &TxContext
    ) {
        // Your implementation here
    }

    // ==================== Getter Functions ====================

    public fun seller(auction: &DutchAuction): address {
        auction.seller
    }

    public fun item_name(auction: &DutchAuction): vector<u8> {
        auction.item_name
    }

    public fun starting_price(auction: &DutchAuction): u64 {
        auction.starting_price
    }

    public fun reserve_price(auction: &DutchAuction): u64 {
        auction.reserve_price
    }

    public fun start_time(auction: &DutchAuction): u64 {
        auction.start_time
    }

    public fun end_time(auction: &DutchAuction): u64 {
        auction.end_time
    }

    public fun is_sold(auction: &DutchAuction): bool {
        auction.is_sold
    }

    public fun proceeds_amount(auction: &DutchAuction): u64 {
        balance::value(&auction.proceeds)
    }

    public fun time_remaining(auction: &DutchAuction, clock: &Clock): u64 {
        let current_time = clock::timestamp_ms(clock);
        if (current_time >= auction.end_time) {
            0
        } else {
            auction.end_time - current_time
        }
    }

    public fun auction_progress_percent(auction: &DutchAuction, clock: &Clock): u64 {
        let current_time = clock::timestamp_ms(clock);
        
        if (current_time < auction.start_time) {
            return 0
        };
        
        if (current_time >= auction.end_time) {
            return 100
        };
        
        let elapsed = current_time - auction.start_time;
        let duration = auction.end_time - auction.start_time;
        (elapsed * 100) / duration
    }
}

#[test_only]
module suilings::auction_tests {
    use suilings::auction::{Self, DutchAuction};
    use sui::test_scenario;
    use sui::clock::{Self, Clock};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;

    const SELLER: address = @0xCAFE;
    const BUYER: address = @0xBEEF;
    const ONE_SUI: u64 = 1_000_000_000;

    #[test]
    fun test_create_auction() {
        let mut scenario = test_scenario::begin(SELLER);
        let clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            auction::create_auction(
                b"Rare NFT",
                100 * ONE_SUI,
                10 * ONE_SUI,
                1000,
                11000,
                test_scenario::ctx(&mut scenario)
            );
        };

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let auction_obj = test_scenario::take_shared<DutchAuction>(&scenario);
            assert!(auction::seller(&auction_obj) == SELLER, 0);
            assert!(auction::starting_price(&auction_obj) == 100 * ONE_SUI, 1);
            assert!(auction::reserve_price(&auction_obj) == 10 * ONE_SUI, 2);
            assert!(!auction::is_sold(&auction_obj), 3);
            test_scenario::return_shared(auction_obj);
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_price_decreases_over_time() {
        let mut scenario = test_scenario::begin(SELLER);
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            auction::create_auction(
                b"Item",
                100 * ONE_SUI,
                10 * ONE_SUI,
                1000,
                11000,
                test_scenario::ctx(&mut scenario)
            );
        };

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let auction_obj = test_scenario::take_shared<DutchAuction>(&scenario);
            
            clock::set_for_testing(&mut clock, 1000);
            assert!(auction::calculate_current_price(&auction_obj, &clock) == 100 * ONE_SUI, 0);
            
            clock::set_for_testing(&mut clock, 6000);
            let mid_price = auction::calculate_current_price(&auction_obj, &clock);
            assert!(mid_price >= 54 * ONE_SUI && mid_price <= 56 * ONE_SUI, 1);
            
            clock::set_for_testing(&mut clock, 11000);
            assert!(auction::calculate_current_price(&auction_obj, &clock) == 10 * ONE_SUI, 2);
            
            test_scenario::return_shared(auction_obj);
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_successful_purchase() {
        let mut scenario = test_scenario::begin(SELLER);
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            auction::create_auction(b"Item", 100 * ONE_SUI, 10 * ONE_SUI, 1000, 11000, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let mut auction_obj = test_scenario::take_shared<DutchAuction>(&scenario);
            clock::set_for_testing(&mut clock, 6000);
            
            let payment = coin::mint_for_testing<SUI>(60 * ONE_SUI, test_scenario::ctx(&mut scenario));
            auction::buy(&mut auction_obj, payment, &clock, test_scenario::ctx(&mut scenario));
            
            assert!(auction::is_sold(&auction_obj), 0);
            test_scenario::return_shared(auction_obj);
        };

        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let refund = test_scenario::take_from_sender<Coin<SUI>>(&scenario);
            assert!(coin::value(&refund) >= 4 * ONE_SUI, 0);
            test_scenario::return_to_sender(&scenario, refund);
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_seller_claims_proceeds() {
        let mut scenario = test_scenario::begin(SELLER);
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            auction::create_auction(b"Item", 100 * ONE_SUI, 10 * ONE_SUI, 1000, 11000, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let mut auction_obj = test_scenario::take_shared<DutchAuction>(&scenario);
            clock::set_for_testing(&mut clock, 1000);
            let payment = coin::mint_for_testing<SUI>(100 * ONE_SUI, test_scenario::ctx(&mut scenario));
            auction::buy(&mut auction_obj, payment, &clock, test_scenario::ctx(&mut scenario));
            test_scenario::return_shared(auction_obj);
        };

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let mut auction_obj = test_scenario::take_shared<DutchAuction>(&scenario);
            auction::claim_proceeds(&mut auction_obj, test_scenario::ctx(&mut scenario));
            test_scenario::return_shared(auction_obj);
        };

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let proceeds = test_scenario::take_from_sender<Coin<SUI>>(&scenario);
            assert!(coin::value(&proceeds) == 100 * ONE_SUI, 0);
            test_scenario::return_to_sender(&scenario, proceeds);
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = auction::EInsufficientPayment)]
    fun test_insufficient_payment_fails() {
        let mut scenario = test_scenario::begin(SELLER);
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            auction::create_auction(b"Item", 100 * ONE_SUI, 10 * ONE_SUI, 1000, 11000, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let mut auction_obj = test_scenario::take_shared<DutchAuction>(&scenario);
            clock::set_for_testing(&mut clock, 1000);
            let payment = coin::mint_for_testing<SUI>(50 * ONE_SUI, test_scenario::ctx(&mut scenario));
            auction::buy(&mut auction_obj, payment, &clock, test_scenario::ctx(&mut scenario));
            test_scenario::return_shared(auction_obj);
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = auction::EAuctionNotStarted)]
    fun test_buy_before_start_fails() {
        let mut scenario = test_scenario::begin(SELLER);
        let mut clock = clock::create_for_testing(test_scenario::ctx(&mut scenario));
        clock::set_for_testing(&mut clock, 500);

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            auction::create_auction(b"Item", 100 * ONE_SUI, 10 * ONE_SUI, 1000, 11000, test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let mut auction_obj = test_scenario::take_shared<DutchAuction>(&scenario);
            let payment = coin::mint_for_testing<SUI>(100 * ONE_SUI, test_scenario::ctx(&mut scenario));
            auction::buy(&mut auction_obj, payment, &clock, test_scenario::ctx(&mut scenario));
            test_scenario::return_shared(auction_obj);
        };

        clock::destroy_for_testing(clock);
        test_scenario::end(scenario);
    }
}
