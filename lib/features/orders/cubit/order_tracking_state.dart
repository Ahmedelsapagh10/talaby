import 'package:equatable/equatable.dart';

import '../data/models/commerce_order.dart';

enum OrderTrackingStatus { initial, loading, success, empty, failure }

class OrderTrackingState extends Equatable {
  const OrderTrackingState({
    this.status = OrderTrackingStatus.initial,
    this.order,
    this.message,
  });

  final OrderTrackingStatus status;
  final CommerceOrder? order;
  final String? message;

  @override
  List<Object?> get props => [status, order, message];
}
