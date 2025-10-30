// This exercise introduces a simple Hello World module in Move for the Sui blockchain.
// Your task is to ensure the module compiles successfully.
// Fix the syntax error in the function and remove the "I AM NOT DONE" comment.

module suilings::intro1 {
    public fun say_hello(): vector<u8> {
        b"Hello World" // Fix this line to return a valid string
}
}