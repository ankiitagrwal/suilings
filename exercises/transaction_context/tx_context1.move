// Exercise: Transaction Context - Multi-Sig Timestamp System
//
// Build a multi-signature system that tracks when each signer approves,
// with time windows for validity using transaction context.
//
// Stuck? Check out: https://move-book.com/programmability/transaction-context.html

module suilings::tx_context1 {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use std::vector;

// Error constants
const EAlreadyExecuted: u64 = 1;
const EProposalExpired: u64 = 2;
const EDuplicateSignature: u64 = 3;
const EInsufficientSignatures: u64 = 4;

/// A multi-signature proposal that requires multiple approvals
public struct Proposal has key {
    id: UID,
    title: vector<u8>,
    creator: address,
    required_signatures: u64,
    signers: vector<address>,
    signature_epochs: vector<u64>,
    signature_timestamps: vector<u64>,
    deadline_epoch: u64,
    executed: bool,
}

/// Signature record for audit trail
public struct SignatureRecord has key, store {
    id: UID,
    proposal_id: address,
    signer: address,
    signed_at_epoch: u64,
    signed_at_timestamp: u64,
}

/// Create a new multi-sig proposal for your organization
/// 
/// Your DAO needs a proposal system where multiple stakeholders must approve
/// before any action can be taken. Each proposal has a deadline after which
/// it becomes invalid.
///
/// Implementation Requirements:
/// - Identify the proposal creator from the transaction context
/// - Capture the current blockchain epoch to calculate the deadline
/// - Initialize empty tracking vectors for signers and their timestamps
/// - The proposal must be publicly accessible (shared object)
public fun create_proposal(
    title: vector<u8>,
    required_signatures: u64,
    duration_epochs: u64,
    ctx: &mut TxContext
) {
    // Your implementation here
}

/// Sign the proposal as a stakeholder
/// 
/// When a stakeholder approves a proposal, we need to capture:
/// - WHO signed (their wallet address)
/// - WHEN they signed (both epoch and timestamp for compliance)
/// 
/// Security Validations:
/// - Proposal must not be already executed
/// - Current time must be within the deadline
/// - Each address can only sign once (prevent replay attacks)
/// 
/// Audit Trail:
/// - Create a personal SignatureRecord NFT for the signer's records
public fun sign_proposal(proposal: &mut Proposal, ctx: &mut TxContext) {
    // Your implementation here
}

/// Execute the proposal after collecting enough signatures
/// 
/// This is the final step where the proposal becomes official.
/// Before execution, verify:
/// - The proposal hasn't been executed already
/// - We're still within the valid time window
/// - We have collected the minimum required signatures
/// 
/// Once validated, mark the proposal as executed.
public fun execute_proposal(proposal: &mut Proposal, ctx: &TxContext) {
    // Your implementation here
}

/// Verify all signatures occurred within an acceptable time window
/// 
/// For regulatory compliance, some organizations require all signers
/// to approve within a specific time frame (e.g., all signatures within 5 epochs).
/// This prevents scenarios where one signer approves immediately and another
/// waits until the last moment.
///
/// Returns true if the gap between earliest and latest signature is acceptable.
public fun verify_signature_time_window(
    proposal: &Proposal,
    max_epoch_difference: u64
): bool {
    // Return false if no signatures exist
    // Find the minimum and maximum epochs among all signatures
    // Return true only if the difference is within acceptable range
    false
}

/// Get proposal info
public fun proposal_info(proposal: &Proposal): (vector<u8>, address, u64, u64, u64, bool) {
    // Return (title, creator, required_signatures, current_signature_count, deadline_epoch, executed)
    (b"", @0x0, 0, 0, 0, false)
}

/// Get signature at index
public fun get_signature_details(proposal: &Proposal, index: u64): (address, u64, u64) {
    // Return (signer, epoch, timestamp) for the given index
    (@0x0, 0, 0)
}

/// Check if address has signed
public fun has_signed(proposal: &Proposal, addr: address): bool {
    // Check if the address exists in the signers vector
    false
}

/// Get remaining time in epochs
public fun epochs_until_deadline(proposal: &Proposal, current_epoch: u64): u64 {
    // Return 0 if deadline has passed, otherwise return remaining epochs
    0
}

/// Get signature record info
public fun signature_record_info(record: &SignatureRecord): (address, address, u64, u64) {
    // Return (proposal_id, signer, signed_at_epoch, signed_at_timestamp)
    (@0x0, @0x0, 0, 0)
}
}

