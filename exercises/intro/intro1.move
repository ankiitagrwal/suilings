// This exercise introduces a simple Hello World module in Move for the Sui blockchain.
// Your task is to ensure the module compiles successfully.

module suilings::intro1 {
    public fun say_hello(): vector<u8> {
        b"Hello World"
}
}