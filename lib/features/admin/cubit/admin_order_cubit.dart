import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../orders/data/models/order_status.dart';
import '../../orders/data/order_repository.dart';
import 'admin_order_state.dart';

class AdminOrderCubit extends Cubit<AdminOrderState> {
  AdminOrderCubit(this._repository) : super(const AdminOrderState());

  final OrderRepository _repository;
  DocumentSnapshot<Map<String, dynamic>>? _cursor;

  Future<void> load() async {
    emit(const AdminOrderState(status: AdminOrderStatus.loading));
    try {
      final page = await _repository.getOrders(limit: 30);
      _cursor = page.nextCursor;
      emit(
        AdminOrderState(
          status: page.orders.isEmpty
              ? AdminOrderStatus.empty
              : AdminOrderStatus.success,
          orders: page.orders,
          hasMore: page.hasMore,
        ),
      );
    } catch (error) {
      emit(
        AdminOrderState(
          status: AdminOrderStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (_cursor == null) return;
    try {
      final page = await _repository.getOrders(limit: 30, after: _cursor);
      _cursor = page.nextCursor;
      emit(
        AdminOrderState(
          status: AdminOrderStatus.success,
          orders: [...state.orders, ...page.orders],
          hasMore: page.hasMore,
        ),
      );
    } catch (error) {
      emit(
        AdminOrderState(
          status: AdminOrderStatus.failure,
          orders: state.orders,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _repository.updateStatus(orderId, status);
    await load();
  }

  Future<void> updateDeliveryFee(String orderId, int fee) async {
    await _repository.updateDeliveryFee(orderId, fee);
    await load();
  }

  Future<void> reviewPayment({
    required String orderId,
    required String paymentId,
    required bool approved,
    int? confirmedAmount,
  }) async {
    await _repository.reviewPayment(
      orderId: orderId,
      paymentId: paymentId,
      approved: approved,
      confirmedAmount: confirmedAmount,
    );
    await load();
  }
}