#[test_only]
module suilings::tx_context1_tests {
use suilings::tx_context1::{Self, Proposal, SignatureRecord};
use sui::test_scenario;

#[test]
fun test_create_proposal() {
    let creator = @0xC;
    let mut scenario = test_scenario::begin(creator);
    
    // Create proposal
    {
        let ctx = test_scenario::ctx(&mut scenario);
        tx_context1::create_proposal(b"Test Proposal", 3, 10, ctx);
    };
    
    // Verify
    test_scenario::next_tx(&mut scenario, creator);
    {
        let proposal = test_scenario::take_shared<Proposal>(&scenario);
        
        let (title, c, required, current, deadline, executed) = tx_context1::proposal_info(&proposal);
        assert!(title == b"Test Proposal", 0);
        assert!(c == creator, 1);
        assert!(required == 3, 2);
        assert!(current == 0, 3);
        assert!(deadline == 10, 4);
        assert!(executed == false, 5);
        
        test_scenario::return_shared(proposal);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_sign_proposal() {
    let creator = @0xC;
    let signer1 = @0xA;
    let mut scenario = test_scenario::begin(creator);
    
    // Create proposal
    {
        tx_context1::create_proposal(b"Test Proposal", 2, 10, test_scenario::ctx(&mut scenario));
    };
    
    // Sign proposal
    test_scenario::next_tx(&mut scenario, signer1);
    {
        let mut proposal = test_scenario::take_shared<Proposal>(&scenario);
        tx_context1::sign_proposal(&mut proposal, test_scenario::ctx(&mut scenario));
        
        let (_, _, _, current, _, _) = tx_context1::proposal_info(&proposal);
        assert!(current == 1, 0);
        assert!(tx_context1::has_signed(&proposal, signer1), 1);
        
        test_scenario::return_shared(proposal);
    };
    
    // Check signature record
    test_scenario::next_tx(&mut scenario, signer1);
    {
        let record = test_scenario::take_from_sender<SignatureRecord>(&scenario);
        let (_, signer, epoch, _timestamp) = tx_context1::signature_record_info(&record);
        assert!(signer == signer1, 0);
        assert!(epoch == 0, 1);
        test_scenario::return_to_sender(&scenario, record);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_execute_with_enough_signatures() {
    let creator = @0xC;
    let signer1 = @0xA;
    let signer2 = @0xB;
    let mut scenario = test_scenario::begin(creator);
    
    // Create proposal
    {
        tx_context1::create_proposal(b"Test Proposal", 2, 10, test_scenario::ctx(&mut scenario));
    };
    
    // Two signatures
    test_scenario::next_tx(&mut scenario, signer1);
    {
        let mut proposal = test_scenario::take_shared<Proposal>(&scenario);
        tx_context1::sign_proposal(&mut proposal, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(proposal);
    };
    
    test_scenario::next_tx(&mut scenario, signer2);
    {
        let mut proposal = test_scenario::take_shared<Proposal>(&scenario);
        tx_context1::sign_proposal(&mut proposal, test_scenario::ctx(&mut scenario));
        test_scenario::return_shared(proposal);
    };
    
    // Execute
    test_scenario::next_tx(&mut scenario, creator);
    {
        let mut proposal = test_scenario::take_shared<Proposal>(&scenario);
        tx_context1::execute_proposal(&mut proposal, test_scenario::ctx(&mut scenario));
        
        let (_, _, _, _, _, executed) = tx_context1::proposal_info(&proposal);
        assert!(executed == true, 0);
        
        test_scenario::return_shared(proposal);
    };
    
    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = tx_context1::EDuplicateSignature)]
fun test_duplicate_signature_fails() {
    let creator = @0xC;
    let signer = @0xA;
    let mut scenario = test_scenario::begin(creator);
    
    // Create and sign
    {
        tx_context1::create_proposal(b"Test Proposal", 2, 10, test_scenario::ctx(&mut scenario));
    };
    
    test_scenario::next_tx(&mut scenario, signer);
    {
        let mut proposal = test_scenario::take_shared<Proposal>(&scenario);
        tx_context1::sign_proposal(&mut proposal, test_scenario::ctx(&mut scenario));
        tx_context1::sign_proposal(&mut proposal, test_scenario::ctx(&mut scenario)); // Should fail
        test_scenario::return_shared(proposal);
    };
    
    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = tx_context1::EInsufficientSignatures)]
fun test_execute_without_enough_signatures_fails() {
    let creator = @0xC;
    let mut scenario = test_scenario::begin(creator);
    
    // Create proposal requiring 2 signatures
    {
        tx_context1::create_proposal(b"Test Proposal", 2, 10, test_scenario::ctx(&mut scenario));
    };
    
    // Try to execute without any signatures
    test_scenario::next_tx(&mut scenario, creator);
    {
        let mut proposal = test_scenario::take_shared<Proposal>(&scenario);
        tx_context1::execute_proposal(&mut proposal, test_scenario::ctx(&mut scenario)); // Should fail
        test_scenario::return_shared(proposal);
    };
    
    test_scenario::end(scenario);
}
}
