import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_event.dart';
import 'order_item.dart';
import 'order_status.dart';
import 'payment_record.dart';
import 'payment_status.dart';

class CommerceOrder {
  const CommerceOrder({
    required this.id,
    required this.readableOrderNumber,
    required this.ownerId,
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.city,
    required this.address,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.total,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    required this.orderStatus,
    this.notes,
    this.deliveryFee,
    this.payments = const [],
    this.events = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String readableOrderNumber;
  final String ownerId;
  final String customerId;
  final String customerName;
  final String phone;
  final String city;
  final String address;
  final String? notes;
  final List<OrderItem> items;
  final int subtotal;
  final int discountAmount;
  final int? deliveryFee;
  final int total;
  final int paidAmount;
  final int remainingAmount;
  final PaymentStatus paymentStatus;
  final OrderStatus orderStatus;
  final List<PaymentRecord> payments;
  final List<OrderEvent> events;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  List<OrderEvent> get customerTimeline =>
      events.where((event) => event.customerVisible).toList();

  factory CommerceOrder.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? const <String, dynamic>{};
    return CommerceOrder(
      id: doc.id,
      readableOrderNumber: map['readableOrderNumber']?.toString() ?? '',
      ownerId: map['ownerId']?.toString() ?? '',
      customerId: map['customerId']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      notes: map['notes']?.toString(),
      items: _maps(map['items']).map(OrderItem.fromMap).toList(),
      subtotal: (map['subtotal'] as num?)?.toInt() ?? 0,
      discountAmount: (map['discountAmount'] as num?)?.toInt() ?? 0,
      deliveryFee: (map['deliveryFee'] as num?)?.toInt(),
      total: (map['total'] as num?)?.toInt() ?? 0,
      paidAmount: (map['paidAmount'] as num?)?.toInt() ?? 0,
      remainingAmount: (map['remainingAmount'] as num?)?.toInt() ?? 0,
      paymentStatus: PaymentStatusCodec.fromValue(map['paymentStatus']),
      orderStatus: OrderStatusCodec.fromValue(map['orderStatus']),
      payments: _maps(map['payments']).map(PaymentRecord.fromMap).toList(),
      events: _maps(map['events']).map(OrderEvent.fromMap).toList(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  static Iterable<Map<String, dynamic>> _maps(Object? value) {
    return (value as List? ?? const []).whereType<Map>().map(
      (item) => Map<String, dynamic>.from(item),
    );
  }
}
