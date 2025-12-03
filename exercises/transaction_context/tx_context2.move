// Exercise: Transaction Context - Dynamic NFT Evolution
//
// Create NFTs that evolve based on transaction context (epoch, transfers, ownership time).
// NFTs "age" and change attributes over time using epoch tracking.
//
// Stuck? Check out: https://move-book.com/programmability/transaction-context.html

module suilings::tx_context2 {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use std::vector;

// Error constants
const ENotReady: u64 = 1;
const ENotOwner: u64 = 2;
const EAlreadyPoweredUp: u64 = 3;

/// Dynamic NFT that evolves with context
public struct DynamicNFT has key, store {
    id: UID,
    name: vector<u8>,
    created_epoch: u64,
    created_timestamp: u64,
    creator: address,
    current_owner: address,
    transfer_count: u64,
    last_transfer_epoch: u64,
    evolution_stage: u8, // 0: Egg, 1: Juvenile, 2: Adult, 3: Legendary
    power_level: u64,
}

/// History record for each NFT
public struct NFTHistory has key {
    id: UID,
    nft_id: address,
    previous_owners: vector<address>,
    transfer_epochs: vector<u64>,
    evolution_epochs: vector<u64>,
}

/// Achievement badge for evolving NFTs
public struct EvolutionBadge has key, store {
    id: UID,
    nft_id: address,
    stage_reached: u8,
    achieved_at_epoch: u64,
}

/// Mint a new Dynamic NFT creature
/// 
/// Your game studio is launching collectible creatures that evolve over time.
/// Each creature starts as an "Egg" and grows based on blockchain time.
///
/// Birth Certificate Data:
/// - Record the exact epoch and timestamp of creation (for age calculation)
/// - Set initial owner as the minter
/// - Initialize with base stats (power_level: 10, stage: Egg)
///
/// Provenance Tracking:
/// - Create a shared NFTHistory to track the creature's journey
/// - This history will record all ownership changes and evolutions
public fun mint_nft(name: vector<u8>, ctx: &mut TxContext) {
    let creator = tx_context::sender(ctx);
    let current_epoch = tx_context::epoch(ctx);
    let current_timestamp = tx_context::epoch_timestamp_ms(ctx);
    
    // Your implementation here
    abort 0
}

/// Transfer NFT to a new owner
/// 
/// When a creature changes hands, maintain its complete ownership history.
/// This is crucial for provenance tracking in the NFT marketplace.
///
/// Transfer Record:
/// - Log the previous owner in the history
/// - Record the epoch when the transfer occurred
/// - Update ownership and increment transfer count
/// - The creature remembers how many homes it's had
public fun transfer_nft(
    nft: DynamicNFT,
    history: &mut NFTHistory,
    recipient: address,
    ctx: &mut TxContext
) {
    let current_epoch = tx_context::epoch(ctx);
    
    // Your implementation here
    abort 0
}

/// Evolve NFT based on its age
/// 
/// Creatures mature as blockchain time passes. Check if your creature
/// is ready to evolve to its next life stage.
///
/// Evolution Stages (based on epochs since creation):
/// - 0-4 epochs: Stage 0 (Egg)
/// - 5-9 epochs: Stage 1 (Juvenile)
/// - 10-19 epochs: Stage 2 (Adult)
/// - 20+ epochs: Stage 3 (Legendary)
///
/// On Successful Evolution:
/// - Update the creature's stage and boost its power
/// - Record the evolution epoch in history
/// - Award an EvolutionBadge as proof of achievement
public fun evolve_nft(
    nft: &mut DynamicNFT,
    history: &mut NFTHistory,
    ctx: &mut TxContext
) {
    let current_epoch = tx_context::epoch(ctx);
    let age = current_epoch - nft.created_epoch;
    
    // Your implementation here
    abort 0
}

/// Power up your NFT creature (daily boost)
/// 
/// Owners can give their creatures a power boost, but only once per epoch.
/// This prevents spam and creates a daily engagement mechanic.
///
/// Requirements:
/// - Only the current owner can power up
/// - Can only power up once per epoch (prevents spam)
/// - Power increase scales with evolution stage
public fun power_up(nft: &mut DynamicNFT, ctx: &TxContext) {
    let sender = tx_context::sender(ctx);
    let current_epoch = tx_context::epoch(ctx);
    
    // Your implementation here
}

/// Calculate NFT age in epochs
public fun get_nft_age(nft: &DynamicNFT, ctx: &TxContext): u64 {
    let current_epoch = tx_context::epoch(ctx);
    // Return the age in epochs
    0
}

/// Get recommended evolution stage based on age
public fun get_recommended_stage(nft: &DynamicNFT, ctx: &TxContext): u8 {
    let age = get_nft_age(nft, ctx);
    
    // Return stage: 0-4 epochs → 0, 5-9 → 1, 10-19 → 2, 20+ → 3
    0
}

/// Get NFT info
public fun nft_info(nft: &DynamicNFT): (vector<u8>, address, address, u64, u64, u8, u64, u64) {
    // Return (name, creator, current_owner, created_epoch, transfer_count, evolution_stage, power_level, last_transfer_epoch)
    (b"", @0x0, @0x0, 0, 0, 0, 0, 0)
}

/// Get history stats
public fun history_stats(history: &NFTHistory): (address, u64, u64) {
    // Return (nft_id, total_transfers, total_evolutions)
    (@0x0, 0, 0)
}

/// Get evolution badge info
public fun badge_info(badge: &EvolutionBadge): (address, u8, u64) {
    // Return (nft_id, stage_reached, achieved_at_epoch)
    (@0x0, 0, 0)
}
}

