// Exercise: Struct Abilities
//
// Practice using struct abilities: copy, drop, store, and key.
//
// Stuck? Check out: https://move-book.com/move-basics/abilities-introduction.html

module suilings::struct_abilities;

// TODO: Add 'drop' ability so this struct can be destroyed
/// Temporary data that can be destroyed
public struct TemporaryData {
    value: u64,
}

// TODO: Add 'copy' and 'drop' abilities
/// A point in 2D space that can be copied and dropped
public struct Point {
    x: u64,
    y: u64,
}

// TODO: Add 'store' and 'drop' abilities
/// Character statistics that can be stored in other structs
public struct Stats {
    health: u64,
    mana: u64,
}

/// Creates a temporary data value
public fun create_temporary(value: u64): TemporaryData {
    TemporaryData { value }
}

/// Creates a point at the given coordinates
public fun create_point(x: u64, y: u64): Point {
    Point { x, y }
}

/// Creates stats with the given values
public fun create_stats(health: u64, mana: u64): Stats {
    Stats { health, mana }
}

/// Returns a copy of the point (works because Point has 'copy')
public fun copy_point(p: Point): Point {
    p
}

/// Returns the x coordinate of a point
public fun point_x(p: &Point): u64 {
    p.x
}

/// Returns the y coordinate of a point
public fun point_y(p: &Point): u64 {
    p.y
}

/// Returns the health value from stats
public fun stats_health(s: &Stats): u64 {
    s.health
}

#[test_only]
module suilings::struct_abilities_tests;

use suilings::struct_abilities;

#[test]
fun temporary_data_can_be_dropped() {
    let _temp = struct_abilities::create_temporary(42);
    // temp is automatically dropped
}

#[test]
fun point_can_be_copied() {
    let p1 = struct_abilities::create_point(10, 20);
    let p2 = struct_abilities::copy_point(p1);
    // Both p1 and p2 are valid because Point has 'copy'
    assert!(struct_abilities::point_x(&p1) == 10 && struct_abilities::point_x(&p2) == 10);
}

#[test]
fun stats_can_be_stored() {
    let stats = struct_abilities::create_stats(100, 50);
    assert!(struct_abilities::stats_health(&stats) == 100);
}