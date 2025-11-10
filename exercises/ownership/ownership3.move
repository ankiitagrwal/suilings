// Copy vs Move: Types with 'copy' ability can be copied instead of moved.
// Without 'copy', values are moved (ownership transferred).
//
// Your task:
// Understand when values are copied vs moved.

module suilings::ownership3 {
    // This struct has 'copy' ability, so it can be copied
    public struct Point has copy, drop {
        x: u64,
        y: u64,
    }
    
    // This struct does NOT have 'copy', so it must be moved
    public struct UniqueBox has drop {
        id: u64,
        data: vector<u8>,
    }
    
    public fun create_point(x: u64, y: u64): Point {
        Point { x, y }
    }
    
    public fun create_box(id: u64, data: vector<u8>): UniqueBox {
        UniqueBox { id, data }
    }
    
    public fun copy_point(point: Point): (Point, Point) {
        // TODO: Return two copies of the point
        // Since Point has 'copy', you can use it multiple times
        (point, point)
    }
    
    public fun move_box(box: UniqueBox): UniqueBox {
        // TODO: Return the box (it's moved, not copied)
        // UniqueBox doesn't have 'copy', so ownership is transferred
        box
    }
    
    public fun get_point_x(point: Point): u64 {
        // TODO: Return x coordinate
        // Point has 'copy', so point is copied, not moved
        point.x
    }
}

#[test_only]
module suilings::ownership3_tests {
    use suilings::ownership3;
    
    #[test]
    fun test_copy_point() {
        let point = ownership3::create_point(3, 4);
        let (p1, p2) = ownership3::copy_point(point);
        assert!(p1.x == 3 && p1.y == 4, 0);
        assert!(p2.x == 3 && p2.y == 4, 1);
        // Original point can still be used (it was copied)
        let x = ownership3::get_point_x(point);
        assert!(x == 3, 2);
    }
    
    #[test]
    fun test_move_box() {
        let box = ownership3::create_box(1, b"data");
        let moved_box = ownership3::move_box(box);
        // box is now consumed and cannot be used
        // moved_box is the new owner
    }
}

