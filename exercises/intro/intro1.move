// Exercise: Hello World in Move
//
// Complete the function to make it compile.
//
// Stuck? Check out: https://move-book.com/your-first-move/hello-world.html

module suilings::intro1;

/// Returns a "Hello World" message as a byte vector.
public fun say_hello(): vector<u8> {
    b"Hello World"
}