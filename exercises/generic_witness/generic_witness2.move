// Exercise: Generic Witness - Delegatable Authorization
//
// Build an authorization system using transferable witness objects for delegatable access control.
// Witness objects can be transferred to delegate authority while maintaining type safety.
//
// Stuck? Check out: https://move-book.com/programmability/witness-pattern.html


module suilings::marketplace {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::vec_map::{Self, VecMap};

    // Error codes
    const ENotAuthorized: u64 = 1;
    const EListingNotFound: u64 = 2;
    const EInsufficientPayment: u64 = 3;
    const EInvalidWitness: u64 = 4;
    const EAlreadyListed: u64 = 5;

    /// Marketplace for trading items
    public struct Marketplace has key {
        id: UID,
        listings: VecMap<address, u64>, // item ID -> price
        admin: address,
    }

    /// Transferable witness proving marketplace authority
    /// Can be held and used multiple times
    /// Generic parameter T represents the type of authority
    public struct MarketplaceAuthority<phantom T> has key, store {
        id: UID,
        authority_type: vector<u8>,
    }

    /// An item that can be listed and sold
    public struct Item<phantom T> has key, store {
        id: UID,
        name: vector<u8>,
        creator: address,
    }

    /// Launch your NFT marketplace with delegatable seller authority
    /// 
    /// You're building an NFT marketplace. You want to give "Verified Seller" badges
    /// to trusted creators. Unlike one-time witnesses, these badges can be transferred
    /// (give to employee) and reused (mint multiple collections). Each badge type
    /// (ArtBadge, GameBadge) can only create items of that category.
    /// 
    /// Real-world: Blur, OpenSea give verified badges to official collections.
    ///
    /// Implementation Requirements:
    /// - Create Marketplace with new UID and empty VecMap for listings
    /// - Set admin = sender
    /// - Share marketplace (public marketplace)
    /// - Create MarketplaceAuthority<W> (the transferable badge)
    /// - Transfer authority to sender (they can delegate it later)
    public fun create_marketplace<W: drop>(
        _witness: W,
        authority_type: vector<u8>,
        ctx: &mut TxContext
    ) {
        // Your implementation here
    }

    /// Create an NFT using your verified seller badge
    /// 
    /// You hold a MarketplaceAuthority<ArtBadge>. This proves you're a verified artist.
    /// You can mint unlimited NFTs - each one is of type Item<ArtBadge>. Buyers know
    /// it's authentic because only ArtBadge holders can create Item<ArtBadge>.
    /// If you hire a helper, you transfer them the badge - they can mint for you!
    ///
    /// Implementation Requirements:
    /// - Create Item<T> with new UID, name, creator=sender
    /// - Transfer item to creator (you own the NFT you minted)
    public fun create_item<T>(
        _authority: &MarketplaceAuthority<T>,
        name: vector<u8>,
        ctx: &mut TxContext
    ) {
        // Your implementation here
    }

    /// List an item for sale
    /// 
    /// Listing Operations:
    /// - Item must have store ability to be held
    /// - Convert item UID to address for tracking
    /// - Store price in marketplace
    ///
    /// Implementation Requirements:
    /// - Get item_addr = object::uid_to_address(&item.id)
    /// - Check !vec_map::contains(&marketplace.listings, &item_addr)
    /// - Abort with EAlreadyListed if already listed
    /// - Insert: vec_map::insert(&mut marketplace.listings, item_addr, price)
    /// - Transfer item to marketplace object (transfer::public_transfer to object address)
    public fun list_item<T>(
        marketplace: &mut Marketplace,
        item: Item<T>,
        price: u64,
        _ctx: &TxContext
    ) {
        // Your implementation here
        transfer::public_transfer(item, @0x0);
    }

    /// Buy a listed item
    /// 
    /// Purchase Flow:
    /// - Verify listing exists and payment is sufficient
    /// - Remove from listings
    /// - Accept payment
    /// - Transfer item to buyer
    ///
    /// Implementation Requirements:
    /// - Get item_addr = object::uid_to_address(&item.id)
    /// - Check vec_map::contains(&marketplace.listings, &item_addr)
    /// - Abort with EListingNotFound if not listed
    /// - Get price: *vec_map::get(&marketplace.listings, &item_addr)
    /// - Check coin::value(&payment) >= price
    /// - Abort with EInsufficientPayment if insufficient
    /// - Remove listing: vec_map::remove(&mut marketplace.listings, &item_addr)
    /// - Transfer payment to marketplace admin
    /// - Transfer item to buyer
    public fun buy_item<T>(
        marketplace: &mut Marketplace,
        item: Item<T>,
        payment: Coin<SUI>,
        ctx: &TxContext
    ) {
        // Your implementation here
        transfer::public_transfer(item, @0x0);
        transfer::public_transfer(payment, @0x0);
    }

