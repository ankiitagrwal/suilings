// ==== MODULE IMPORT EXERCISE ====
// Move lets you `use` a function from another module.
// The runner-crate contains a tiny helper module that we can import.
//
// Your task:
// 1. Add a `use` statement to import `math::add`.
// 2. Implement `sum_three` using the imported `add` function.
//
// The helper module is automatically available because the
// runner-crate’s Move.toml publishes it at address `suilings`.


module suilings::calculator {

    // <-- add the `use` line here
    public fun sum_three(x: u64, y: u64, z: u64): u64 {
        // replace the dummy return with a call to `add`
        0
    }

    #[test]
    fun test_sum_three() {
        assert!(sum_three(1, 2, 3) == 6, 0);
        assert!(sum_three(10, 20, 30) == 60, 0);
    }
}

// -------------------------------------------------------------------
// Helper module – defined **in the same file** (no extra .move needed)
// -------------------------------------------------------------------
module suilings::math {
    /// Simple addition – used by the import exercise.
    public fun add(a: u64, b: u64): u64 {
        a + b
    }
}