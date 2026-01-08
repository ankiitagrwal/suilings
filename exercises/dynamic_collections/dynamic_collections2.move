  // Exercise: Dynamic Collections - Game Character System
//
// Build a game character system combining ObjectTable for character storage with Dynamic Object Fields for equipment.
// This pattern allows characters to be objects while maintaining flexible equipment attachment.
//
// Stuck? Check out: https://move-book.com/programmability/dynamic-collections.html

module suilings::game_character_system {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::object_table::{Self, ObjectTable};
    use sui::dynamic_object_field as dof;
    use std::string::{Self, String};

    // Error codes
    const ECharacterNotFound: u64 = 1;
    const ENotOwner: u64 = 2;
    const EEquipmentNotFound: u64 = 3;
    const EEquipmentAlreadyAttached: u64 = 4;

    /// Game character with basic stats
    public struct Character has key, store {
        id: UID,
        name: String,
        level: u64,
        owner: address,
    }

    /// Equipment that can be attached to characters
    public struct Equipment has key, store {
        id: UID,
        name: String,
        equipment_type: u8, // 0: Weapon, 1: Armor, 2: Accessory
        power: u64,
    }

    /// Game world storing all characters
    /// Combines ObjectTable for character storage with Dynamic Object Fields for equipment
    public struct GameWorld has key {
        id: UID,
        characters: ObjectTable<u64, Character>,
        next_character_id: u64,
    }

    /// Launch your RPG game world
    /// 
    /// You're building an on-chain RPG where players create characters and equip them
    /// with weapons, armor, and accessories. Characters themselves are valuable NFTs
    /// (stored in ObjectTable), and equipment items are also NFTs that can be attached/
    /// detached dynamically. Players can trade equipped characters with all their gear!
    /// 
    /// Implementation Requirements:
    /// - Create ObjectTable with object_table::new() to store all game characters
    /// - Initialize next_character_id to 1 (first character will be ID 1)
    /// - Share the game world (public game, anyone can play and see characters)
    public fun create_game(ctx: &mut TxContext) {
        // Your implementation here
    }

    /// Create your RPG character
    /// 
    /// A player joins your game and creates their first character. The character
    /// is stored in the global game world (so it appears in the game), but they own it.
    /// It starts at level 1 with no equipment - they'll find gear as they play.
    /// 
    /// Implementation Requirements:
    /// - Create Character NFT with new UID, name, level=1, owner=sender's address
    /// - Add to ObjectTable: object_table::add(&mut game.characters, next_character_id, character)
    /// - Increment next_character_id counter
    /// - Return the character ID (so player knows their character's ID)
    public fun create_character(
        game: &mut GameWorld,
        name: String,
        ctx: &mut TxContext
    ): u64 {
        // Your implementation here
        0
    }

    /// Equip your character with gear
    /// 
    /// Player found a legendary sword! They want to equip it to their character's
    /// weapon slot. The equipment NFT gets attached to the character (not sent to
    /// a separate inventory contract). If they trade the character, the equipped
    /// sword goes with it - everything stays together!
    /// 
    /// Implementation Requirements:
    /// - Get character from ObjectTable: object_table::borrow_mut()
    /// - Abort with ECharacterNotFound if character doesn't exist
    /// - Abort with ENotOwner if sender doesn't own this character
    /// - Check dof::exists_() - abort with EEquipmentAlreadyAttached if slot occupied
    /// - Attach: dof::add(&mut character.id, equipment_slot, equipment)
    public fun attach_equipment(
        game: &mut GameWorld,
        character_id: u64,
        equipment_slot: String,
        equipment: Equipment,
        ctx: &TxContext
    ) {
        // Your implementation here
        transfer::public_transfer(equipment, @0x0);
    }

    /// Detach equipment from a character
    /// 
    /// Dynamic Object Field Operations:
    /// - Borrow character: object_table::borrow_mut()
    /// - Remove equipment: dof::remove<String, Equipment>(&mut character.id, slot)
    /// - Returns the Equipment object with UID intact
    /// 
    /// Implementation Requirements:
    /// - Abort with ECharacterNotFound if character doesn't exist
    /// - Abort with ENotOwner if sender is not character owner
    /// - Abort with EEquipmentNotFound if slot doesn't have equipment
    /// - Remove and return the equipment
    public fun detach_equipment(
        game: &mut GameWorld,
        character_id: u64,
        equipment_slot: String,
        ctx: &TxContext
    ): Equipment {
        // Your implementation here
        abort 0
    }

