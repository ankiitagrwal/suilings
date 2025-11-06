// Generic container types in Move.
//
// You can build reusable container types using generics.
// Common patterns include Stack, Queue, and Wrapper types.
//
// Type constraints ensure elements have required abilities:
// - store: can be stored in global storage
// - copy: can be copied
// - drop: can be dropped/discarded
//
// Your task:
// Implement a generic Stack and Queue.

module suilings::generics2 {
    use std::vector;
    
    // TODO: Define a Stack<T> struct that wraps a vector
    // T should have drop ability
    // The struct itself should have drop ability
    // Field: items: vector<T>
    public struct Stack<T: drop> has drop {
        items: vector<T>,
    }
    
    // TODO: Define a Queue<T> struct that wraps a vector
    // T should have drop ability
    // The struct itself should have drop ability
    // Field: items: vector<T>
    public struct Queue<T: drop> has drop {
        items: vector<T>,
    }
    
    // ===== Stack Operations =====
    
    public fun create_stack<T: drop>(): Stack<T> {
        // TODO: Create an empty stack
        Stack { items: vector::empty() } // Remove this line and implement correctly
    }
    
    public fun push<T: drop>(stack: &mut Stack<T>, item: T) {
        // TODO: Push an item onto the stack
    }
    
    public fun pop<T: drop>(stack: &mut Stack<T>): T {
        // TODO: Pop and return the top item from the stack
        // Assume stack is non-empty (will abort if empty via vector::pop_back)
        abort 0
    }
    
    public fun peek<T: drop>(stack: &Stack<T>): &T {
        // TODO: Return a reference to the top item without removing it
        // Hint: Use vector::borrow with length - 1
        abort 0
    }
    
    public fun is_empty_stack<T: drop>(stack: &Stack<T>): bool {
        // TODO: Check if stack is empty
        false
    }
    
    // ===== Queue Operations =====
    
    public fun create_queue<T: drop>(): Queue<T> {
        // TODO: Create an empty queue
        Queue { items: vector::empty() } // Remove this line and implement correctly
    }
    
    public fun enqueue<T: drop>(queue: &mut Queue<T>, item: T) {
        // TODO: Add an item to the back of the queue
    }
    
    public fun dequeue<T: drop>(queue: &mut Queue<T>): T {
        // TODO: Remove and return the front item from the queue
        // Hint: Use vector::remove with index 0
        abort 0
    }
    
    public fun front<T: drop>(queue: &Queue<T>): &T {
        // TODO: Return a reference to the front item without removing it
        abort 0
    }
    
    public fun is_empty_queue<T: drop>(queue: &Queue<T>): bool {
        // TODO: Check if queue is empty
        false
    }
}

#[test_only]
module suilings::generics2_tests {
    use suilings::generics2;
    
    #[test]
    fun test_stack_basic() {
        let mut stack = generics2::create_stack<u64>();
        assert!(generics2::is_empty_stack(&stack), 0);
        
        generics2::push(&mut stack, 1);
        generics2::push(&mut stack, 2);
        generics2::push(&mut stack, 3);
        
        assert!(!generics2::is_empty_stack(&stack), 1);
        assert!(*generics2::peek(&stack) == 3, 2);
        
        assert!(generics2::pop(&mut stack) == 3, 3);
        assert!(generics2::pop(&mut stack) == 2, 4);
        assert!(generics2::pop(&mut stack) == 1, 5);
        
        assert!(generics2::is_empty_stack(&stack), 6);
        sui::test_utils::destroy(stack);
    }
    
    #[test]
    fun test_stack_with_strings() {
        use std::string;
        let mut stack = generics2::create_stack<std::string::String>();
        
        generics2::push(&mut stack, string::utf8(b"first"));
        generics2::push(&mut stack, string::utf8(b"second"));
        
        assert!(*generics2::peek(&stack) == string::utf8(b"second"), 0);
        assert!(generics2::pop(&mut stack) == string::utf8(b"second"), 1);
        
        sui::test_utils::destroy(stack);
    }
    
    #[test]
    fun test_queue_basic() {
        let mut queue = generics2::create_queue<u64>();
        assert!(generics2::is_empty_queue(&queue), 0);
        
        generics2::enqueue(&mut queue, 1);
        generics2::enqueue(&mut queue, 2);
        generics2::enqueue(&mut queue, 3);
        
        assert!(!generics2::is_empty_queue(&queue), 1);
        assert!(*generics2::front(&queue) == 1, 2);
        
        assert!(generics2::dequeue(&mut queue) == 1, 3);
        assert!(generics2::dequeue(&mut queue) == 2, 4);
        assert!(generics2::dequeue(&mut queue) == 3, 5);
        
        assert!(generics2::is_empty_queue(&queue), 6);
        sui::test_utils::destroy(queue);
    }
    
    #[test]
    fun test_queue_fifo() {
        let mut queue = generics2::create_queue<u64>();
        
        // Add 1, 2, 3
        generics2::enqueue(&mut queue, 1);
        generics2::enqueue(&mut queue, 2);
        generics2::enqueue(&mut queue, 3);
        
        // Remove 1, add 4
        assert!(generics2::dequeue(&mut queue) == 1, 0);
        generics2::enqueue(&mut queue, 4);
        
        // Should now have: 2, 3, 4
        assert!(generics2::dequeue(&mut queue) == 2, 1);
        assert!(generics2::dequeue(&mut queue) == 3, 2);
        assert!(generics2::dequeue(&mut queue) == 4, 3);
        
        sui::test_utils::destroy(queue);
    }
}


