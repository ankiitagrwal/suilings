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
       // Todo: Create and return a Point
    }
    
    public fun create_box(id: u64, data: vector<u8>): UniqueBox {
        // TODO: Create and return a UniqueBox
    }
    
    public fun copy_point(point: Point): (Point, Point) {
        // TODO: Return two copies of the point
        // Since Point has 'copy', you can use it multiple times
      
    }
    
    public fun move_box(box: UniqueBox): UniqueBox {
        // TODO: Return the box (it's moved, not copied)
        // UniqueBox doesn't have 'copy', so ownership is transferred
        
    }
    
    #[test]
    fun test_copy_point() {
        let point = create_point(3, 4);
        let (p1, p2) = copy_point(point);
        assert!(p1.x == 3 && p1.y == 4, 0);
        assert!(p2.x == 3 && p2.y == 4, 1);
        // Original point can still be used (it was copied)
        assert!(point.x == 3, 2);
    }
    
    #[test]
    fun test_move_box() {
        let box = create_box(1, b"data");
        let moved_box = move_box(box);
        // box is now consumed and cannot be used
        // moved_box is the new owner
        
        // Verify the box was moved successfully (it gets dropped at the end)
        sui::test_utils::destroy(moved_box);
    }
}

