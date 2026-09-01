import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:new_strucuture/features/cart/cubit/cart_cubit.dart';
import 'package:new_strucuture/features/cart/cubit/cart_state.dart';
import 'package:new_strucuture/features/cart/data/models/cart_item.dart';
import 'package:new_strucuture/features/shop/presentation/store_header.dart';

void main() {
  testWidgets('store name uses the Major Mono Display font', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(appBar: StoreHeader()),
        ),
      ],
    );
    await tester.pumpWidget(
      BlocProvider<CartCubit>(
        create: (_) => _TestCartCubit(),
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    final title = tester.widget<Text>(find.text('TALABY'));
    expect(title.style?.fontFamily, 'MajorMonoDisplay');
    expect(find.byIcon(Icons.language), findsNothing);
  });
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
