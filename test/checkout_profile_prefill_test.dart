import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:new_strucuture/features/cart/cubit/cart_cubit.dart';
import 'package:new_strucuture/features/cart/cubit/cart_state.dart';
import 'package:new_strucuture/features/cart/data/models/cart_item.dart';
import 'package:new_strucuture/features/checkout/cubit/checkout_cubit.dart';
import 'package:new_strucuture/features/checkout/cubit/checkout_state.dart';
import 'package:new_strucuture/features/checkout/data/models/checkout_details.dart';
import 'package:new_strucuture/features/checkout/presentation/checkout_page.dart';
import 'package:new_strucuture/features/profile/data/models/customer_profile.dart';

void main() {
  testWidgets('checkout prefills saved delivery profile', (tester) async {
    const profile = CustomerProfile(
      userId: 'customer-1',
      name: 'Ahmed Ali',
      email: 'ahmed@example.com',
      phone: '01012345678',
      defaultCity: 'Cairo',
      defaultAddress: 'Nasr City',
    );
    final checkout = _TestCheckoutCubit(const CheckoutState(profile: profile));
    final router = GoRouter(
      initialLocation: '/checkout',
      routes: [
        GoRoute(path: '/checkout', builder: (_, _) => const CheckoutPage()),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<CartCubit>(create: (_) => _TestCartCubit()),
          BlocProvider<CheckoutCubit>.value(value: checkout),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.text('Ahmed Ali'), findsOneWidget);
    expect(find.text('01012345678'), findsOneWidget);
    expect(find.text('Cairo'), findsOneWidget);
    expect(find.text('Nasr City'), findsOneWidget);
  });
}

class _TestCheckoutCubit extends Cubit<CheckoutState> implements CheckoutCubit {
  _TestCheckoutCubit(super.initialState);

  @override
  Future<void> loadProfile(String userId) async {}

  @override
  Future<void> submit(CheckoutDetails details) async {}
}

class _TestCartCubit extends Cubit<CartState> implements CartCubit {
  _TestCartCubit() : super(const CartState());

  @override
  void load() {}

  @override
  Future<void> add(CartItem item) async {}

  @override
  Future<void> updateQuantity(String key, int quantity) async {}

  @override
  Future<void> remove(String key) async {}

  @override
  Future<void> clear() async {}
}
