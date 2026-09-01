import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:new_strucuture/features/cart/cubit/cart_cubit.dart';
import 'package:new_strucuture/features/cart/cubit/cart_state.dart';
import 'package:new_strucuture/features/cart/data/models/cart_item.dart';
import 'package:new_strucuture/features/catalog/cubit/products_cubit.dart';
import 'package:new_strucuture/features/catalog/cubit/products_state.dart';
import 'package:new_strucuture/features/catalog/data/models/catalog_query.dart';
import 'package:new_strucuture/features/shop/presentation/search_page.dart';

void main() {
  testWidgets('search waits for two characters and debounces requests', (
    tester,
  ) async {
    final products = _TestProductsCubit();
    final router = GoRouter(
      initialLocation: '/search',
      routes: [GoRoute(path: '/search', builder: (_, _) => const SearchPage())],
    );
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<CartCubit>(create: (_) => _TestCartCubit()),
          BlocProvider<ProductsCubit>.value(value: products),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    final input = find.descendant(
      of: find.byType(SearchBar),
      matching: find.byType(EditableText),
    );
    await tester.enterText(input, 'r');
    await tester.pump(const Duration(milliseconds: 400));
    expect(products.lastQuery, isNull);

    await tester.enterText(input, 'red');
    await tester.pump(const Duration(milliseconds: 349));
    expect(products.lastQuery, isNull);
    await tester.pump(const Duration(milliseconds: 1));
    expect(products.lastQuery?.searchQuery, 'red');
  });
}

class _TestProductsCubit extends Cubit<ProductsState> implements ProductsCubit {
  _TestProductsCubit() : super(const ProductsState());

  CatalogQuery? lastQuery;

  @override
  Future<void> load({CatalogQuery query = const CatalogQuery()}) async {
    lastQuery = query;
    emit(const ProductsState(status: ProductsStatus.empty));
  }

  @override
  Future<void> loadMore() async {}
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
