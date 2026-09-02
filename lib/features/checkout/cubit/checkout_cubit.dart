import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/data/auth_repository.dart';
import '../../cart/data/cart_repository.dart';
import '../../orders/data/order_repository.dart';
import '../data/models/checkout_details.dart';
import '../../profile/data/profile_repository.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._orders, this._cart, this._profiles, this._auth)
    : super(const CheckoutState());

  final OrderRepository _orders;
  final CartRepository _cart;
  final ProfileRepository _profiles;
  final AuthRepository _auth;

  Future<void> loadProfile(String userId) async {
    try {
      final profile = await _profiles.getProfile(userId);
      emit(CheckoutState(profile: profile));
    } catch (_) {
      // Checkout remains usable when optional profile defaults cannot load.
    }
  }

  Future<void> submit(CheckoutDetails details) async {
    final items = _cart.load();
    if (items.isEmpty) {
      emit(
        const CheckoutState(
          status: CheckoutStatus.failure,
          message: 'cart_empty',
        ),
      );
      return;
    }
    emit(CheckoutState(status: CheckoutStatus.loading, profile: state.profile));
    try {
      // Ensure a Firebase user exists; signs in anonymously if needed.
      await _auth.startGuestCheckout();

      final orderId = await _orders.finalizeOrder(
        items: items,
        details: details,
      );
      await _cart.clear();
      emit(
        CheckoutState(
          status: CheckoutStatus.success,
          orderId: orderId,
          profile: state.profile,
        ),
      );
    } catch (error) {
      emit(
        CheckoutState(
          status: CheckoutStatus.failure,
          message: error.toString(),
          profile: state.profile,
        ),
      );
    }
  }
}
