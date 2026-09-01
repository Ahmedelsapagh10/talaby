import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.orderCount,
    this.defaultCity,
    this.defaultAddress,
    this.email,
    this.lastOrderAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String phone;
  final int orderCount;
  final String? defaultCity;
  final String? defaultAddress;
  final String? email;
  final DateTime? lastOrderAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Customer.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? const <String, dynamic>{};
    return Customer(
      id: doc.id,
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      orderCount: (map['orderCount'] as num?)?.toInt() ?? 0,
      defaultCity: map['defaultCity']?.toString(),
      defaultAddress: map['defaultAddress']?.toString(),
      email: map['email']?.toString(),
      lastOrderAt: (map['lastOrderAt'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
