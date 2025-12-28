// Exercise: Wrapper Type - Gift Box System
//
// Build a gift wrapping system using wrapper types for object protection.
// Wrappers control access and add functionality to wrapped objects.
//
// Stuck? Check out: https://move-book.com/programmability/wrapper-pattern.html

#[allow(duplicate_alias)]
module suilings::gift_box {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;

// Error constants
const ENotRecipient: u64 = 1;
const EAlreadyOpened: u64 = 2;
const EWrongGift: u64 = 3;

/// A valuable item that can be gifted
public struct Gift has key, store {
    id: UID,
    title: vector<u8>,
    value: u64,
    from: address,
}

/// A gift box wrapper that protects the gift inside
/// The wrapper controls who can open it and when
public struct GiftBox<T: key + store> has key {
    id: UID,
    /// The wrapped gift object
    inner: T,
    /// Who can open this gift box
    recipient: address,
    /// Personal message from the sender
    message: vector<u8>,
    /// Whether the box has been opened
    is_opened: bool,
}

/// Wrap a gift in a protective gift box
///
/// Your gifting platform needs to wrap presents so only the intended
/// recipient can open them. The wrapper pattern provides object-level
/// access control without modifying the gift itself.
///
/// Implementation Requirements:
/// - Create GiftBox wrapper with new UID
/// - Store the gift object as `inner`
/// - Set recipient address
/// - Initialize is_opened to false
/// - Transfer the wrapped GiftBox to the recipient
public fun wrap_gift<T: key + store>(
    gift: T,
    recipient: address,
    message: vector<u8>,
    ctx: &mut TxContext
) {
    // Your implementation here
    // REMOVE this temporary line after implementation:
    transfer::public_transfer(gift, recipient);
}

/// Unwrap the gift box to retrieve the inner gift
///
/// When the recipient wants to open their gift, unwrap the box
/// to extract the original gift object. This destroys the wrapper
/// and returns ownership of the inner object.
///
/// Security Requirements:
/// - Only the recipient can unwrap (abort with ENotRecipient)
/// - Box must not be already opened (abort with EAlreadyOpened)
///
/// Wrapper Operations:
/// - Verify sender is recipient
/// - Verify !is_opened
/// - Unpack the GiftBox struct to extract inner
/// - Delete the wrapper's UID
/// - Return the inner gift object T
public fun unwrap_gift<T: key + store>(
    gift_box: GiftBox<T>,
    ctx: &TxContext
): T {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Peek at the gift message without opening the box
///
/// Allow the recipient to read the gift message before deciding
/// whether to open it. This demonstrates read-only wrapper access.
///
/// Security Requirements:
/// - Only recipient can peek (abort with ENotRecipient)
///
/// Wrapper Operations:
/// - Verify sender is recipient
/// - Return immutable reference to message
public fun peek_message<T: key + store>(
    gift_box: &GiftBox<T>,
    ctx: &TxContext
): vector<u8> {
    assert!(tx_context::sender(ctx) == gift_box.recipient, ENotRecipient);
    gift_box.message
}

/// Mark the gift box as opened without unwrapping
///
/// For tracking purposes, mark a box as opened while keeping it wrapped.
/// Useful for delivery confirmation systems.
///
/// Security Requirements:
/// - Only recipient can mark as opened (abort with ENotRecipient)
/// - Box must not be already opened (abort with EAlreadyOpened)
///
/// Wrapper Operations:
/// - Verify sender is recipient
/// - Verify !is_opened
/// - Set is_opened = true
public fun mark_as_opened<T: key + store>(
    gift_box: &mut GiftBox<T>,
    ctx: &TxContext
) {
    // Your implementation here
}

// ==================== Helper Functions ====================

/// Create a new gift object
public fun create_gift(
    title: vector<u8>,
    value: u64,
    ctx: &mut TxContext
): Gift {
    Gift {
        id: object::new(ctx),
        title,
        value,
        from: tx_context::sender(ctx),
    }
}

// ==================== Getter Functions ====================

public fun recipient<T: key + store>(gift_box: &GiftBox<T>): address {
    gift_box.recipient
}

public fun is_opened<T: key + store>(gift_box: &GiftBox<T>): bool {
    gift_box.is_opened
}

public fun message<T: key + store>(gift_box: &GiftBox<T>): vector<u8> {
    gift_box.message
}

public fun gift_title(gift: &Gift): vector<u8> {
    gift.title
}

public fun gift_value(gift: &Gift): u64 {
    gift.value
}

public fun gift_from(gift: &Gift): address {
    gift.from
}
}

#[test_only]
module suilings::gift_box_tests {
use suilings::gift_box::{Self, GiftBox, Gift};
use sui::test_scenario;

const SENDER: address = @0xA11CE;
const RECIPIENT: address = @0xB0B;
const OTHER: address = @0xCAFE;

#[test]
fun test_wrap_and_unwrap_gift() {
    let mut scenario = test_scenario::begin(SENDER);

    test_scenario::next_tx(&mut scenario, SENDER);
    {
        let gift = gift_box::create_gift(b"Rare NFT", 1000, test_scenario::ctx(&mut scenario));
        gift_box::wrap_gift(gift, RECIPIENT, b"Happy Birthday!", test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, RECIPIENT);
    {
        let gift_box = test_scenario::take_from_sender<GiftBox<Gift>>(&scenario);
        assert!(gift_box::recipient(&gift_box) == RECIPIENT, 0);
        assert!(!gift_box::is_opened(&gift_box), 1);
        
        let gift = gift_box::unwrap_gift(gift_box, test_scenario::ctx(&mut scenario));
        assert!(gift_box::gift_value(&gift) == 1000, 2);
        transfer::public_transfer(gift, RECIPIENT);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_peek_message() {
    let mut scenario = test_scenario::begin(SENDER);

    test_scenario::next_tx(&mut scenario, SENDER);
    {
        let gift = gift_box::create_gift(b"Ticket", 500, test_scenario::ctx(&mut scenario));
        gift_box::wrap_gift(gift, RECIPIENT, b"Concert Pass", test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, RECIPIENT);
    {
        let gift_box = test_scenario::take_from_sender<GiftBox<Gift>>(&scenario);
        let msg = gift_box::peek_message(&gift_box, test_scenario::ctx(&mut scenario));
        assert!(msg == b"Concert Pass", 0);
        test_scenario::return_to_sender(&scenario, gift_box);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_mark_as_opened() {
    let mut scenario = test_scenario::begin(SENDER);

    test_scenario::next_tx(&mut scenario, SENDER);
    {
        let gift = gift_box::create_gift(b"Book", 100, test_scenario::ctx(&mut scenario));
        gift_box::wrap_gift(gift, RECIPIENT, b"Enjoy!", test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, RECIPIENT);
    {
        let mut gift_box = test_scenario::take_from_sender<GiftBox<Gift>>(&scenario);
        gift_box::mark_as_opened(&mut gift_box, test_scenario::ctx(&mut scenario));
        assert!(gift_box::is_opened(&gift_box), 0);
        test_scenario::return_to_sender(&scenario, gift_box);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = gift_box::ENotRecipient)]
fun test_non_recipient_unwrap_fails() {
    let mut scenario = test_scenario::begin(SENDER);

    test_scenario::next_tx(&mut scenario, SENDER);
    {
        let gift = gift_box::create_gift(b"Secret", 999, test_scenario::ctx(&mut scenario));
        gift_box::wrap_gift(gift, RECIPIENT, b"For your eyes only", test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, OTHER);
    {
        let gift_box = test_scenario::take_from_address<GiftBox<Gift>>(&scenario, RECIPIENT);
        let _gift = gift_box::unwrap_gift(gift_box, test_scenario::ctx(&mut scenario));
        test_scenario::return_to_address(RECIPIENT, _gift);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = gift_box::EAlreadyOpened)]
fun test_double_open_fails() {
    let mut scenario = test_scenario::begin(SENDER);

    test_scenario::next_tx(&mut scenario, SENDER);
    {
        let gift = gift_box::create_gift(b"Item", 50, test_scenario::ctx(&mut scenario));
        gift_box::wrap_gift(gift, RECIPIENT, b"Once only", test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, RECIPIENT);
    {
        let mut gift_box = test_scenario::take_from_sender<GiftBox<Gift>>(&scenario);
        gift_box::mark_as_opened(&mut gift_box, test_scenario::ctx(&mut scenario));
        gift_box::mark_as_opened(&mut gift_box, test_scenario::ctx(&mut scenario));
        test_scenario::return_to_sender(&scenario, gift_box);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = gift_box::ENotRecipient)]
fun test_non_recipient_peek_fails() {
    let mut scenario = test_scenario::begin(SENDER);

    test_scenario::next_tx(&mut scenario, SENDER);
    {
        let gift = gift_box::create_gift(b"Private", 200, test_scenario::ctx(&mut scenario));
        gift_box::wrap_gift(gift, RECIPIENT, b"Private message", test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, OTHER);
    {
        let gift_box = test_scenario::take_from_address<GiftBox<Gift>>(&scenario, RECIPIENT);
        let _msg = gift_box::peek_message(&gift_box, test_scenario::ctx(&mut scenario));
        test_scenario::return_to_address(RECIPIENT, gift_box);
    };

    test_scenario::end(scenario);
}
}

