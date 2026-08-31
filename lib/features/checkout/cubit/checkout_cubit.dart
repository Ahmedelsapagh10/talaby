import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cart/data/cart_repository.dart';
import '../../orders/data/order_repository.dart';
import '../data/models/checkout_details.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._orders, this._cart) : super(const CheckoutState());

  final OrderRepository _orders;
  final CartRepository _cart;

  Future<void> submit(CheckoutDetails details) async {
    final items = _cart.load();
    if (items.isEmpty) {
      emit(
        const CheckoutState(
          status: CheckoutStatus.failure,
          message: 'Cart is empty.',
        ),
      );
      return;
    }
    emit(const CheckoutState(status: CheckoutStatus.loading));
    try {
      final orderId = await _orders.finalizeOrder(
        items: items,
        details: details,
      );
      await _cart.clear();
      emit(CheckoutState(status: CheckoutStatus.success, orderId: orderId));
    } catch (error) {
      emit(
        CheckoutState(
          status: CheckoutStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
