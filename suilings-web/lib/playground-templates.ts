// Move Playground Templates
// Pre-built code templates to help users get started

export interface PlaygroundTemplate {
  id: string;
  title: string;
  description: string;
  category: string;
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  code: string;
  tags: string[];
}

export const TEMPLATE_CATEGORIES = [
  "All",
  "Basics",
  "Objects",
  "NFT",
  "DeFi",
  "Patterns"
] as const;

export const PLAYGROUND_TEMPLATES: PlaygroundTemplate[] = [
  {
    id: 'hello-world',
    title: 'Hello World',
    description: 'Your first Move module - a simple hello world example',
    category: 'Basics',
    difficulty: 'beginner',
    tags: ['basics', 'beginner'],
    code: `module 0x0::hello_world;

/// Returns a greeting message
public fun say_hello(): vector<u8> {
    b"Hello, Sui!"
}

#[test]
fun test_hello() {
    let greeting = say_hello();
    assert!(greeting == b"Hello, Sui!", 0);
}
`,
  },
  {
    id: 'counter',
    title: 'Shared Counter',
    description: 'A simple shared object that anyone can increment',
    category: 'Objects',
    difficulty: 'beginner',
    tags: ['objects', 'shared', 'beginner'],
    code: `module 0x0::counter;

use sui::object::{UID};
use sui::tx_context::TxContext;
use sui::transfer;

/// A simple counter object
public struct Counter has key {
    id: UID,
    value: u64,
}

/// Create a new counter and share it
public fun create(ctx: &mut TxContext) {
    let counter = Counter {
        id: object::new(ctx),
        value: 0,
    };
    transfer::share_object(counter);
}

/// Increment the counter
public fun increment(counter: &mut Counter) {
    counter.value = counter.value + 1;
}

/// Get the current value
public fun value(counter: &Counter): u64 {
    counter.value
}

#[test]
fun test_counter() {
    use sui::test_scenario;
    
    let user = @0xCAFE;
    let mut scenario = test_scenario::begin(user);
    
    // Create counter
    {
        let ctx = test_scenario::ctx(&mut scenario);
        create(ctx);
    };
    
    // Test increment
    test_scenario::next_tx(&mut scenario, user);
    {
        let mut counter = test_scenario::take_shared<Counter>(&scenario);
        increment(&mut counter);
        assert!(value(&counter) == 1, 0);
        test_scenario::return_shared(counter);
    };
    
    test_scenario::end(scenario);
}
`,
  },
  {
    id: 'nft-basic',
    title: 'Basic NFT',
    description: 'Create a simple NFT with metadata',
    category: 'NFT',
    difficulty: 'intermediate',
    tags: ['nft', 'objects', 'display'],
    code: `module 0x0::nft;

use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use std::string::{Self, String};

/// A simple NFT
public struct NFT has key, store {
    id: UID,
    name: String,
    description: String,
    url: String,
}

/// Mint a new NFT
public fun mint(
    name: vector<u8>,
    description: vector<u8>,
    url: vector<u8>,
    ctx: &mut TxContext
) {
    let nft = NFT {
        id: object::new(ctx),
        name: string::utf8(name),
        description: string::utf8(description),
        url: string::utf8(url),
    };
    
    transfer::public_transfer(nft, tx_context::sender(ctx));
}

/// Transfer NFT to another address
public fun transfer_nft(nft: NFT, recipient: address) {
    transfer::public_transfer(nft, recipient);
}

#[test]
fun test_mint_nft() {
    use sui::test_scenario;
    
    let user = @0xCAFE;
    let mut scenario = test_scenario::begin(user);
    
    // Mint NFT
    {
        let ctx = test_scenario::ctx(&mut scenario);
        mint(b"Cool NFT", b"A very cool NFT", b"https://example.com/nft.png", ctx);
    };
    
    // Check NFT was received
    test_scenario::next_tx(&mut scenario, user);
    {
        let nft = test_scenario::take_from_sender<NFT>(&scenario);
        assert!(nft.name == string::utf8(b"Cool NFT"), 0);
        test_scenario::return_to_sender(&scenario, nft);
    };
    
    test_scenario::end(scenario);
}
`,
  },
  {
    id: 'coin-basic',
    title: 'Custom Coin',
    description: 'Create your own fungible token',
    category: 'DeFi',
    difficulty: 'intermediate',
    tags: ['coin', 'token', 'defi'],
    code: `module 0x0::my_coin;

use sui::coin::{Self, Coin, TreasuryCap};
use sui::tx_context::{Self, TxContext};

/// One time witness for the coin
public struct MY_COIN has drop {}

/// Initialize the coin
fun init(witness: MY_COIN, ctx: &mut TxContext) {
    let (treasury, metadata) = coin::create_currency(
        witness,
        9, // decimals
        b"MYC", // symbol
        b"My Coin", // name
        b"A custom coin created in the playground", // description
        option::none(), // icon url
        ctx
    );
    
    // Transfer treasury cap to sender
    transfer::public_transfer(treasury, tx_context::sender(ctx));
    
    // Freeze metadata object
    transfer::public_freeze_object(metadata);
}

/// Mint new coins
public fun mint(
    treasury: &mut TreasuryCap<MY_COIN>,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext
) {
    let coin = coin::mint(treasury, amount, ctx);
    transfer::public_transfer(coin, recipient);
}

/// Burn coins
public fun burn(treasury: &mut TreasuryCap<MY_COIN>, coin: Coin<MY_COIN>) {
    coin::burn(treasury, coin);
}
`,
  },
  {
    id: 'capability',
    title: 'Capability Pattern',
    description: 'Implement access control with capabilities',
    category: 'Patterns',
    difficulty: 'intermediate',
    tags: ['capability', 'access-control', 'patterns'],
    code: `module 0x0::capability_example;

use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;

/// Admin capability - only the admin can perform certain actions
public struct AdminCap has key, store {
    id: UID,
}

/// A protected resource
public struct ProtectedResource has key {
    id: UID,
    value: u64,
}

/// Create admin capability and protected resource
fun init(ctx: &mut TxContext) {
    // Create admin capability
    let admin_cap = AdminCap {
        id: object::new(ctx),
    };
    
    // Create protected resource
    let resource = ProtectedResource {
        id: object::new(ctx),
        value: 0,
    };
    
    // Transfer admin cap to sender
    transfer::transfer(admin_cap, tx_context::sender(ctx));
    
    // Share the resource
    transfer::share_object(resource);
}

/// Only admin can update the value
public fun update_value(
    _admin: &AdminCap,
    resource: &mut ProtectedResource,
    new_value: u64
) {
    resource.value = new_value;
}

/// Anyone can read the value
public fun read_value(resource: &ProtectedResource): u64 {
    resource.value
}

#[test]
fun test_capability() {
    use sui::test_scenario;
    
    let admin = @0xAD;
    let mut scenario = test_scenario::begin(admin);
    
    // Initialize
    {
        let ctx = test_scenario::ctx(&mut scenario);
        init(ctx);
    };
    
    // Admin updates value
    test_scenario::next_tx(&mut scenario, admin);
    {
        let admin_cap = test_scenario::take_from_sender<AdminCap>(&scenario);
        let mut resource = test_scenario::take_shared<ProtectedResource>(&scenario);
        
        update_value(&admin_cap, &mut resource, 42);
        assert!(read_value(&resource) == 42, 0);
        
        test_scenario::return_to_sender(&scenario, admin_cap);
        test_scenario::return_shared(resource);
    };
    
    test_scenario::end(scenario);
}
`,
  },
  {
    id: 'marketplace',
    title: 'Simple Marketplace',
    description: 'Buy and sell items on a marketplace',
    category: 'DeFi',
    difficulty: 'advanced',
    tags: ['marketplace', 'defi', 'trading'],
    code: `module 0x0::marketplace;

use sui::object::{Self, UID, ID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::coin::{Self, Coin};
use sui::sui::SUI;
use sui::balance::{Self, Balance};

/// A listing for an item
public struct Listing<T: key + store> has key {
    id: UID,
    item: T,
    price: u64,
    seller: address,
}

/// List an item for sale
public fun list<T: key + store>(
    item: T,
    price: u64,
    ctx: &mut TxContext
) {
    let listing = Listing {
        id: object::new(ctx),
        item,
        price,
        seller: tx_context::sender(ctx),
    };
    
    transfer::share_object(listing);
}

/// Buy a listed item
public fun buy<T: key + store>(
    listing: Listing<T>,
    payment: Coin<SUI>,
    ctx: &mut TxContext
) {
    let Listing { id, item, price, seller } = listing;
    
    // Check payment amount
    assert!(coin::value(&payment) >= price, 0);
    
    // Transfer payment to seller
    transfer::public_transfer(payment, seller);
    
    // Transfer item to buyer
    transfer::public_transfer(item, tx_context::sender(ctx));
    
    // Delete listing
    object::delete(id);
}

/// Cancel a listing (seller only)
public fun cancel<T: key + store>(
    listing: Listing<T>,
    ctx: &mut TxContext
) {
    let Listing { id, item, price: _, seller } = listing;
    
    // Only seller can cancel
    assert!(tx_context::sender(ctx) == seller, 0);
    
    // Return item to seller
    transfer::public_transfer(item, seller);
    
    // Delete listing
    object::delete(id);
}
`,
  },
  {
    id: 'empty',
    title: 'Empty Template',
    description: 'Start from scratch with an empty module',
    category: 'Basics',
    difficulty: 'beginner',
    tags: ['empty', 'blank'],
    code: `module 0x0::my_module;

// Write your Move code here...

`,
  },
];

export function getTemplateById(id: string): PlaygroundTemplate | undefined {
  return PLAYGROUND_TEMPLATES.find(t => t.id === id);
}

export function getTemplatesByCategory(category: string): PlaygroundTemplate[] {
  if (category === 'All') return PLAYGROUND_TEMPLATES;
  return PLAYGROUND_TEMPLATES.filter(t => t.category === category);
}

export function getTemplatesByDifficulty(difficulty: PlaygroundTemplate['difficulty']): PlaygroundTemplate[] {
  return PLAYGROUND_TEMPLATES.filter(t => t.difficulty === difficulty);
}