    /// Get total power from all equipped items
    /// 
    /// Dynamic Object Field Operations:
    /// - Check common equipment slots: "weapon", "armor", "accessory"
    /// - For each slot that exists, borrow and read power
    /// - Sum all power values
    /// 
    /// Implementation Requirements:
    /// - Abort with ECharacterNotFound if character doesn't exist
    /// - Check each standard slot with dof::exists_
    /// - Borrow equipment with dof::borrow() and sum power
    /// - Return total power
    public fun get_character_power(
        game: &GameWorld,
        character_id: u64
    ): u64 {
        // Your implementation here
        0
    }

    /// Level up a character
    /// 
    /// ObjectTable Operations:
    /// - Borrow mutable: object_table::borrow_mut()
    /// - Update level field
    /// 
    /// Implementation Requirements:
    /// - Abort with ECharacterNotFound if character doesn't exist
    /// - Abort with ENotOwner if sender is not character owner
    /// - Increment character level by 1
    public fun level_up_character(
        game: &mut GameWorld,
        character_id: u64,
        ctx: &TxContext
    ) {
        // Your implementation here
    }

    /// Check if character has equipment in a slot
    /// 
    /// Dynamic Object Field Operations:
    /// - Borrow character from ObjectTable
    /// - Check dof::exists_<String>(&character.id, slot)
    /// 
    /// Implementation Requirements:
    /// - Return false if character doesn't exist
    /// - Return dof::exists_ result if character exists
    public fun has_equipment(
        game: &GameWorld,
        character_id: u64,
        equipment_slot: String
    ): bool {
        // Your implementation here
        false
    }

    // ==================== Getter Functions ====================
    public fun character_name(character: &Character): String { character.name }
    public fun character_level(character: &Character): u64 { character.level }
    public fun character_owner(character: &Character): address { character.owner }
    
    public fun equipment_name(equipment: &Equipment): String { equipment.name }
    public fun equipment_type(equipment: &Equipment): u8 { equipment.equipment_type }
    public fun equipment_power(equipment: &Equipment): u64 { equipment.power }
    
    public fun game_next_character_id(game: &GameWorld): u64 { game.next_character_id }
    public fun character_exists(game: &GameWorld, id: u64): bool {
        object_table::contains(&game.characters, id)
    }

    #[test_only]
    public fun create_equipment_for_testing(
        name: String,
        equipment_type: u8,
        power: u64,
        ctx: &mut TxContext
    ): Equipment {
        Equipment {
            id: object::new(ctx),
            name,
            equipment_type,
            power,
        }
    }
}

#[test_only]
module suilings::game_character_system_tests {
    use suilings::game_character_system::{Self, GameWorld, Equipment};
    use sui::test_scenario;
    use sui::object;
    use sui::transfer;
    use std::string;

    const PLAYER1: address = @0x01;

