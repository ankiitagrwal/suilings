// Exercise: Publisher Pattern - Game Assets with Display
//
// Build a game asset system using Publisher to create rich metadata displays.
// Learn how Display makes your game items look professional in wallets and marketplaces.
//
// Stuck? Check out: https://move-book.com/programmability/publisher.html

module suilings::publisher2 {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use sui::package::{Self, Publisher};
use sui::display::{Self, Display};
use std::string::{Self, String};

// Error constants
const ENotPublisher: u64 = 1;
const EInvalidRarity: u64 = 2;
const EMaxLevelReached: u64 = 3;

/// One-Time Witness for claiming Publisher
public struct PUBLISHER2 has drop {}

/// Game weapon with display metadata
public struct GameWeapon has key, store {
    id: UID,
    name: String,
    weapon_type: String,  // "Sword", "Bow", "Staff"
    rarity: u8,  // 1=Common, 2=Rare, 3=Epic, 4=Legendary
    attack_power: u64,
    level: u64,
    owner: address,
}

/// Game registry tracking all weapons
public struct GameRegistry has key {
    id: UID,
    total_weapons: u64,
    legendary_count: u64,
}

/// Initialize game with Publisher and Display for weapons
///
/// Create a comprehensive display for game weapons showing all attributes.
/// Publisher allows you to define rich metadata that appears in wallets.
///
/// Implementation Requirements:
/// 1. Claim Publisher using package::claim(otw, ctx)
/// 2. Create Display<GameWeapon> using display::new<GameWeapon>(&publisher, ctx)
/// 3. Set display fields:
///    - "name": "{name}"
///    - "description": "Level {level} {weapon_type} with {attack_power} attack power"
///    - "type": "{weapon_type}"
///    - "rarity": "{rarity}"
///    - "attack_power": "{attack_power}"
///    - "level": "{level}"
///    - "image_url": "https://game-assets.io/weapons/{weapon_type}_{rarity}.png"
/// 4. Update display: display::update_version(&mut display)
/// 5. Create GameRegistry shared object with counters initialized to 0
/// 6. Transfer Publisher to sender
/// 7. Make Display public: transfer::public_transfer(display, sender)
///
/// Display Best Practices:
/// - Use descriptive field names
/// - Combine fields for rich descriptions
/// - Use conditional image URLs based on attributes
public fun init_game(
    otw: PUBLISHER2,
    ctx: &mut TxContext
) {
    // Your implementation here
}

/// Forge a new weapon
///
/// Create a game weapon with specific attributes. The Display defines
/// how it appears with images and metadata based on rarity and type.
///
/// Security Requirements:
/// - Rarity must be between 1-4 (abort with EInvalidRarity)
///
/// Forging Operations:
/// - Validate rarity (1-4)
/// - Create GameWeapon with new UID and provided attributes
/// - Set level = 1, owner = recipient
/// - Increment registry.total_weapons
/// - If rarity == 4 (Legendary), increment registry.legendary_count
/// - Transfer weapon to recipient
public fun forge_weapon(
    registry: &mut GameRegistry,
    name: String,
    weapon_type: String,
    rarity: u8,
    attack_power: u64,
    recipient: address,
    ctx: &mut TxContext
) {
    // Your implementation here
}

/// Level up a weapon
///
/// Increase weapon level and attack power. Display automatically
/// updates to show new stats.
///
/// Security Requirements:
/// - Only weapon owner can level up
/// - Level must be < 100 (abort with EMaxLevelReached)
///
/// Level Up Operations:
/// - Increment weapon.level by 1
/// - Increase weapon.attack_power by 10% (attack_power * 11 / 10)
public fun level_up_weapon(
    weapon: &mut GameWeapon,
    ctx: &TxContext
) {
    // Your implementation here
}

/// Get rarity name for display
///
/// Convert numeric rarity to human-readable string.
/// This could be used in display templates or frontend.
public fun get_rarity_name(rarity: u8): String {
    if (rarity == 1) {
        string::utf8(b"Common")
    } else if (rarity == 2) {
        string::utf8(b"Rare")
    } else if (rarity == 3) {
        string::utf8(b"Epic")
    } else if (rarity == 4) {
        string::utf8(b"Legendary")
    } else {
        string::utf8(b"Unknown")
    }
}

// ==================== Getter Functions ====================

public fun weapon_name(weapon: &GameWeapon): String { weapon.name }
public fun weapon_type(weapon: &GameWeapon): String { weapon.weapon_type }
public fun weapon_rarity(weapon: &GameWeapon): u8 { weapon.rarity }
public fun weapon_attack_power(weapon: &GameWeapon): u64 { weapon.attack_power }
public fun weapon_level(weapon: &GameWeapon): u64 { weapon.level }
public fun weapon_owner(weapon: &GameWeapon): address { weapon.owner }

public fun registry_total_weapons(registry: &GameRegistry): u64 { registry.total_weapons }
public fun registry_legendary_count(registry: &GameRegistry): u64 { registry.legendary_count }

#[test_only]
public fun create_witness_for_testing(): PUBLISHER2 {
    PUBLISHER2 {}
}

#[test_only]
public fun create_publisher_for_testing(ctx: &mut TxContext): Publisher {
    package::test_claim(create_witness_for_testing(), ctx)
}
}

