// Exercise: Wrapper Type - Document Authorization System
//
// Build a document approval system using wrappers for authorization.
// Wrappers can enforce multi-step approval workflows.
//
// Stuck? Check out: https://move-book.com/programmability/wrapper-type-pattern.html

module suilings::document_auth {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use std::vector;

// Error constants
const ENotAuthorized: u64 = 1;
const EAlreadyApproved: u64 = 2;
const EInsufficientApprovals: u64 = 3;
const EDocumentFinalized: u64 = 4;

/// A confidential document that requires approval
public struct Document has key, store {
    id: UID,
    title: vector<u8>,
    content: vector<u8>,
    classification: u8,
}

/// Authorization wrapper that tracks approval workflow
/// Multiple approvers must sign off before document is released
public struct AuthWrapper<T: key + store> has key {
    id: UID,
    /// The wrapped document
    inner: T,
    /// Addresses authorized to approve
    authorized_approvers: vector<address>,
    /// Addresses that have already approved
    approvals: vector<address>,
    /// Minimum approvals required
    required_approvals: u64,
    /// Whether document has been finalized
    is_finalized: bool,
}

/// Wrap a document in authorization layer
///
/// Your organization needs a multi-signature approval system for sensitive
/// documents. Before any document can be released, it must collect approvals
/// from designated authorities. The wrapper enforces this workflow.
///
/// Implementation Requirements:
/// - Create AuthWrapper with new UID
/// - Store document as `inner`
/// - Set authorized_approvers list
/// - Initialize empty approvals vector
/// - Set required_approvals count
/// - Initialize is_finalized to false
/// - Share the wrapped document (multiple people need to approve)
public fun wrap_document<T: key + store>(
    document: T,
    authorized_approvers: vector<address>,
    required_approvals: u64,
    ctx: &mut TxContext
) {
    // Your implementation here
    // REMOVE this temporary line after implementation:
    transfer::public_transfer(document, tx_context::sender(ctx));
}

/// Approve the document as an authorized approver
///
/// When an authorized party reviews and approves the document, add their
/// signature to the approval list. Once enough approvals are collected,
/// the document can be finalized.
///
/// Security Requirements:
/// - Sender must be in authorized_approvers list (abort with ENotAuthorized)
/// - Sender must not have already approved (abort with EAlreadyApproved)
/// - Document must not be finalized (abort with EDocumentFinalized)
///
/// Approval Operations:
/// - Verify sender is in authorized_approvers using vector::contains()
/// - Verify sender not in approvals using vector::contains()
/// - Verify !is_finalized
/// - Add sender to approvals using vector::push_back()
public fun approve_document<T: key + store>(
    wrapper: &mut AuthWrapper<T>,
    ctx: &TxContext
) {
    // Your implementation here
}

/// Finalize and unwrap the document after sufficient approvals
///
/// Once the required number of approvals has been collected, the document
/// can be finalized and extracted from the wrapper. This demonstrates
/// conditional unwrapping based on approval state.
///
/// Security Requirements:
/// - Must have required_approvals (abort with EInsufficientApprovals)
/// - Document must not already be finalized (abort with EDocumentFinalized)
///
/// Finalization Operations:
/// - Count approvals using vector::length()
/// - Verify count >= required_approvals
/// - Verify !is_finalized
/// - Unpack AuthWrapper to extract inner document
/// - Delete wrapper's UID
/// - Return the document T
public fun finalize_document<T: key + store>(
    wrapper: AuthWrapper<T>,
    ctx: &TxContext
): T {
    // Your implementation here
    abort 0 // Placeholder - replace with actual implementation
}

/// Check if a specific address has approved
///
/// Query the approval status for auditing and dashboard displays.
/// This demonstrates read-only wrapper queries.
///
/// Approval Check:
/// - Search for address in approvals vector using vector::contains()
/// - Return true if found, false otherwise
public fun has_approved<T: key + store>(
    wrapper: &AuthWrapper<T>,
    approver: address
): bool {
    vector::contains(&wrapper.approvals, &approver)
}

/// Check if document has collected enough approvals
///
/// Determine if the document is ready to be finalized.
/// Used for UI indicators and workflow automation.
///
/// Approval Check:
/// - Compare vector::length(approvals) >= required_approvals
public fun is_ready_to_finalize<T: key + store>(wrapper: &AuthWrapper<T>): bool {
    vector::length(&wrapper.approvals) >= wrapper.required_approvals
}

// ==================== Helper Functions ====================

/// Create a new document
public fun create_document(
    title: vector<u8>,
    content: vector<u8>,
    classification: u8,
    ctx: &mut TxContext
): Document {
    Document {
        id: object::new(ctx),
        title,
        content,
        classification,
    }
}

// ==================== Getter Functions ====================

public fun approval_count<T: key + store>(wrapper: &AuthWrapper<T>): u64 {
    vector::length(&wrapper.approvals)
}

public fun required_approvals<T: key + store>(wrapper: &AuthWrapper<T>): u64 {
    wrapper.required_approvals
}

public fun is_finalized<T: key + store>(wrapper: &AuthWrapper<T>): bool {
    wrapper.is_finalized
}

public fun authorized_approvers<T: key + store>(wrapper: &AuthWrapper<T>): vector<address> {
    wrapper.authorized_approvers
}

public fun approvals<T: key + store>(wrapper: &AuthWrapper<T>): vector<address> {
    wrapper.approvals
}

public fun document_title(doc: &Document): vector<u8> {
    doc.title
}

public fun document_classification(doc: &Document): u8 {
    doc.classification
}
}