    #[test]
    fun test_create_game() {
        let mut scenario = test_scenario::begin(PLAYER1);
        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            game_character_system::create_game(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let game = test_scenario::take_shared<GameWorld>(&scenario);
            assert!(game_character_system::game_next_character_id(&game) == 1, 0);
            test_scenario::return_shared(game);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_create_character() {
        let mut scenario = test_scenario::begin(PLAYER1);
        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            game_character_system::create_game(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_shared<GameWorld>(&scenario);
            let char_id = game_character_system::create_character(
                &mut game,
                string::utf8(b"Warrior"),
                test_scenario::ctx(&mut scenario)
            );
            assert!(char_id == 1, 0);
            assert!(game_character_system::character_exists(&game, 1), 1);
            test_scenario::return_shared(game);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_attach_equipment() {
        let mut scenario = test_scenario::begin(PLAYER1);
        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            game_character_system::create_game(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_shared<GameWorld>(&scenario);
            let _char_id = game_character_system::create_character(
                &mut game,
                string::utf8(b"Knight"),
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(game);
        };

        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_shared<GameWorld>(&scenario);
            let equipment = game_character_system::create_equipment_for_testing(
                string::utf8(b"Iron Sword"),
                0, // Weapon
                10,
                test_scenario::ctx(&mut scenario)
            );
            game_character_system::attach_equipment(
                &mut game,
                1,
                string::utf8(b"weapon"),
                equipment,
                test_scenario::ctx(&mut scenario)
            );
            assert!(
                game_character_system::has_equipment(&game, 1, string::utf8(b"weapon")),
                0
            );
            test_scenario::return_shared(game);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_detach_equipment() {
        let mut scenario = test_scenario::begin(PLAYER1);
        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            game_character_system::create_game(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_shared<GameWorld>(&scenario);
            let _char_id = game_character_system::create_character(
                &mut game,
                string::utf8(b"Mage"),
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(game);
        };

        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_shared<GameWorld>(&scenario);
            let equipment = game_character_system::create_equipment_for_testing(
                string::utf8(b"Magic Staff"),
                0,
                15,
                test_scenario::ctx(&mut scenario)
            );
            game_character_system::attach_equipment(
                &mut game,
                1,
                string::utf8(b"weapon"),
                equipment,
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(game);
        };

        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_shared<GameWorld>(&scenario);
            let equipment = game_character_system::detach_equipment(
                &mut game,
                1,
                string::utf8(b"weapon"),
                test_scenario::ctx(&mut scenario)
            );
            assert!(game_character_system::equipment_name(&equipment) == string::utf8(b"Magic Staff"), 0);
            assert!(
                !game_character_system::has_equipment(&game, 1, string::utf8(b"weapon")),
                1
            );
            test_scenario::return_shared(game);
            transfer::public_transfer(equipment, PLAYER1);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_get_character_power() {
        let mut scenario = test_scenario::begin(PLAYER1);
        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            game_character_system::create_game(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_shared<GameWorld>(&scenario);
            let _char_id = game_character_system::create_character(
                &mut game,
                string::utf8(b"Paladin"),
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(game);
        };

        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_shared<GameWorld>(&scenario);
            
            let weapon = game_character_system::create_equipment_for_testing(
                string::utf8(b"Holy Sword"),
                0,
                20,
                test_scenario::ctx(&mut scenario)
            );
            game_character_system::attach_equipment(
                &mut game,
                1,
                string::utf8(b"weapon"),
                weapon,
                test_scenario::ctx(&mut scenario)
            );

            let armor = game_character_system::create_equipment_for_testing(
                string::utf8(b"Plate Armor"),
                1,
                15,
                test_scenario::ctx(&mut scenario)
            );
            game_character_system::attach_equipment(
                &mut game,
                1,
                string::utf8(b"armor"),
                armor,
                test_scenario::ctx(&mut scenario)
            );

            let total_power = game_character_system::get_character_power(&game, 1);
            assert!(total_power == 35, 0);
            
            test_scenario::return_shared(game);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_level_up_character() {
        let mut scenario = test_scenario::begin(PLAYER1);
        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            game_character_system::create_game(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_shared<GameWorld>(&scenario);
            let _char_id = game_character_system::create_character(
                &mut game,
                string::utf8(b"Archer"),
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(game);
        };

        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_shared<GameWorld>(&scenario);
            game_character_system::level_up_character(
                &mut game,
                1,
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(game);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = game_character_system::EEquipmentAlreadyAttached)]
    fun test_duplicate_equipment_fails() {
        let mut scenario = test_scenario::begin(PLAYER1);
        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            game_character_system::create_game(test_scenario::ctx(&mut scenario));
        };

        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_shared<GameWorld>(&scenario);
            let _char_id = game_character_system::create_character(
                &mut game,
                string::utf8(b"Fighter"),
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared(game);
        };

        test_scenario::next_tx(&mut scenario, PLAYER1);
        {
            let mut game = test_scenario::take_shared<GameWorld>(&scenario);
            
            let eq1 = game_character_system::create_equipment_for_testing(
                string::utf8(b"Sword1"),
                0,
                10,
                test_scenario::ctx(&mut scenario)
            );
            game_character_system::attach_equipment(
                &mut game,
                1,
                string::utf8(b"weapon"),
                eq1,
                test_scenario::ctx(&mut scenario)
            );

            let eq2 = game_character_system::create_equipment_for_testing(
                string::utf8(b"Sword2"),
                0,
                15,
                test_scenario::ctx(&mut scenario)
            );
            // This should fail - slot already occupied
            game_character_system::attach_equipment(
                &mut game,
                1,
                string::utf8(b"weapon"),
                eq2,
                test_scenario::ctx(&mut scenario)
            );
            
            test_scenario::return_shared(game);
        };

        test_scenario::end(scenario);
    }
}
