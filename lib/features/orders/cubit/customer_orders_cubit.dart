import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/order_repository.dart';
import 'customer_orders_state.dart';

class CustomerOrdersCubit extends Cubit<CustomerOrdersState> {
  CustomerOrdersCubit(this._repository) : super(const CustomerOrdersState());

  final OrderRepository _repository;
  DocumentSnapshot<Map<String, dynamic>>? _cursor;
  String? _customerId;
  bool _loadingMore = false;

  Future<void> load(String customerId) async {
    _customerId = customerId;
    emit(const CustomerOrdersState(status: CustomerOrdersStatus.loading));
    try {
      final page = await _repository.getOrders(
        limit: 20,
        customerId: customerId,
      );
      _cursor = page.nextCursor;
      emit(
        CustomerOrdersState(
          status: page.orders.isEmpty
              ? CustomerOrdersStatus.empty
              : CustomerOrdersStatus.success,
          orders: page.orders,
          hasMore: page.hasMore,
        ),
      );
    } catch (error) {
      _emitFailure(error);
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || _cursor == null || _customerId == null) return;
    _loadingMore = true;
    try {
      final page = await _repository.getOrders(
        limit: 20,
        customerId: _customerId,
        after: _cursor,
      );
      _cursor = page.nextCursor;
      emit(
        state.copyWith(
          status: CustomerOrdersStatus.success,
          orders: [...state.orders, ...page.orders],
          hasMore: page.hasMore,
        ),
      );
    } catch (error) {
      _emitFailure(error);
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> submitPaymentProof({
    required String orderId,
    required int claimedAmount,
  }) async {
    emit(state.copyWith(isSubmittingProof: true, proofSubmitted: false));
    try {
      final submitted = await _repository.submitPaymentProof(
        orderId: orderId,
        claimedAmount: claimedAmount,
      );
      emit(state.copyWith(isSubmittingProof: false, proofSubmitted: submitted));
    } catch (error) {
      _emitFailure(error);
    }
  }

  void _emitFailure(Object error) {
    emit(
      state.copyWith(
        status: CustomerOrdersStatus.failure,
        isSubmittingProof: false,
        proofSubmitted: false,
        message: error.toString(),
      ),
    );
  }
}
