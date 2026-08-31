import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderEventType {
  orderCreated,
  orderConfirmed,
  deliveryFeeUpdated,
  paymentProofSubmitted,
  paymentApproved,
  paymentRejected,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
  returned,
}

extension OrderEventTypeCodec on OrderEventType {
  String get value => name;

  static OrderEventType fromValue(Object? value) {
    return OrderEventType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => OrderEventType.orderCreated,
    );
  }
}

class OrderEvent {
  const OrderEvent({
    required this.type,
    required this.customerVisible,
    this.timestamp,
    this.performedBy,
    this.metadata = const {},
  });

  final OrderEventType type;
  final DateTime? timestamp;
  final String? performedBy;
  final Map<String, dynamic> metadata;
  final bool customerVisible;

  factory OrderEvent.fromMap(Map<String, dynamic> map) => OrderEvent(
    type: OrderEventTypeCodec.fromValue(map['type']),
    timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    performedBy: map['performedBy']?.toString(),
    metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? const {}),
    customerVisible: map['customerVisible'] as bool? ?? false,
  );
}