    /// Delist an item (remove from sale)
    /// 
    /// Authorization:
    /// - Only item creator can delist
    /// - Removes from marketplace and returns to creator
    ///
    /// Implementation Requirements:
    /// - Get item_addr = object::uid_to_address(&item.id)
    /// - Check vec_map::contains(&marketplace.listings, &item_addr)
    /// - Abort with EListingNotFound if not listed
    /// - Check item.creator == tx_context::sender(ctx)
    /// - Abort with ENotAuthorized if not creator
    /// - Remove listing
    /// - Transfer item back to creator
    public fun delist_item<T>(
        marketplace: &mut Marketplace,
        item: Item<T>,
        ctx: &TxContext
    ) {
        // Your implementation here
        transfer::public_transfer(item, @0x0);
    }

    /// Check if an item is listed
    /// 
    /// Implementation Requirements:
    /// - Get item_addr = object::uid_to_address(&item.id)
    /// - Return vec_map::contains(&marketplace.listings, &item_addr)
    public fun is_listed<T>(marketplace: &Marketplace, item: &Item<T>): bool {
        // Your implementation here
        false
    }

    /// Get listing price
    /// 
    /// Implementation Requirements:
    /// - Get item_addr = object::uid_to_address(&item.id)
    /// - Check vec_map::contains()
    /// - Abort with EListingNotFound if not found
    /// - Return *vec_map::get(&marketplace.listings, &item_addr)
    public fun get_price<T>(marketplace: &Marketplace, item: &Item<T>): u64 {
        // Your implementation here
        0
    }

    // Getter functions
    public fun item_name<T>(item: &Item<T>): vector<u8> { item.name }
    public fun item_creator<T>(item: &Item<T>): address { item.creator }
    public fun authority_type<T>(auth: &MarketplaceAuthority<T>): vector<u8> { auth.authority_type }
}

#[test_only]
module suilings::marketplace_tests {
    use suilings::marketplace::{Self, Marketplace, MarketplaceAuthority, Item};
    use sui::test_scenario;
    use sui::coin;
    use sui::sui::SUI;

    const ADMIN: address = @0xAD;
    const SELLER: address = @0x01;
    const BUYER: address = @0x02;

    // Test witness
    public struct COLLECTION has drop {}

    #[test]
    fun test_create_marketplace() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            marketplace::create_marketplace(
                COLLECTION {},
                b"NFT Collection",
                test_scenario::ctx(&mut scenario)
            );
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let marketplace = test_scenario::take_shared<Marketplace>(&scenario);
            let authority = test_scenario::take_from_sender<MarketplaceAuthority<COLLECTION>>(&scenario);
            
            assert!(marketplace::authority_type(&authority) == b"NFT Collection", 0);
            
            test_scenario::return_shared(marketplace);
            test_scenario::return_to_sender(&scenario, authority);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_create_item() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            marketplace::create_marketplace(
                COLLECTION {},
                b"Collection",
                test_scenario::ctx(&mut scenario)
            );
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let authority = test_scenario::take_from_sender<MarketplaceAuthority<COLLECTION>>(&scenario);
            
            marketplace::create_item(
                &authority,
                b"Item #1",
                test_scenario::ctx(&mut scenario)
            );
            
            test_scenario::return_to_sender(&scenario, authority);
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let item = test_scenario::take_from_sender<Item<COLLECTION>>(&scenario);
            assert!(marketplace::item_name(&item) == b"Item #1", 0);
            assert!(marketplace::item_creator(&item) == ADMIN, 1);
            test_scenario::return_to_sender(&scenario, item);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_list_and_buy_item() {
        let mut scenario = test_scenario::begin(ADMIN);

        // Create marketplace
        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            marketplace::create_marketplace(
                COLLECTION {},
                b"Collection",
                test_scenario::ctx(&mut scenario)
            );
        };

        // Create item
        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let authority = test_scenario::take_from_address<MarketplaceAuthority<COLLECTION>>(&scenario, ADMIN);
            
            marketplace::create_item(
                &authority,
                b"Rare Item",
                test_scenario::ctx(&mut scenario)
            );
            