#[test_only]
module suilings::document_auth_tests {
use suilings::document_auth::{Self, AuthWrapper, Document};
use sui::test_scenario;
use std::vector;

const CREATOR: address = @0xC8;
const APPROVER1: address = @0xA1;
const APPROVER2: address = @0xA2;
const APPROVER3: address = @0xA3;
const OTHER: address = @0x99;

#[test]
fun test_wrap_and_approve() {
    let mut scenario = test_scenario::begin(CREATOR);

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let doc = document_auth::create_document(b"Contract", b"Terms", 3, test_scenario::ctx(&mut scenario));
        let mut approvers = vector::empty<address>();
        vector::push_back(&mut approvers, APPROVER1);
        vector::push_back(&mut approvers, APPROVER2);
        document_auth::wrap_document(doc, approvers, 2, test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, APPROVER1);
    {
        let mut wrapper = test_scenario::take_shared<AuthWrapper<Document>>(&scenario);
        assert!(document_auth::approval_count(&wrapper) == 0, 0);
        document_auth::approve_document(&mut wrapper, test_scenario::ctx(&mut scenario));
        assert!(document_auth::approval_count(&wrapper) == 1, 1);
        assert!(document_auth::has_approved(&wrapper, APPROVER1), 2);
        test_scenario::return_shared(wrapper);
    };

    test_scenario::end(scenario);
}

#[test]
fun test_full_approval_workflow() {
    let mut scenario = test_scenario::begin(CREATOR);

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let doc = document_auth::create_document(b"Policy", b"Rules", 5, test_scenario::ctx(&mut scenario));
        let mut approvers = vector::empty<address>();
        vector::push_back(&mut approvers, APPROVER1);
        vector::push_back(&mut approvers, APPROVER2);
        document_auth::wrap_document(doc, approvers, 2, test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, APPROVER1);
    {
        let mut wrapper = test_scenario::take_shared<AuthWrapper<Document>>(&scenario);
        document_auth::approve_document(&mut wrapper, test_scenario::ctx(&mut scenario));
        assert!(!document_auth::is_ready_to_finalize(&wrapper), 0);
        test_scenario::return_shared(wrapper);
    };

    test_scenario::next_tx(&mut scenario, APPROVER2);
    {
        let mut wrapper = test_scenario::take_shared<AuthWrapper<Document>>(&scenario);
        document_auth::approve_document(&mut wrapper, test_scenario::ctx(&mut scenario));
        assert!(document_auth::is_ready_to_finalize(&wrapper), 1);
        test_scenario::return_shared(wrapper);
    };

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let wrapper = test_scenario::take_shared<AuthWrapper<Document>>(&scenario);
        let doc = document_auth::finalize_document(wrapper, test_scenario::ctx(&mut scenario));
        assert!(document_auth::document_classification(&doc) == 5, 2);
        transfer::public_transfer(doc, CREATOR);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = document_auth::ENotAuthorized)]
fun test_unauthorized_approval_fails() {
    let mut scenario = test_scenario::begin(CREATOR);

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let doc = document_auth::create_document(b"Secret", b"Data", 9, test_scenario::ctx(&mut scenario));
        let mut approvers = vector::empty<address>();
        vector::push_back(&mut approvers, APPROVER1);
        document_auth::wrap_document(doc, approvers, 1, test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, OTHER);
    {
        let mut wrapper = test_scenario::take_shared<AuthWrapper<Document>>(&scenario);
        document_auth::approve_document(&mut wrapper, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(wrapper);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = document_auth::EAlreadyApproved)]
fun test_double_approval_fails() {
    let mut scenario = test_scenario::begin(CREATOR);

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let doc = document_auth::create_document(b"Doc", b"Text", 1, test_scenario::ctx(&mut scenario));
        let mut approvers = vector::empty<address>();
        vector::push_back(&mut approvers, APPROVER1);
        document_auth::wrap_document(doc, approvers, 1, test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, APPROVER1);
    {
        let mut wrapper = test_scenario::take_shared<AuthWrapper<Document>>(&scenario);
        document_auth::approve_document(&mut wrapper, test_scenario::ctx(&mut scenario));
        document_auth::approve_document(&mut wrapper, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(wrapper);
    };

    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = document_auth::EInsufficientApprovals)]
fun test_premature_finalize_fails() {
    let mut scenario = test_scenario::begin(CREATOR);

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let doc = document_auth::create_document(b"Draft", b"Content", 2, test_scenario::ctx(&mut scenario));
        let mut approvers = vector::empty<address>();
        vector::push_back(&mut approvers, APPROVER1);
        vector::push_back(&mut approvers, APPROVER2);
        document_auth::wrap_document(doc, approvers, 2, test_scenario::ctx(&mut scenario));
    };

    test_scenario::next_tx(&mut scenario, APPROVER1);
    {
        let mut wrapper = test_scenario::take_shared<AuthWrapper<Document>>(&scenario);
        document_auth::approve_document(&mut wrapper, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(wrapper);
    };

    test_scenario::next_tx(&mut scenario, CREATOR);
    {
        let wrapper = test_scenario::take_shared<AuthWrapper<Document>>(&scenario);
        let _doc = document_auth::finalize_document(wrapper, test_scenario::ctx(&mut scenario));
        transfer::public_transfer(_doc, CREATOR);
    };

    test_scenario::end(scenario);
}
}

