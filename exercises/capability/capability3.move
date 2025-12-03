// Exercise: Capability Pattern - Governance System
//
// Build a DAO-style governance system where voting capabilities
// represent different voting powers and proposal creation rights.
//
// Stuck? Check out: https://move-book.com/programmability/capability.html

module suilings::capability3 {
use sui::object::{Self, UID, ID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;
use std::vector;

// Error constants
const ENotActive: u64 = 1;
const EDuplicateVote: u64 = 2;
const ENotPassed: u64 = 3;

/// Main DAO governance structure
public struct DAO has key {
    id: UID,
    name: vector<u8>,
    total_members: u64,
    total_proposals: u64,
    voting_threshold: u64, // Minimum votes needed to pass
    founder: address,
}

/// Founder capability - can create proposals and vote with 10x power
public struct FounderCap has key, store {
    id: UID,
    dao_id: ID,
    voting_power: u64,
}

/// Member capability - can vote with 1x power
public struct MemberCap has key, store {
    id: UID,
    dao_id: ID,
    voting_power: u64,
}

/// Delegate capability - can vote on behalf of others with accumulated power
public struct DelegateCap has key, store {
    id: UID,
    dao_id: ID,
    voting_power: u64,
    delegated_by: vector<address>,
}

/// Proposal for voting
public struct Proposal has key {
    id: UID,
    title: vector<u8>,
    description: vector<u8>,
    proposer: address,
    yes_votes: u64,
    no_votes: u64,
    status: u8, // 0: Active, 1: Passed, 2: Rejected, 3: Executed
    voters: vector<address>,
}

/// Create a new DAO for your community
/// 
/// Launch a decentralized autonomous organization where members govern
/// through voting. The founder gets special privileges and voting power.
///
/// DAO Configuration:
/// - Set the name and voting threshold (minimum votes to pass)
/// - Founder becomes the first member
///
/// Founder Privileges:
/// - Create a FounderCap with 10x voting power
/// - Link capability to this specific DAO
/// - Make DAO publicly accessible for member interactions
public fun create_dao(name: vector<u8>, voting_threshold: u64, ctx: &mut TxContext) {
    let founder = tx_context::sender(ctx);
    
    // Your implementation here
    abort 0
}

/// Add a new member to the DAO
/// 
/// Founders can grow the community by adding members.
/// Each member receives voting rights.
///
/// Member Onboarding:
/// - Create a MemberCap with standard voting power (1x)
/// - Link to this specific DAO
/// - Update total member count
public fun add_member(
    _founder_cap: &FounderCap,
    dao: &mut DAO,
    member: address,
    ctx: &mut TxContext
) {
    // Your implementation here
    abort 0
}

/// Delegate your voting power
/// 
/// Members can delegate their voting power to trusted representatives.
/// This enables liquid democracy where busy members can still participate.
///
/// Delegation Process:
/// - Create a DelegateCap with the delegator's voting power
/// - Track who delegated (for accountability)
/// - Delegate receives the capability
public fun delegate_vote(
    member_cap: &MemberCap,
    delegate: address,
    ctx: &mut TxContext
) {
    let delegator = tx_context::sender(ctx);
    
    // Your implementation here
    abort 0
}

/// Create a proposal as founder
/// 
/// Founders can propose changes for the community to vote on.
///
/// Proposal Setup:
/// - Record the proposer and proposal details
/// - Start with zero votes and Active status
/// - Initialize empty voter list (to prevent double voting)
/// - Make proposal publicly accessible for voting
public fun create_proposal_with_founder(
    _founder_cap: &FounderCap,
    dao: &mut DAO,
    title: vector<u8>,
    description: vector<u8>,
    ctx: &mut TxContext
) {
    // Your implementation here
    abort 0
}

/// Create a proposal as member
/// 
/// Regular members can also propose changes to the DAO.
public fun create_proposal_with_member(
    _member_cap: &MemberCap,
    dao: &mut DAO,
    title: vector<u8>,
    description: vector<u8>,
    ctx: &mut TxContext
) {
    // Your implementation here (same as founder)
    abort 0
}

/// Vote on a proposal with founder power
/// 
/// Cast your vote with all your voting power behind it.
///
/// Voting Rules:
/// - Proposal must be Active (status 0)
/// - Each address can only vote once per proposal
///
/// Vote Recording:
/// - Add voter to the voters list
/// - Add voting power to yes_votes or no_votes based on choice
public fun vote_with_founder(
    founder_cap: &FounderCap,
    proposal: &mut Proposal,
    vote_yes: bool,
    ctx: &TxContext
) {
    let voter = tx_context::sender(ctx);
    
    // Your implementation here
}

/// Vote on a proposal with member power
public fun vote_with_member(
    member_cap: &MemberCap,
    proposal: &mut Proposal,
    vote_yes: bool,
    ctx: &TxContext
) {
    // Your implementation here (same logic, use member voting power)
    abort 0
}

/// Vote on a proposal with delegated power
public fun vote_with_delegate(
    delegate_cap: &DelegateCap,
    proposal: &mut Proposal,
    vote_yes: bool,
    ctx: &TxContext
) {
    // Your implementation here (same logic, use delegate voting power)
    abort 0
}

/// Finalize the proposal voting
/// 
/// After voting, determine if the proposal passed or was rejected.
///
/// Outcome Determination:
/// - Proposal must be Active
/// - If yes_votes >= threshold: Passed (status 1)
/// - Otherwise: Rejected (status 2)
public fun finalize_proposal(dao: &DAO, proposal: &mut Proposal) {
    // Your implementation here
}

/// Execute a passed proposal
/// 
/// Founders can execute proposals that have passed voting.
///
/// Execution Requirements:
/// - Proposal must have Passed status (1)
///
/// On execution, update status to Executed (3)
public fun execute_proposal(_founder_cap: &FounderCap, proposal: &mut Proposal) {
    // Your implementation here
}

/// Get DAO information
public fun dao_info(dao: &DAO): (vector<u8>, u64, u64, u64, address) {
    // Return (name, total_members, total_proposals, voting_threshold, founder)
    (b"", 0, 0, 0, @0x0)
}

/// Get proposal information
public fun proposal_info(proposal: &Proposal): (vector<u8>, address, u64, u64, u8) {
    // Return (title, proposer, yes_votes, no_votes, status)
    (b"", @0x0, 0, 0, 0)
}

/// Get founder voting power
public fun voting_power_of_founder(cap: &FounderCap): u64 {
    // Return voting_power
    0
}

/// Get member voting power
public fun voting_power_of_member(cap: &MemberCap): u64 {
    // Return voting_power
    0
}

/// Get delegate voting power
public fun voting_power_of_delegate(cap: &DelegateCap): u64 {
    // Return voting_power
    0
}
}

#[test_only]
module suilings::capability3_tests {
use suilings::capability3::{Self, DAO, FounderCap, MemberCap, Proposal};
use sui::test_scenario;

#[test]
fun test_create_dao() {
    let founder = @0xF;
    let mut scenario = test_scenario::begin(founder);
    
    // Create DAO
    {
        capability3::create_dao(b"Test DAO", 5, test_scenario::ctx(&mut scenario));
    };
    
    // Verify
    test_scenario::next_tx(&mut scenario, founder);
    {
        let dao = test_scenario::take_shared<DAO>(&scenario);
        let founder_cap = test_scenario::take_from_sender<FounderCap>(&scenario);
        
        let (name, members, proposals, threshold, f) = capability3::dao_info(&dao);
        assert!(name == b"Test DAO", 0);
        assert!(members == 1, 1);
        assert!(proposals == 0, 2);
        assert!(threshold == 5, 3);
        assert!(f == founder, 4);
        assert!(capability3::voting_power_of_founder(&founder_cap) == 10, 5);
        
        test_scenario::return_shared(dao);
        test_scenario::return_to_sender(&scenario, founder_cap);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_add_member_and_vote() {
    let founder = @0xF;
    let member = @0xA;
    let mut scenario = test_scenario::begin(founder);
    
    // Create DAO
    {
        capability3::create_dao(b"Test DAO", 5, test_scenario::ctx(&mut scenario));
    };
    
    // Add member
    test_scenario::next_tx(&mut scenario, founder);
    {
        let mut dao = test_scenario::take_shared<DAO>(&scenario);
        let founder_cap = test_scenario::take_from_sender<FounderCap>(&scenario);
        
        capability3::add_member(&founder_cap, &mut dao, member, test_scenario::ctx(&mut scenario));
        
        let (_, members, _, _, _) = capability3::dao_info(&dao);
        assert!(members == 2, 0);
        
        test_scenario::return_shared(dao);
        test_scenario::return_to_sender(&scenario, founder_cap);
    };
    
    // Verify member received cap
    test_scenario::next_tx(&mut scenario, member);
    {
        let member_cap = test_scenario::take_from_address<MemberCap>(&scenario, member);
        assert!(capability3::voting_power_of_member(&member_cap) == 1, 0);
        test_scenario::return_to_address(member, member_cap);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_proposal_and_voting() {
    let founder = @0xF;
    let member = @0xA;
    let mut scenario = test_scenario::begin(founder);
    
    // Setup
    {
        capability3::create_dao(b"Test DAO", 5, test_scenario::ctx(&mut scenario));
    };
    
    test_scenario::next_tx(&mut scenario, founder);
    {
        let mut dao = test_scenario::take_shared<DAO>(&scenario);
        let founder_cap = test_scenario::take_from_sender<FounderCap>(&scenario);
        
        capability3::add_member(&founder_cap, &mut dao, member, test_scenario::ctx(&mut scenario));
        capability3::create_proposal_with_founder(&founder_cap, &mut dao, b"Proposal 1", b"Description", test_scenario::ctx(&mut scenario));
        
        test_scenario::return_shared(dao);
        test_scenario::return_to_sender(&scenario, founder_cap);
    };
    
    // Founder votes yes (10 votes)
    test_scenario::next_tx(&mut scenario, founder);
    {
        let founder_cap = test_scenario::take_from_address<FounderCap>(&scenario, founder);
        let mut proposal = test_scenario::take_shared<Proposal>(&scenario);
        
        capability3::vote_with_founder(&founder_cap, &mut proposal, true, test_scenario::ctx(&mut scenario));
        
        let (_, _, yes, no, _) = capability3::proposal_info(&proposal);
        assert!(yes == 10, 0);
        assert!(no == 0, 1);
        
        test_scenario::return_shared(proposal);
        test_scenario::return_to_address(founder, founder_cap);
    };
    
    // Finalize (should pass)
    test_scenario::next_tx(&mut scenario, founder);
    {
        let dao = test_scenario::take_shared<DAO>(&scenario);
        let mut proposal = test_scenario::take_shared<Proposal>(&scenario);
        
        capability3::finalize_proposal(&dao, &mut proposal);
        
        let (_, _, _, _, status) = capability3::proposal_info(&proposal);
        assert!(status == 1, 0); // Passed
        
        test_scenario::return_shared(dao);
        test_scenario::return_shared(proposal);
    };
    
    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = 2)]
fun test_double_vote_fails() {
    let founder = @0xF;
    let mut scenario = test_scenario::begin(founder);
    
    // Setup
    {
        capability3::create_dao(b"Test DAO", 5, test_scenario::ctx(&mut scenario));
    };
    
    test_scenario::next_tx(&mut scenario, founder);
    {
        let mut dao = test_scenario::take_shared<DAO>(&scenario);
        let founder_cap = test_scenario::take_from_sender<FounderCap>(&scenario);
        
        capability3::create_proposal_with_founder(&founder_cap, &mut dao, b"Proposal", b"Desc", test_scenario::ctx(&mut scenario));
        
        test_scenario::return_shared(dao);
        test_scenario::return_to_sender(&scenario, founder_cap);
    };
    
    // Vote twice
    test_scenario::next_tx(&mut scenario, founder);
    {
        let founder_cap = test_scenario::take_from_address<FounderCap>(&scenario, founder);
        let mut proposal = test_scenario::take_shared<Proposal>(&scenario);
        
        capability3::vote_with_founder(&founder_cap, &mut proposal, true, test_scenario::ctx(&mut scenario));
        capability3::vote_with_founder(&founder_cap, &mut proposal, true, test_scenario::ctx(&mut scenario)); // Should fail
        
        test_scenario::return_shared(proposal);
        test_scenario::return_to_address(founder, founder_cap);
    };
    
    test_scenario::end(scenario);
}
}
