import 'package:equatable/equatable.dart';

import '../../orders/data/models/commerce_order.dart';

enum AdminOrderStatus { initial, loading, success, empty, failure }

class AdminOrderState extends Equatable {
  const AdminOrderState({
    this.status = AdminOrderStatus.initial,
    this.orders = const [],
    this.hasMore = false,
    this.message,
  });

  final AdminOrderStatus status;
  final List<CommerceOrder> orders;
  final bool hasMore;
  final String? message;

  @override
  List<Object?> get props => [status, orders, hasMore, message];
}
