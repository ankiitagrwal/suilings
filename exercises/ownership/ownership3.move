// Exercise: Copy vs Move Semantics
//
// Understand when values are copied vs moved based on abilities.
//
// Stuck? Check out: https://move-book.com/move-basics/copy-ability.html

module suilings::ownership3 {
/// Point that can be copied
public struct Point has copy, drop {
    x: u64,
    y: u64,
}

/// Box that must be moved (no copy ability)
public struct UniqueBox has drop {
    id: u64,
    data: vector<u8>,
}

/// Creates a new point
public fun create_point(x: u64, y: u64): Point {
    // Todo: Create and return a Point
    abort 0
}

/// Creates a new box
public fun create_box(id: u64, data: vector<u8>): UniqueBox {
    // TODO: Create and return a UniqueBox
    abort 0
}

/// Returns two copies of the point
public fun copy_point(point: Point): (Point, Point) {
    // TODO: Return two copies of the point
    // Since Point has 'copy', you can use it multiple times
    abort 0
}

/// Moves the box (transfers ownership)
public fun move_box(box: UniqueBox): UniqueBox {
    // TODO: Return the box (it's moved, not copied)
    // UniqueBox doesn't have 'copy', so ownership is transferred
    abort 0
}

#[test]
    fun copy_point_works() {
        let point = create_point(3, 4);
        let (p1, p2) = copy_point(point);
        assert!(p1.x == 3 && p1.y == 4);
        assert!(p2.x == 3 && p2.y == 4);
// Original point can still be used (it was copied)
        assert!(point.x == 3);
}

    #[test]
    fun move_box_works() {
        let box = create_box(1, b"data");
        let moved_box = move_box(box);
// box is now consumed and cannot be used
// moved_box is the new owner

// Verify the box was moved successfully (it gets dropped at the end)
        sui::test_utils::destroy(moved_box);
}

}