            test_scenario::return_to_address(ADMIN, authority);
        };

        // List item
        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let mut marketplace = test_scenario::take_shared<Marketplace>(&scenario);
            let item = test_scenario::take_from_sender<Item<COLLECTION>>(&scenario);
            
            marketplace::list_item(&mut marketplace, item, 1000, test_scenario::ctx(&mut scenario));
            
            test_scenario::return_shared(marketplace);
        };

        // Buy item
        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let mut marketplace = test_scenario::take_shared<Marketplace>(&scenario);
            let item = test_scenario::take_from_address<Item<COLLECTION>>(&scenario, object::id_address(&marketplace));
            
            let payment = coin::mint_for_testing<SUI>(1000, test_scenario::ctx(&mut scenario));
            
            marketplace::buy_item(&mut marketplace, item, payment, test_scenario::ctx(&mut scenario));
            
            test_scenario::return_shared(marketplace);
        };

        // Verify buyer has item
        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let item = test_scenario::take_from_sender<Item<COLLECTION>>(&scenario);
            assert!(marketplace::item_name(&item) == b"Rare Item", 0);
            test_scenario::return_to_sender(&scenario, item);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_delist_item() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            marketplace::create_marketplace(
                COLLECTION {},
                b"Collection",
                test_scenario::ctx(&mut scenario)
            );
        };

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let authority = test_scenario::take_from_address<MarketplaceAuthority<COLLECTION>>(&scenario, ADMIN);
            marketplace::create_item(&authority, b"Item", test_scenario::ctx(&mut scenario));
            test_scenario::return_to_address(ADMIN, authority);
        };

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let mut marketplace = test_scenario::take_shared<Marketplace>(&scenario);
            let item = test_scenario::take_from_sender<Item<COLLECTION>>(&scenario);
            
            marketplace::list_item(&mut marketplace, item, 500, test_scenario::ctx(&mut scenario));
            
            test_scenario::return_shared(marketplace);
        };

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let mut marketplace = test_scenario::take_shared<Marketplace>(&scenario);
            let item = test_scenario::take_from_address<Item<COLLECTION>>(&scenario, object::id_address(&marketplace));
            
            marketplace::delist_item(&mut marketplace, item, test_scenario::ctx(&mut scenario));
            
            test_scenario::return_shared(marketplace);
        };

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let item = test_scenario::take_from_sender<Item<COLLECTION>>(&scenario);
            test_scenario::return_to_sender(&scenario, item);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_multiple_items_with_authority() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            marketplace::create_marketplace(
                COLLECTION {},
                b"Collection",
                test_scenario::ctx(&mut scenario)
            );
        };

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            let authority = test_scenario::take_from_sender<MarketplaceAuthority<COLLECTION>>(&scenario);
            
            // Create multiple items using the same authority
            marketplace::create_item(&authority, b"Item 1", test_scenario::ctx(&mut scenario));
            marketplace::create_item(&authority, b"Item 2", test_scenario::ctx(&mut scenario));
            marketplace::create_item(&authority, b"Item 3", test_scenario::ctx(&mut scenario));
            
            test_scenario::return_to_sender(&scenario, authority);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = marketplace::EInsufficientPayment)]
    fun test_insufficient_payment_fails() {
        let mut scenario = test_scenario::begin(ADMIN);

        test_scenario::next_tx(&mut scenario, ADMIN);
        {
            marketplace::create_marketplace(COLLECTION {}, b"Collection", test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let authority = test_scenario::take_from_address<MarketplaceAuthority<COLLECTION>>(&scenario, ADMIN);
            marketplace::create_item(&authority, b"Item", test_scenario::ctx(&mut scenario));
            test_scenario::return_to_address(ADMIN, authority);
        };

        test_scenario::next_tx(&mut scenario, SELLER);
        {
            let mut marketplace = test_scenario::take_shared<Marketplace>(&scenario);
            let item = test_scenario::take_from_sender<Item<COLLECTION>>(&scenario);
            marketplace::list_item(&mut marketplace, item, 1000, test_scenario::ctx(&mut scenario));
            test_scenario::return_shared(marketplace);
        };

        test_scenario::next_tx(&mut scenario, BUYER);
        {
            let mut marketplace = test_scenario::take_shared<Marketplace>(&scenario);
            let item = test_scenario::take_from_address<Item<COLLECTION>>(&scenario, object::id_address(&marketplace));
            
            // Insufficient payment - should fail
            let payment = coin::mint_for_testing<SUI>(500, test_scenario::ctx(&mut scenario));
            marketplace::buy_item(&mut marketplace, item, payment, test_scenario::ctx(&mut scenario));
            
            test_scenario::return_shared(marketplace);
        };

        test_scenario::end(scenario);
    }
}

