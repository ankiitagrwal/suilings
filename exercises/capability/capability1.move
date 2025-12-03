// Exercise: Capability Pattern - Admin System
//
// Build a role-based access control system using the Capability pattern.
// Different capabilities grant different permissions.
//
// Stuck? Check out: https://move-book.com/programmability/capability.html

module suilings::capability1 {
use sui::object::{Self, UID};
use sui::tx_context::{Self, TxContext};
use sui::transfer;

// Error constants
const ESystemLocked: u64 = 1;
const ECannotBan: u64 = 2;
const EUserBanned: u64 = 3;

/// Main system configuration
public struct System has key {
    id: UID,
    name: vector<u8>,
    owner: address,
    total_admins: u64,
    total_moderators: u64,
    is_locked: bool,
}

/// Admin capability - can do everything
public struct AdminCap has key, store {
    id: UID,
    granted_by: address,
}

/// Moderator capability - limited permissions
public struct ModeratorCap has key, store {
    id: UID,
    granted_by: address,
    can_ban: bool,
}

/// User record
public struct UserRecord has key, store {
    id: UID,
    user: address,
    is_banned: bool,
    reputation: u64,
}

/// Initialize your admin system
/// 
/// Your platform needs a role-based access control system. Anyone can create
/// their own system instance, becoming the founding admin.
///
/// System Bootstrap:
/// - Create the System with the provided name
/// - Founding admin is counted in total_admins (starts at 1)
/// - System begins in unlocked state (accepting new admins/mods)
///
/// Admin Privilege:
/// - Create an AdminCap for the founder
/// - Track who granted it (self-granted for founders)
/// - Make the System publicly accessible
public fun create_system(name: vector<u8>, ctx: &mut TxContext) {
    let owner = tx_context::sender(ctx);
    
    // Your implementation here
    abort 0
}

/// Grant admin capability to a team member
/// 
/// Existing admins can promote others to admin status, expanding the team.
///
/// Authorization Check:
/// - System must not be locked (no new grants allowed when locked)
///
/// Admin Onboarding:
/// - Create new AdminCap with chain of trust (who granted it)
/// - Update system metrics
/// - Transfer capability to the new admin
public fun grant_admin(
    _admin_cap: &AdminCap,
    system: &mut System,
    recipient: address,
    ctx: &mut TxContext
) {
    // Your implementation here
    abort 0
}

/// Grant moderator capability
/// 
/// Admins can create moderators with customizable permissions.
/// Not all moderators are equal - some can ban users, others cannot.
///
/// Authorization Check:
/// - System must not be locked
///
/// Moderator Setup:
/// - Create ModeratorCap with specified ban permission
/// - Track the admin who granted this capability
/// - Update system metrics
public fun grant_moderator(
    _admin_cap: &AdminCap,
    system: &mut System,
    recipient: address,
    can_ban: bool,
    ctx: &mut TxContext
) {
    // Your implementation here
    abort 0
}

/// Moderator bans a user (requires ban permission)
/// 
/// Moderators with ban privileges can restrict users from the platform.
///
/// Permission Check:
/// - Moderator must have the can_ban flag set to true
///
/// User Update:
/// - Mark the user record as banned
public fun ban_user_with_moderator(
    moderator_cap: &ModeratorCap,
    user_record: &mut UserRecord
) {
    // Your implementation here
}

/// Admin bans a user (always allowed)
/// 
/// Admins have full privileges and can always ban users.
public fun ban_user_with_admin(
    _admin_cap: &AdminCap,
    user_record: &mut UserRecord
) {
    // Your implementation here
}

/// Lock the system (freeze new capability grants)
/// 
/// Once locked, no new admins or moderators can be added.
/// This is useful for finalizing team structure.
public fun lock_system(_admin_cap: &AdminCap, system: &mut System) {
    // Your implementation here
}

/// Create a user record
/// 
/// Any user can create their profile in the system.
///
/// Profile Setup:
/// - User starts with clean record (not banned)
/// - Initial reputation is zero
/// - Profile is owned by the user
public fun create_user_record(ctx: &mut TxContext) {
    let user = tx_context::sender(ctx);
    
    // Your implementation here
    abort 0
}

/// Increase user reputation (admin only)
/// 
/// Admins can reward good behavior by increasing reputation.
///
/// Eligibility Check:
/// - User must not be banned (banned users can't earn reputation)
///
/// Reputation Update:
/// - Add the specified amount to the user's reputation
public fun increase_reputation(
    _admin_cap: &AdminCap,
    user_record: &mut UserRecord,
    amount: u64
) {
    // Your implementation here
}

/// Get system information
public fun system_info(system: &System): (vector<u8>, address, u64, u64, bool) {
    // Return (name, owner, total_admins, total_moderators, is_locked)
    (b"", @0x0, 0, 0, false)
}

/// Get user profile information
public fun user_info(record: &UserRecord): (address, bool, u64) {
    // Return (user, is_banned, reputation)
    (@0x0, false, 0)
}

/// Check moderator's ban permission
public fun moderator_can_ban(cap: &ModeratorCap): bool {
    // Return the can_ban permission
    false
}
}

