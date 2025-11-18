// Exercise: Generic Containers
//
// Implement reusable container types using generics (Stack and Queue).
//
// Stuck? Check out: https://move-book.com/move-basics/generics.html

module suilings::generics2 {
use std::vector;

// TODO: Define a Stack<T> struct that wraps a vector
// T should have drop ability
// The struct itself should have drop ability
// Field: items: vector<T>

// TODO: Define a Queue<T> struct that wraps a vector
// T should have drop ability
// The struct itself should have drop ability
// Field: items: vector<T>

// ===== Stack Operations =====

/// Creates an empty stack
public fun create_stack<T: drop>(): Stack<T> {
    // TODO: Create an empty stack
    abort 0
}

/// Pushes an item onto the stack
public fun push<T: drop>(stack: &mut Stack<T>, item: T) {
    // TODO: Push an item onto the stack
}

/// Pops an item from the stack
public fun pop<T: drop>(stack: &mut Stack<T>): T {
    // TODO: Pop and return the top item from the stack
    // Assume stack is non-empty (will abort if empty via vector::pop_back)
    abort 0
}

/// Returns a reference to the top item
public fun peek<T: drop>(stack: &Stack<T>): &T {
    // TODO: Return a reference to the top item without removing it
    // Hint: Use vector::borrow with length - 1
    abort 0
}

/// Checks if the stack is empty
public fun is_empty_stack<T: drop>(stack: &Stack<T>): bool {
    // TODO: Check if stack is empty
    false
}

// ===== Queue Operations =====

/// Creates an empty queue
public fun create_queue<T: drop>(): Queue<T> {
    // TODO: Create an empty queue
    abort 0
}

/// Adds an item to the back of the queue
public fun enqueue<T: drop>(queue: &mut Queue<T>, item: T) {
    // TODO: Add an item to the back of the queue
}

/// Removes and returns the front item from the queue
public fun dequeue<T: drop>(queue: &mut Queue<T>): T {
    // TODO: Remove and return the front item from the queue
    // Hint: Use vector::remove with index 0
    abort 0
}

/// Returns a reference to the front item
public fun front<T: drop>(queue: &Queue<T>): &T {
    // TODO: Return a reference to the front item without removing it
    abort 0
}

/// Checks if the queue is empty
public fun is_empty_queue<T: drop>(queue: &Queue<T>): bool {
    // TODO: Check if queue is empty
    false
    }}

#[test_only]
module suilings::generics2_tests {

    use suilings::generics2;

    #[test]
    fun stack_basic_works() {
    let mut stack = generics2::create_stack<u64>();
    assert!(generics2::is_empty_stack(&stack));

    generics2::push(&mut stack, 1);
    generics2::push(&mut stack, 2);
    generics2::push(&mut stack, 3);

    assert!(!generics2::is_empty_stack(&stack));
    assert!(*generics2::peek(&stack) == 3);

    assert!(generics2::pop(&mut stack) == 3);
    assert!(generics2::pop(&mut stack) == 2);
    assert!(generics2::pop(&mut stack) == 1);

    assert!(generics2::is_empty_stack(&stack));
    sui::test_utils::destroy(stack);
}

#[test]
    fun stack_with_strings_works() {
use std::string;
        let mut stack = generics2::create_stack<std::string::String>();

        generics2::push(&mut stack, string::utf8(b"first"));
        generics2::push(&mut stack, string::utf8(b"second"));

        assert!(*generics2::peek(&stack) == string::utf8(b"second"));
        assert!(generics2::pop(&mut stack) == string::utf8(b"second"));

        sui::test_utils::destroy(stack);
}

    #[test]
    fun queue_basic_works() {
        let mut queue = generics2::create_queue<u64>();
        assert!(generics2::is_empty_queue(&queue));

        generics2::enqueue(&mut queue, 1);
        generics2::enqueue(&mut queue, 2);
        generics2::enqueue(&mut queue, 3);

        assert!(!generics2::is_empty_queue(&queue));
        assert!(*generics2::front(&queue) == 1);

        assert!(generics2::dequeue(&mut queue) == 1);
        assert!(generics2::dequeue(&mut queue) == 2);
        assert!(generics2::dequeue(&mut queue) == 3);

        assert!(generics2::is_empty_queue(&queue));
        sui::test_utils::destroy(queue);
}

    #[test]
    fun queue_fifo_works() {
        let mut queue = generics2::create_queue<u64>();

// Add 1, 2, 3
        generics2::enqueue(&mut queue, 1);
        generics2::enqueue(&mut queue, 2);
        generics2::enqueue(&mut queue, 3);

// Remove 1, add 4
        assert!(generics2::dequeue(&mut queue) == 1);
        generics2::enqueue(&mut queue, 4);

// Should now have: 2, 3, 4
        assert!(generics2::dequeue(&mut queue) == 2);
        assert!(generics2::dequeue(&mut queue) == 3);
        assert!(generics2::dequeue(&mut queue) == 4);

        sui::test_utils::destroy(queue);
}

}