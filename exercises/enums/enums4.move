// Exercise: Advanced Enum Patterns
//
// Implement complex enum operations with nested data structures.
//
// Stuck? Check out: https://move-book.com/move-basics/enum-and-match.html

module suilings::enums4 {
use std::vector;

/// Payment method with different variants
public enum PaymentMethod has copy, drop {
    CreditCard(u64, vector<u8>), // card number, holder name
    BankTransfer(address),
    Crypto(vector<u8>), // wallet address
    Cash,
}

/// Order status with tracking information
public enum OrderStatus has copy, drop {
    Pending,
    Processing,
    Shipped(vector<u8>), // tracking number
    Delivered,
    Cancelled(vector<u8>), // reason
}

/// Returns the payment type name
public fun payment_type(payment: PaymentMethod): vector<u8> {
    // TODO: Use match to return payment type name
    // CreditCard => b"card", BankTransfer => b"transfer", 
    // Crypto => b"crypto", Cash => b"cash"
    b""
}

/// Extracts card number from CreditCard variant
public fun card_number(payment: PaymentMethod): u64 {
    // TODO: Extract card number from CreditCard variant
    // For other variants, return 0
    0
}

/// Extracts tracking number from Shipped variant
public fun tracking_number(status: OrderStatus): vector<u8> {
    // TODO: Extract tracking number from Shipped variant
    // For other variants, return empty vector
    vector::empty<u8>()
}

/// Checks if order can be cancelled
public fun can_cancel(status: OrderStatus): bool {
    // TODO: Return true if order can be cancelled
    // Can cancel if Pending or Processing
    false
}

#[test]
    fun payment_type_returns_correct_name() {
        let card = PaymentMethod::CreditCard(1234567890, b"John Doe");
        assert!(payment_type(card) == b"card");

        let transfer = PaymentMethod::BankTransfer(@0x123);
        assert!(payment_type(transfer) == b"transfer");

        let crypto = PaymentMethod::Crypto(b"0xabc123");
        assert!(payment_type(crypto) == b"crypto");

        let cash = PaymentMethod::Cash;
        assert!(payment_type(cash) == b"cash");
}

    #[test]
    fun card_number_extracts_from_credit_card() {
        let card = PaymentMethod::CreditCard(9876543210, b"Jane Smith");
        assert!(card_number(card) == 9876543210);

        let cash = PaymentMethod::Cash;
        assert!(card_number(cash) == 0);

        let transfer = PaymentMethod::BankTransfer(@0x456);
        assert!(card_number(transfer) == 0);
}

    #[test]
    fun tracking_number_extracts_from_shipped() {
        let shipped = OrderStatus::Shipped(b"TRACK123");
        let tracking = tracking_number(shipped);
        assert!(tracking == b"TRACK123");

        let pending = OrderStatus::Pending;
        let empty = tracking_number(pending);
        assert!(empty.length() == 0);
}

    #[test]
    fun can_cancel_checks_status_correctly() {
        assert!(can_cancel(OrderStatus::Pending) == true);
        assert!(can_cancel(OrderStatus::Processing) == true);
        assert!(can_cancel(OrderStatus::Delivered) == false);
        assert!(can_cancel(OrderStatus::Shipped(b"TRACK")) == false);
        assert!(can_cancel(OrderStatus::Cancelled(b"reason")) == false);
}

}