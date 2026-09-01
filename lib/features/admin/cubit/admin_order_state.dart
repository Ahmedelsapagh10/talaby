import 'package:equatable/equatable.dart';

import '../../../core/utils/search_normalizer.dart';
import '../../orders/data/models/commerce_order.dart';
import '../../orders/data/models/order_status.dart';

enum AdminOrderStatus { initial, loading, success, empty, failure }

class AdminOrderState extends Equatable {
  const AdminOrderState({
    this.status = AdminOrderStatus.initial,
    this.orders = const [],
    this.hasMore = false,
    this.isUpdating = false,
    this.query = '',
    this.statusFilter,
    this.message,
  });

  final AdminOrderStatus status;
  final List<CommerceOrder> orders;
  final bool hasMore;
  final bool isUpdating;
  final String query;
  final OrderStatus? statusFilter;
  final String? message;

  List<CommerceOrder> get visibleOrders {
    final normalized = SearchNormalizer.normalize(query);
    final phoneQuery = RegExp(r'^\+?[0-9 ()-]+$').hasMatch(query.trim())
        ? SearchNormalizer.normalizePhone(query)
        : null;
    return orders.where((order) {
      if (statusFilter != null && order.orderStatus != statusFilter) {
        return false;
      }
      if (normalized.isEmpty) return true;
      return order.readableOrderNumber.toLowerCase().contains(normalized) ||
          order.customerName.toLowerCase().contains(normalized) ||
          (phoneQuery != null &&
              SearchNormalizer.normalizePhone(
                order.phone,
              ).contains(phoneQuery));
    }).toList();
  }

  AdminOrderState copyWith({
    AdminOrderStatus? status,
    List<CommerceOrder>? orders,
    bool? hasMore,
    bool? isUpdating,
    String? query,
    OrderStatus? statusFilter,
    bool clearStatus = false,
    String? message,
  }) => AdminOrderState(
    status: status ?? this.status,
    orders: orders ?? this.orders,
    hasMore: hasMore ?? this.hasMore,
    isUpdating: isUpdating ?? this.isUpdating,
    query: query ?? this.query,
    statusFilter: clearStatus ? null : statusFilter ?? this.statusFilter,
    message: message,
  );

  @override
  List<Object?> get props => [
    status,
    orders,
    hasMore,
    isUpdating,
    query,
    statusFilter,
    message,
  ];
}