#[test_only]
module suilings::capability1_tests {
use suilings::capability1::{Self, System, AdminCap, ModeratorCap, UserRecord};
use sui::test_scenario;

#[test]
fun test_create_system() {
    let owner = @0xCAFE;
    let mut scenario = test_scenario::begin(owner);
    
    // Create system
    {
        capability1::create_system(b"My System", test_scenario::ctx(&mut scenario));
    };
    
    // Verify
    test_scenario::next_tx(&mut scenario, owner);
    {
        let system = test_scenario::take_shared<System>(&scenario);
        let admin_cap = test_scenario::take_from_sender<AdminCap>(&scenario);
        
        let (name, sys_owner, admins, mods, locked) = capability1::system_info(&system);
        assert!(name == b"My System", 0);
        assert!(sys_owner == owner, 1);
        assert!(admins == 1, 2);
        assert!(mods == 0, 3);
        assert!(locked == false, 4);
        
        test_scenario::return_shared(system);
        test_scenario::return_to_sender(&scenario, admin_cap);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_grant_moderator() {
    let owner = @0xCAFE;
    let moderator = @0xA;
    let mut scenario = test_scenario::begin(owner);
    
    // Setup
    {
        capability1::create_system(b"My System", test_scenario::ctx(&mut scenario));
    };
    
    // Grant moderator
    test_scenario::next_tx(&mut scenario, owner);
    {
        let mut system = test_scenario::take_shared<System>(&scenario);
        let admin_cap = test_scenario::take_from_sender<AdminCap>(&scenario);
        
        capability1::grant_moderator(&admin_cap, &mut system, moderator, true, test_scenario::ctx(&mut scenario));
        
        let (_, _, _, mods, _) = capability1::system_info(&system);
        assert!(mods == 1, 0);
        
        test_scenario::return_shared(system);
        test_scenario::return_to_sender(&scenario, admin_cap);
    };
    
    // Verify moderator received cap
    test_scenario::next_tx(&mut scenario, moderator);
    {
        let mod_cap = test_scenario::take_from_address<ModeratorCap>(&scenario, moderator);
        assert!(capability1::moderator_can_ban(&mod_cap), 0);
        test_scenario::return_to_address(moderator, mod_cap);
    };
    
    test_scenario::end(scenario);
}

#[test]
fun test_ban_user() {
    let owner = @0xCAFE;
    let user = @0xB;
    let mut scenario = test_scenario::begin(owner);
    
    // Setup system
    {
        capability1::create_system(b"My System", test_scenario::ctx(&mut scenario));
    };
    
    // Create user record
    test_scenario::next_tx(&mut scenario, user);
    {
        capability1::create_user_record(test_scenario::ctx(&mut scenario));
    };
    
    // Admin bans user
    test_scenario::next_tx(&mut scenario, owner);
    {
        let admin_cap = test_scenario::take_from_address<AdminCap>(&scenario, owner);
        let mut user_record = test_scenario::take_from_address<UserRecord>(&scenario, user);
        
        capability1::ban_user_with_admin(&admin_cap, &mut user_record);
        
        let (_, is_banned, _) = capability1::user_info(&user_record);
        assert!(is_banned == true, 0);
        
        test_scenario::return_to_address(owner, admin_cap);
        test_scenario::return_to_address(user, user_record);
    };
    
    test_scenario::end(scenario);
}

#[test]
#[expected_failure(abort_code = 1)]
fun test_grant_after_lock_fails() {
    let owner = @0xCAFE;
    let new_admin = @0xD;
    let mut scenario = test_scenario::begin(owner);
    
    // Setup and lock
    {
        capability1::create_system(b"My System", test_scenario::ctx(&mut scenario));
    };
    
    test_scenario::next_tx(&mut scenario, owner);
    {
        let mut system = test_scenario::take_shared<System>(&scenario);
        let admin_cap = test_scenario::take_from_sender<AdminCap>(&scenario);
        
        capability1::lock_system(&admin_cap, &mut system);
        capability1::grant_admin(&admin_cap, &mut system, new_admin, test_scenario::ctx(&mut scenario)); // Should fail
        
        test_scenario::return_shared(system);
        test_scenario::return_to_sender(&scenario, admin_cap);
    };
    
    test_scenario::end(scenario);
}
}
