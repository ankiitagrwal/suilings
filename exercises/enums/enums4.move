// Advanced enum patterns: nested matching, enum methods, and complex data.
//
// Your task:
// Implement complex enum operations with nested data structures.

module suilings::enums4 {
    use std::vector;
    
    public enum PaymentMethod {
        CreditCard(u64, vector<u8>), // card number, holder name
        BankTransfer(address),
        Crypto(vector<u8>), // wallet address
        Cash,
    }
    
    public enum OrderStatus {
        Pending,
        Processing,
        Shipped(vector<u8>), // tracking number
        Delivered,
        Cancelled(vector<u8>), // reason
    }
    
    public fun get_payment_type(payment: PaymentMethod): vector<u8> {
        // TODO: Use match to return payment type name
        // CreditCard => b"card", BankTransfer => b"transfer", etc.
        b""
    }
    
    public fun get_card_number(payment: PaymentMethod): u64 {
        // TODO: Extract card number from CreditCard variant
        // For other variants, return 0
        0
    }
    
    public fun get_tracking_number(status: OrderStatus): vector<u8> {
        // TODO: Extract tracking number from Shipped variant
        // For other variants, return empty vector
        vector::empty<u8>()
    }
    
    public fun can_cancel(status: OrderStatus): bool {
        // TODO: Return true if order can be cancelled
        // Can cancel if Pending or Processing
        false
    }
}

#[test_only]
module suilings::enums4_tests {
    use suilings::enums4;
    use std::vector;
    
    #[test]
    fun test_payment_type() {
        let card = enums4::PaymentMethod::CreditCard(1234567890, b"John Doe");
        assert!(enums4::get_payment_type(card) == b"card", 0);
        
        let transfer = enums4::PaymentMethod::BankTransfer(@0x123);
        assert!(enums4::get_payment_type(transfer) == b"transfer", 1);
    }
    
    #[test]
    fun test_get_card_number() {
        let card = enums4::PaymentMethod::CreditCard(9876543210, b"Jane Smith");
        assert!(enums4::get_card_number(card) == 9876543210, 0);
        
        let cash = enums4::PaymentMethod::Cash;
        assert!(enums4::get_card_number(cash) == 0, 1);
    }
    
    #[test]
    fun test_tracking_number() {
        let shipped = enums4::OrderStatus::Shipped(b"TRACK123");
        let tracking = enums4::get_tracking_number(shipped);
        assert!(tracking == b"TRACK123", 0);
    }
    
    #[test]
    fun test_can_cancel() {
        assert!(enums4::can_cancel(enums4::OrderStatus::Pending) == true, 0);
        assert!(enums4::can_cancel(enums4::OrderStatus::Processing) == true, 1);
        assert!(enums4::can_cancel(enums4::OrderStatus::Delivered) == false, 2);
    }
}

