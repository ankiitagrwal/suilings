// Exercise: Module Initializer - Game World Setup
//
// Initialize a complex game world with multiple interconnected objects.
// This demonstrates how init can set up an entire ecosystem in one go.
//
// Stuck? Check out: https://move-book.com/programmability/module-initializer.html

module suilings::init3 {
use sui::object::{Self, UID, ID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use std::vector;

// Error constants
const ENotCreator: u64 = 1;
const EZoneFull: u64 = 2;
const EDuplicatePlayer: u64 = 3;
const EPlayerNotFound: u64 = 4;

/// The main game world state
public struct GameWorld has key {
    id: UID,
    name: vector<u8>,
    total_players: u64,
    total_zones: u64,
    creator: address,
    active: bool,
}

/// A zone in the game world
public struct Zone has key, store {
    id: UID,
    name: vector<u8>,
    difficulty: u8,
    max_players: u64,
    current_players: vector<address>,
}

/// Zone directory that tracks all zones
public struct ZoneDirectory has key {
    id: UID,
    zone_ids: vector<ID>,
    zone_names: vector<vector<u8>>,
}

/// Module Initializer - Bootstrap an Entire Game World
/// 
/// Your game studio is deploying a new MMORPG on Sui. The init function
/// sets up the entire game world infrastructure in a single atomic operation.
///
/// World Creation:
/// - Create the main GameWorld with your game's name ("Sui Adventure World")
/// - Publisher becomes the game creator/master
/// - World starts active with zero players
///
/// Zone Infrastructure:
/// - Create a ZoneDirectory to track all game zones
/// - Deploy 3 starter zones with varying difficulty:
///   * "Beginner Valley" - Easy (difficulty 1, max 100 players)
///   * "Dark Forest" - Medium (difficulty 5, max 50 players)
///   * "Dragon's Peak" - Hard (difficulty 10, max 20 players)
///
/// Zone Registration:
/// - Each zone needs a unique ID (use object::uid_to_inner)
/// - Register zone IDs and names in the directory
/// - All zones must be publicly accessible (shared objects)
///
/// Note: Use `let mut directory` for the directory since you'll modify it
///
/// fun init(ctx: &mut TxContext) {
///     // Your implementation here
/// }

/// Create a new zone (game master only)
/// 
/// As the game grows, the creator can add new zones to expand the world.
///
/// Authorization:
/// - Only the original creator can add new zones
///
/// Zone Setup:
/// - Create the zone with provided parameters
/// - Register it in the directory (ID and name)
/// - Increment the world's total zone count
/// - Make the zone publicly accessible
public fun create_zone(
    world: &mut GameWorld,
    directory: &mut ZoneDirectory,
    name: vector<u8>,
    difficulty: u8,
    max_players: u64,
    ctx: &mut TxContext
) {
    // Your implementation here
    abort 0
}

/// Player joins a zone
/// 
/// Players can enter any zone that has available capacity.
///
/// Entry Requirements:
/// - Zone must not be at maximum capacity
/// - Player cannot be in the zone already (no duplicates)
///
/// On successful entry, add player to the zone's player list.
public fun join_zone(zone: &mut Zone, player: address) {
    // Your implementation here
}

/// Player leaves a zone
/// 
/// Players can leave zones they're currently in.
///
/// Exit Process:
/// - Find the player in the zone's player list
/// - Verify the player is actually in the zone
/// - Remove the player from the list
public fun leave_zone(zone: &mut Zone, player: address) {
    // Your implementation here
    abort 0
}

/// Get game world info
public fun world_info(world: &GameWorld): (vector<u8>, u64, u64, address, bool) {
    // Return (name, total_players, total_zones, creator, active)
}

/// Get zone info
public fun zone_info(zone: &Zone): (vector<u8>, u8, u64, u64) {
    // Return (name, difficulty, max_players, current_player_count)
}

/// Get total zones from directory
public fun total_zones_in_directory(directory: &ZoneDirectory): u64 {
    // Return the count of zones in the directory
}

/// Check if player is in zone
public fun is_player_in_zone(zone: &Zone, player: address): bool {
    // Check if the player address exists in the zone's player list
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    // Call the init function for testing
    // init(ctx);
}
}

#[test_only]
module suilings::init3_tests {
use suilings::init3::{Self, GameWorld, Zone, ZoneDirectory};
use sui::test_scenario;

#[test]
fun test_game_world_initialization() {
    let creator = @0xC;
    let mut scenario = test_scenario::begin(creator);
    
    // Init game world
    {
        init3::init_for_testing(test_scenario::ctx(&mut scenario));
    };
    
    // Verify game world
    test_scenario::next_tx(&mut scenario, creator);
    {
        let world = test_scenario::take_shared<GameWorld>(&scenario);
        let directory = test_scenario::take_shared<ZoneDirectory>(&scenario);
        
        let (name, players, zones, c, active) = init3::world_info(&world);
        assert!(name == b"Sui Adventure World", 0);
        assert!(players == 0, 1);
        assert!(zones == 3, 2);
        assert!(c == creator, 3);
        assert!(active == true, 4);
        assert!(init3::total_zones_in_directory(&directory) == 3, 5);
        
        test_scenario::return_shared(world);
        test_scenario::return_shared(directory);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_player_joins_zone() {
    let creator = @0xC;
    let player = @0xA;
    let mut scenario = test_scenario::begin(creator);
    
    // Init
    {
        init3::init_for_testing(test_scenario::ctx(&mut scenario));
    };
    
    // Player joins beginner zone
    test_scenario::next_tx(&mut scenario, player);
    {
        let mut zone = test_scenario::take_shared<Zone>(&scenario);
        
        init3::join_zone(&mut zone, player);
        assert!(init3::is_player_in_zone(&zone, player), 0);
        
        let (_, _, _, current) = init3::zone_info(&zone);
        assert!(current == 1, 1);
        
        test_scenario::return_shared(zone);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_player_leaves_zone() {
    let creator = @0xC;
    let player = @0xA;
    let mut scenario = test_scenario::begin(creator);
    
    // Init
    {
        init3::init_for_testing(test_scenario::ctx(&mut scenario));
    };
    
    // Player joins then leaves
    test_scenario::next_tx(&mut scenario, player);
    {
        let mut zone = test_scenario::take_shared<Zone>(&scenario);
        
        init3::join_zone(&mut zone, player);
        init3::leave_zone(&mut zone, player);
        
        assert!(!init3::is_player_in_zone(&zone, player), 0);
        
        test_scenario::return_shared(zone);
    };
    
    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = init3::EDuplicatePlayer)]
fun test_duplicate_join_fails() {
    let creator = @0xC;
    let player = @0xA;
    let mut scenario = test_scenario::begin(creator);
    
    // Init
    {
        init3::init_for_testing(test_scenario::ctx(&mut scenario));
    };
    
    // Player joins twice
    test_scenario::next_tx(&mut scenario, player);
    {
        let mut zone = test_scenario::take_shared<Zone>(&scenario);
        
        init3::join_zone(&mut zone, player);
        init3::join_zone(&mut zone, player); // Should fail
        
        test_scenario::return_shared(zone);
    };
    
    test_scenario::end(scenario);
}
}
