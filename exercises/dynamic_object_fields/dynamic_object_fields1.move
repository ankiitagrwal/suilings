// Exercise: Dynamic Object Fields - Attachment System
//
// Build an attachment system using dynamic object fields to attach objects to other objects.
// Dynamic object fields store objects as values, maintaining their UIDs and ownership.
//
// Stuck? Check out: https://move-book.com/programmability/dynamic-object-fields.html

module suilings::attachment_system {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::dynamic_object_field as dof;
use std::string::String;

// Error constants
const EAttachmentNotFound: u64 = 1;
const EAttachmentAlreadyExists: u64 = 2;
const ENotOwner: u64 = 3;

/// A base item that can have attachments
public struct BaseItem has key, store {
    id: UID,
    name: String,
    owner: address,
}

/// An attachment that can be attached to items
public struct Attachment has key, store {
    id: UID,
    name: String,
    attachment_type: u8, // 0: Mod, 1: Upgrade, 2: Decoration
    power: u64,
}

/// Create a new base item
///
/// Your system needs items that can have other objects attached to them.
/// Dynamic object fields allow storing objects as values while maintaining
/// their UIDs and object properties.
///
/// Implementation Requirements:
/// - Create BaseItem with new UID
/// - Set name and owner (tx_context::sender())
/// - Transfer to owner
public fun create_base_item(
    name: String,
    ctx: &mut TxContext
): BaseItem {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Create a new attachment
///
/// Create an attachment object that can be attached to base items.
/// Attachments are independent objects with their own UIDs.
///
/// Implementation Requirements:
/// - Create Attachment with new UID
/// - Set name, attachment_type, and power
/// - Transfer to creator
public fun create_attachment(
    name: String,
    attachment_type: u8,
    power: u64,
    ctx: &mut TxContext
): Attachment {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Attach an object to a base item
///
/// Attach an attachment object to a base item using dynamic object fields.
/// The attachment maintains its UID and can be detached later.
///
/// Security Requirements:
/// - Attachment must not already exist for this key (abort with EAttachmentAlreadyExists)
/// - Only item owner can attach (abort with ENotOwner)
///
/// Dynamic Object Field Operations:
/// - Check exists: dof::exists_<String, Attachment>(&item.id, key)
/// - Abort if exists
/// - Verify sender is owner
/// - Add: dof::add(&mut item.id, key, attachment)
/// - Note: key is String, value is Attachment object
public fun attach(
    item: &mut BaseItem,
    key: String,
    attachment: Attachment,
    ctx: &TxContext,
) {
    // Your implementation here
    transfer::public_transfer(attachment, tx_context::sender(ctx)); // Temporary - replace with dof::add
}

/// Detach an attachment from an item
///
/// Remove an attachment and return it as an independent object.
/// The attachment can then be transferred or attached elsewhere.
///
/// Security Requirements:
/// - Attachment must exist (abort with EAttachmentNotFound)
/// - Only item owner can detach (abort with ENotOwner)
///
/// Dynamic Object Field Operations:
/// - Verify exists
/// - Verify sender is owner
/// - Remove: dof::remove<String, Attachment>(&mut item.id, key)
/// - Returns the Attachment object (with its UID intact)
public fun detach(
    item: &mut BaseItem,
    key: String,
    ctx: &TxContext,
): Attachment {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Get a reference to an attached object
///
/// Borrow an attachment without removing it.
/// Useful for reading attachment properties.
///
/// Security Requirements:
/// - Attachment must exist (abort with EAttachmentNotFound)
///
/// Dynamic Object Field Operations:
/// - Verify exists
/// - Borrow: dof::borrow<String, Attachment>(&item.id, key)
/// - Return immutable reference
public fun get_attachment(item: &BaseItem, key: String): &Attachment {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Get a mutable reference to an attached object
///
/// Borrow an attachment mutably to modify its properties.
/// The attachment remains attached but can be updated.
///
/// Security Requirements:
/// - Attachment must exist (abort with EAttachmentNotFound)
/// - Only item owner can modify (abort with ENotOwner)
///
/// Dynamic Object Field Operations:
/// - Verify exists
/// - Verify sender is owner
/// - Borrow mutable: dof::borrow_mut<String, Attachment>(&mut item.id, key)
/// - Return mutable reference
public fun get_attachment_mut(
    item: &mut BaseItem,
    key: String,
    ctx: &TxContext,
): &mut Attachment {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Check if an attachment exists
///
/// Query whether a specific attachment is attached to an item.
///
/// Dynamic Object Field Operations:
/// - Use dof::exists_<String, Attachment>(&item.id, key)
public fun has_attachment(item: &BaseItem, key: String): bool {
    // Your implementation here
    false
}

// ==================== Getter Functions ====================

public fun item_name(item: &BaseItem): String {
    item.name
}

public fun item_owner(item: &BaseItem): address {
    item.owner
}

public fun attachment_name(attachment: &Attachment): String {
    attachment.name
}

public fun attachment_type(attachment: &Attachment): u8 {
    attachment.attachment_type
}

public fun attachment_power(attachment: &Attachment): u64 {
    attachment.power
}

public fun set_attachment_power(attachment: &mut Attachment, new_power: u64) {
    attachment.power = new_power;
}
}

#[test_only]
module suilings::attachment_system_tests {
use suilings::attachment_system::{Self, BaseItem};
use sui::test_scenario;
use sui::transfer;
use std::string;

const OWNER: address = @0x01;
const OTHER: address = @0x02;

#[test]
fun test_create_item_and_attachment() {
    let mut scenario = test_scenario::begin(OWNER);

    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let item = attachment_system::create_base_item(
            string::utf8(b"Base Weapon"),
            test_scenario::ctx(&mut scenario)
        );
        let attachment = attachment_system::create_attachment(
            string::utf8(b"Power Mod"),
            0, // Mod
            50,
            test_scenario::ctx(&mut scenario)
        );
        
        assert!(attachment_system::item_name(&item) == string::utf8(b"Base Weapon"), 0);
        assert!(attachment_system::attachment_power(&attachment) == 50, 1);
        
        transfer::public_transfer(item, OWNER);
        transfer::public_transfer(attachment, OWNER);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_attach_and_detach() {
    let mut scenario = test_scenario::begin(OWNER);

    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let mut item = attachment_system::create_base_item(
            string::utf8(b"Modular Item"),
            test_scenario::ctx(&mut scenario)
        );
        let attachment = attachment_system::create_attachment(
            string::utf8(b"Upgrade"),
            1,
            75,
            test_scenario::ctx(&mut scenario)
        );
        
        attachment_system::attach(
            &mut item,
            string::utf8(b"upgrade1"),
            attachment,
            test_scenario::ctx(&mut scenario)
        );
        
        assert!(
            attachment_system::has_attachment(&item, string::utf8(b"upgrade1")),
            0
        );
        
        let detached = attachment_system::detach(
            &mut item,
            string::utf8(b"upgrade1"),
            test_scenario::ctx(&mut scenario)
        );
        
        assert!(
            !attachment_system::has_attachment(&item, string::utf8(b"upgrade1")),
            1
        );
        assert!(attachment_system::attachment_power(&detached) == 75, 2);
        
        transfer::public_transfer(item, OWNER);
        transfer::public_transfer(detached, OWNER);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_get_attachment() {
    let mut scenario = test_scenario::begin(OWNER);

    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let mut item = attachment_system::create_base_item(
            string::utf8(b"Item with Mod"),
            test_scenario::ctx(&mut scenario)
        );
        let attachment = attachment_system::create_attachment(
            string::utf8(b"Speed Mod"),
            0,
            30,
            test_scenario::ctx(&mut scenario)
        );
        
        attachment_system::attach(
            &mut item,
            string::utf8(b"mod1"),
            attachment,
            test_scenario::ctx(&mut scenario)
        );
        
        let attached = attachment_system::get_attachment(&item, string::utf8(b"mod1"));
        assert!(attachment_system::attachment_name(attached) == string::utf8(b"Speed Mod"), 0);
        assert!(attachment_system::attachment_power(attached) == 30, 1);
        
        transfer::public_transfer(item, OWNER);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_modify_attached_object() {
    let mut scenario = test_scenario::begin(OWNER);

    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let mut item = attachment_system::create_base_item(
            string::utf8(b"Upgradeable Item"),
            test_scenario::ctx(&mut scenario)
        );
        let attachment = attachment_system::create_attachment(
            string::utf8(b"Base Mod"),
            0,
            10,
            test_scenario::ctx(&mut scenario)
        );
        
        attachment_system::attach(
            &mut item,
            string::utf8(b"mod"),
            attachment,
            test_scenario::ctx(&mut scenario)
        );
        
        // Modify the attached object
        let attached = attachment_system::get_attachment_mut(
            &mut item,
            string::utf8(b"mod"),
            test_scenario::ctx(&mut scenario)
        );
        attachment_system::set_attachment_power(attached, 25);
        
        let attached_ref = attachment_system::get_attachment(&item, string::utf8(b"mod"));
        assert!(attachment_system::attachment_power(attached_ref) == 25, 0);
        
        transfer::public_transfer(item, OWNER);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = attachment_system::EAttachmentAlreadyExists)]
fun test_duplicate_attachment_fails() {
    let mut scenario = test_scenario::begin(OWNER);

    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let mut item = attachment_system::create_base_item(
            string::utf8(b"Test Item"),
            test_scenario::ctx(&mut scenario)
        );
        let attachment1 = attachment_system::create_attachment(
            string::utf8(b"Mod 1"),
            0,
            10,
            test_scenario::ctx(&mut scenario)
        );
        let attachment2 = attachment_system::create_attachment(
            string::utf8(b"Mod 2"),
            0,
            20,
            test_scenario::ctx(&mut scenario)
        );
        
        attachment_system::attach(
            &mut item,
            string::utf8(b"same_key"),
            attachment1,
            test_scenario::ctx(&mut scenario)
        );
        
        // This should fail - duplicate key
        attachment_system::attach(
            &mut item,
            string::utf8(b"same_key"),
            attachment2,
            test_scenario::ctx(&mut scenario)
        );
        
        transfer::public_transfer(item, OWNER);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = attachment_system::ENotOwner)]
fun test_non_owner_cannot_attach() {
    let mut scenario = test_scenario::begin(OWNER);

    test_scenario::next_tx(&mut scenario, OWNER);
    {
        let item = attachment_system::create_base_item(
            string::utf8(b"Owner's Item"),
            test_scenario::ctx(&mut scenario)
        );
        transfer::public_share_object(item);
    };

    test_scenario::next_tx(&mut scenario, OTHER);
    {
        let mut item = test_scenario::take_shared<BaseItem>(&scenario);
        let attachment = attachment_system::create_attachment(
            string::utf8(b"Hack Mod"),
            0,
            999,
            test_scenario::ctx(&mut scenario)
        );
        
        // This should fail - not the owner
        attachment_system::attach(
            &mut item,
            string::utf8(b"hack"),
            attachment,
            test_scenario::ctx(&mut scenario)
        );
        
        transfer::public_share_object(item);
    };

    test_scenario::end(scenario);
}
}