#[test_only]
module suilings::tx_context2_tests {
use suilings::tx_context2::{Self, DynamicNFT, NFTHistory, EvolutionBadge};
use sui::test_scenario;

#[test]
fun test_mint_nft() {
    let creator = @0xC;
    let mut scenario = test_scenario::begin(creator);
    
    // Mint NFT
    {
        tx_context2::mint_nft(b"Dragon Egg", test_scenario::ctx(&mut scenario));
    };
    
    // Verify
    test_scenario::next_tx(&mut scenario, creator);
    {
        let nft = test_scenario::take_from_sender<DynamicNFT>(&scenario);
        
        let (name, c, owner, epoch, transfers, stage, power, _) = tx_context2::nft_info(&nft);
        assert!(name == b"Dragon Egg", 0);
        assert!(c == creator, 1);
        assert!(owner == creator, 2);
        assert!(epoch == 0, 3);
        assert!(transfers == 0, 4);
        assert!(stage == 0, 5);
        assert!(power == 10, 6);
        
        test_scenario::return_to_sender(&scenario, nft);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_transfer_nft() {
    let creator = @0xC;
    let recipient = @0xA;
    let mut scenario = test_scenario::begin(creator);
    
    // Mint
    {
        tx_context2::mint_nft(b"Dragon Egg", test_scenario::ctx(&mut scenario));
    };
    
    // Transfer
    test_scenario::next_tx(&mut scenario, creator);
    {
        let nft = test_scenario::take_from_sender<DynamicNFT>(&scenario);
        let mut history = test_scenario::take_shared<NFTHistory>(&scenario);
        
        tx_context2::transfer_nft(nft, &mut history, recipient, test_scenario::ctx(&mut scenario));
        
        let (_, transfers, _) = tx_context2::history_stats(&history);
        assert!(transfers == 1, 0);
        
        test_scenario::return_shared(history);
    };
    
    // Verify recipient received
    test_scenario::next_tx(&mut scenario, recipient);
    {
        let nft = test_scenario::take_from_address<DynamicNFT>(&scenario, recipient);
        
        let (_, _, owner, _, transfer_count, _, _, _) = tx_context2::nft_info(&nft);
        assert!(owner == recipient, 0);
        assert!(transfer_count == 1, 1);
        
        test_scenario::return_to_address(recipient, nft);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_nft_age_calculation() {
    let creator = @0xC;
    let mut scenario = test_scenario::begin(creator);
    
    // Mint at epoch 0
    {
        tx_context2::mint_nft(b"Dragon Egg", test_scenario::ctx(&mut scenario));
    };
    
    // Check age at epoch 5
    test_scenario::next_epoch(&mut scenario, creator);
    test_scenario::next_epoch(&mut scenario, creator);
    test_scenario::next_epoch(&mut scenario, creator);
    test_scenario::next_epoch(&mut scenario, creator);
    test_scenario::next_epoch(&mut scenario, creator);
    {
        let nft = test_scenario::take_from_address<DynamicNFT>(&scenario, creator);
        
        let age = tx_context2::get_nft_age(&nft, test_scenario::ctx(&mut scenario));
        assert!(age == 5, 0);
        
        let recommended = tx_context2::get_recommended_stage(&nft, test_scenario::ctx(&mut scenario));
        assert!(recommended == 1, 1); // Should be Juvenile
        
        test_scenario::return_to_address(creator, nft);
    };
    
    test_scenario::end(scenario);
}
}
