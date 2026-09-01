import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../orders/data/models/order_status.dart';
import '../../orders/data/order_repository.dart';
import 'admin_order_state.dart';

class AdminOrderCubit extends Cubit<AdminOrderState> {
  AdminOrderCubit(this._repository) : super(const AdminOrderState());

  final OrderRepository _repository;
  DocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _searchPrepared = false;
  bool _loadingMore = false;
  Timer? _searchDebounce;

  Future<void> load({String? searchQuery, OrderStatus? statusFilter}) async {
    final query = searchQuery ?? state.query;
    final selectedStatus = statusFilter ?? state.statusFilter;
    emit(
      AdminOrderState(
        status: AdminOrderStatus.loading,
        orders: state.orders,
        query: query,
        statusFilter: selectedStatus,
      ),
    );
    try {
      if (!_searchPrepared) {
        await _repository.backfillSearchPrefixes();
        _searchPrepared = true;
      }
      final page = await _repository.getOrders(
        limit: 30,
        searchQuery: query,
        status: selectedStatus,
      );
      _cursor = page.nextCursor;
      emit(
        AdminOrderState(
          status: page.orders.isEmpty
              ? AdminOrderStatus.empty
              : AdminOrderStatus.success,
          orders: page.orders,
          hasMore: page.hasMore,
          query: query,
          statusFilter: selectedStatus,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AdminOrderStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (_cursor == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await _repository.getOrders(
        limit: 30,
        searchQuery: state.query,
        status: state.statusFilter,
        after: _cursor,
      );
      _cursor = page.nextCursor;
      emit(
        state.copyWith(
          status: AdminOrderStatus.success,
          orders: [...state.orders, ...page.orders],
          hasMore: page.hasMore,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AdminOrderStatus.failure,
          message: error.toString(),
        ),
      );
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _update(() => _repository.updateStatus(orderId, status));
  }

  Future<void> updateDeliveryFee(String orderId, int fee) async {
    await _update(() => _repository.updateDeliveryFee(orderId, fee));
  }

  Future<void> reviewPayment({
    required String orderId,
    required String paymentId,
    required bool approved,
    int? confirmedAmount,
  }) async {
    await _update(
      () => _repository.reviewPayment(
        orderId: orderId,
        paymentId: paymentId,
        approved: approved,
        confirmedAmount: confirmedAmount,
      ),
    );
  }

  void setQuery(String value) {
    emit(state.copyWith(query: value));
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => load(searchQuery: value),
    );
  }

  void setStatusFilter(OrderStatus? value) {
    emit(state.copyWith(statusFilter: value, clearStatus: value == null));
    load(statusFilter: value);
  }

  Future<void> _update(Future<void> Function() operation) async {
    emit(state.copyWith(isUpdating: true));
    try {
      await operation();
      await load();
    } catch (error) {
      emit(
        state.copyWith(
          status: AdminOrderStatus.failure,
          isUpdating: false,
          message: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    _searchDebounce?.cancel();
    return super.close();
  }
}
