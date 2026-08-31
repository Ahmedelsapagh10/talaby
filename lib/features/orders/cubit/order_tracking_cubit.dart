import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/commerce_order.dart';
import '../data/order_repository.dart';
import 'order_tracking_state.dart';

class OrderTrackingCubit extends Cubit<OrderTrackingState> {
  OrderTrackingCubit(this._repository) : super(const OrderTrackingState());

  final OrderRepository _repository;
  StreamSubscription<CommerceOrder?>? _subscription;

  Future<void> watch(String orderId) async {
    emit(const OrderTrackingState(status: OrderTrackingStatus.loading));
    await _subscription?.cancel();
    _subscription = _repository
        .watchOrder(orderId)
        .listen(
          (order) => emit(
            OrderTrackingState(
              status: order == null
                  ? OrderTrackingStatus.empty
                  : OrderTrackingStatus.success,
              order: order,
            ),
          ),
          onError: (Object error) => emit(
            OrderTrackingState(
              status: OrderTrackingStatus.failure,
              message: error.toString(),
            ),
          ),
        );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