#[test_only]
module suilings::publisher2_tests {
use suilings::publisher2::{Self, GameRegistry, GameWeapon};
use sui::test_scenario;
use sui::package::Publisher;
use sui::display::Display;
use std::string;

const GAME_MASTER: address = @0xAD;
const PLAYER1: address = @0x01;
const PLAYER2: address = @0x02;

#[test]
fun test_game_initialization() {
    let mut scenario = test_scenario::begin(GAME_MASTER);

    test_scenario::next_tx(&mut scenario, GAME_MASTER);
    {
        publisher2::init_game(
            publisher2::create_witness_for_testing(),
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, GAME_MASTER);
    {
        let registry = test_scenario::take_shared<GameRegistry>(&scenario);
        assert!(publisher2::registry_total_weapons(&registry) == 0, 0);
        assert!(publisher2::registry_legendary_count(&registry) == 0, 1);
        
        assert!(test_scenario::has_most_recent_for_sender<Publisher>(&scenario), 2);
        assert!(test_scenario::has_most_recent_for_sender<Display<GameWeapon>>(&scenario), 3);
        
        test_scenario::return_shared(registry);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_forge_common_weapon() {
    let mut scenario = test_scenario::begin(GAME_MASTER);

    test_scenario::next_tx(&mut scenario, GAME_MASTER);
    {
        publisher2::init_game(
            publisher2::create_witness_for_testing(),
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, GAME_MASTER);
    {
        let mut registry = test_scenario::take_shared<GameRegistry>(&scenario);
        publisher2::forge_weapon(
            &mut registry,
            string::utf8(b"Iron Sword"),
            string::utf8(b"Sword"),
            1, // Common
            50,
            PLAYER1,
            test_scenario::ctx(&mut scenario)
        );
        assert!(publisher2::registry_total_weapons(&registry) == 1, 0);
        assert!(publisher2::registry_legendary_count(&registry) == 0, 1);
        test_scenario::return_shared(registry);
    };

    test_scenario::next_tx(&mut scenario, PLAYER1);
    {
        let weapon = test_scenario::take_from_sender<GameWeapon>(&scenario);
        assert!(publisher2::weapon_name(&weapon) == string::utf8(b"Iron Sword"), 0);
        assert!(publisher2::weapon_rarity(&weapon) == 1, 1);
        assert!(publisher2::weapon_level(&weapon) == 1, 2);
        assert!(publisher2::weapon_attack_power(&weapon) == 50, 3);
        test_scenario::return_to_sender(&scenario, weapon);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_forge_legendary_weapon() {
    let mut scenario = test_scenario::begin(GAME_MASTER);

    test_scenario::next_tx(&mut scenario, GAME_MASTER);
    {
        publisher2::init_game(
            publisher2::create_witness_for_testing(),
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, GAME_MASTER);
    {
        let mut registry = test_scenario::take_shared<GameRegistry>(&scenario);
        publisher2::forge_weapon(
            &mut registry,
            string::utf8(b"Excalibur"),
            string::utf8(b"Sword"),
            4, // Legendary
            500,
            PLAYER1,
            test_scenario::ctx(&mut scenario)
        );
        assert!(publisher2::registry_legendary_count(&registry) == 1, 0);
        test_scenario::return_shared(registry);
    };

    test_scenario::next_tx(&mut scenario, PLAYER1);
    {
        let weapon = test_scenario::take_from_sender<GameWeapon>(&scenario);
        assert!(publisher2::weapon_rarity(&weapon) == 4, 0);
        assert!(publisher2::get_rarity_name(4) == string::utf8(b"Legendary"), 1);
        test_scenario::return_to_sender(&scenario, weapon);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_level_up_weapon() {
    let mut scenario = test_scenario::begin(GAME_MASTER);

    test_scenario::next_tx(&mut scenario, GAME_MASTER);
    {
        publisher2::init_game(
            publisher2::create_witness_for_testing(),
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, GAME_MASTER);
    {
        let mut registry = test_scenario::take_shared<GameRegistry>(&scenario);
        publisher2::forge_weapon(
            &mut registry,
            string::utf8(b"Basic Sword"),
            string::utf8(b"Sword"),
            1,
            100,
            PLAYER1,
            test_scenario::ctx(&mut scenario)
        );
        test_scenario::return_shared(registry);
    };

    test_scenario::next_tx(&mut scenario, PLAYER1);
    {
        let mut weapon = test_scenario::take_from_sender<GameWeapon>(&scenario);
        let initial_power = publisher2::weapon_attack_power(&weapon);
        
        publisher2::level_up_weapon(&mut weapon, test_scenario::ctx(&mut scenario));
        
        assert!(publisher2::weapon_level(&weapon) == 2, 0);
        assert!(publisher2::weapon_attack_power(&weapon) == initial_power * 11 / 10, 1);
        test_scenario::return_to_sender(&scenario, weapon);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = publisher2::EInvalidRarity)]
fun test_invalid_rarity_fails() {
    let mut scenario = test_scenario::begin(GAME_MASTER);

    test_scenario::next_tx(&mut scenario, GAME_MASTER);
    {
        publisher2::init_game(
            publisher2::create_witness_for_testing(),
            test_scenario::ctx(&mut scenario)
        );
    };

    test_scenario::next_tx(&mut scenario, GAME_MASTER);
    {
        let mut registry = test_scenario::take_shared<GameRegistry>(&scenario);
        // This should fail - invalid rarity
        publisher2::forge_weapon(
            &mut registry,
            string::utf8(b"Invalid Weapon"),
            string::utf8(b"Sword"),
            5, // Invalid rarity
            100,
            PLAYER1,
            test_scenario::ctx(&mut scenario)
        );
        test_scenario::return_shared(registry);
    };

    test_scenario::end(scenario);
}
}

