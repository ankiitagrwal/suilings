// ==== STRUCT ABILITIES EXERCISE ====
// Structs in Move can have abilities: copy, drop, store, and key
// - copy: The value can be copied
// - drop: The value can be dropped/destroyed
// - store: The value can be stored inside other structs
// - key: The value can be used as a key for global storage
//
// Your task:
// Add the correct abilities to each struct based on the requirements

module suilings::struct_abilities {
    // TODO: Add 'drop' ability so this struct can be destroyed
    public struct TemporaryData {
        value: u64,
    }
    
    // TODO: Add 'copy' and 'drop' abilities so this struct can be copied and destroyed
    public struct Point {
        x: u64,
        y: u64,
    }
    
    // TODO: Add 'store' and 'drop' abilities so this can be stored in other structs
    public struct Stats {
        health: u64,
        mana: u64,
    }
    
    public fun create_temporary(value: u64): TemporaryData {
        TemporaryData { value }
    }
    
    public fun create_point(x: u64, y: u64): Point {
        Point { x, y }
    }
    
    public fun create_stats(health: u64, mana: u64): Stats {
        Stats { health, mana }
    }
    
    // This function should work because Point has 'copy'
    public fun copy_point(p: Point): Point {
        p
    }
    
    // Getter functions to access fields from tests
    public fun get_point_x(p: &Point): u64 {
        p.x
    }
    
    public fun get_point_y(p: &Point): u64 {
        p.y
    }
    
    public fun get_stats_health(s: &Stats): u64 {
        s.health
    }
}

#[test_only]
module suilings::struct_abilities_tests {
    use suilings::struct_abilities;
    
    #[test]
    fun test_temporary_data() {
        let _temp = struct_abilities::create_temporary(42);
        // temp should be automatically dropped
    }
    
    #[test]
    fun test_point_copy() {
        let p1 = struct_abilities::create_point(10, 20);
        let p2 = struct_abilities::copy_point(p1);
        // Both p1 and p2 should be valid because Point has 'copy'
        assert!(struct_abilities::get_point_x(&p1) == 10 && struct_abilities::get_point_x(&p2) == 10, 0);
    }
    
    #[test]
    fun test_stats() {
        let stats = struct_abilities::create_stats(100, 50);
        // stats should be droppable
        assert!(struct_abilities::get_stats_health(&stats) == 100, 0);
    }
}

