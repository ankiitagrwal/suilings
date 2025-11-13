// Advanced enum patterns: nested matching, enum methods, and complex data.
//
// Your task:
// Implement complex enum operations with nested data structures.

module suilings::enums4 {
    use std::vector;
    
    public enum PaymentMethod has copy, drop {
        CreditCard(u64, vector<u8>), // card number, holder name
        BankTransfer(address),
        Crypto(vector<u8>), // wallet address
        Cash,
    }
    
    public enum OrderStatus has copy, drop {
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

    #[test_only]
    #[test]
    fun test_payment_type() {
        let card = PaymentMethod::CreditCard(1234567890, b"John Doe");
        assert!(get_payment_type(card) == b"card", 0);
        
        let transfer = PaymentMethod::BankTransfer(@0x123);
        assert!(get_payment_type(transfer) == b"transfer", 1);
        
        let crypto = PaymentMethod::Crypto(b"0xabc123");
        assert!(get_payment_type(crypto) == b"crypto", 2);
        
        let cash = PaymentMethod::Cash;
        assert!(get_payment_type(cash) == b"cash", 3);
    }
    
    #[test_only]
    #[test]
    fun test_get_card_number() {
        let card = PaymentMethod::CreditCard(9876543210, b"Jane Smith");
        assert!(get_card_number(card) == 9876543210, 0);
        
        let cash = PaymentMethod::Cash;
        assert!(get_card_number(cash) == 0, 1);
        
        let transfer = PaymentMethod::BankTransfer(@0x456);
        assert!(get_card_number(transfer) == 0, 2);
    }
    
    #[test_only]
    #[test]
    fun test_tracking_number() {
        let shipped = OrderStatus::Shipped(b"TRACK123");
        let tracking = get_tracking_number(shipped);
        assert!(tracking == b"TRACK123", 0);
        
        let pending = OrderStatus::Pending;
        let empty = get_tracking_number(pending);
        assert!(vector::length(&empty) == 0, 1);
    }
    
    #[test_only]
    #[test]
    fun test_can_cancel() {
        assert!(can_cancel(OrderStatus::Pending) == true, 0);
        assert!(can_cancel(OrderStatus::Processing) == true, 1);
        assert!(can_cancel(OrderStatus::Delivered) == false, 2);
        assert!(can_cancel(OrderStatus::Shipped(b"TRACK")) == false, 3);
        assert!(can_cancel(OrderStatus::Cancelled(b"reason")) == false, 4);
    }
}

