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
import 'package:new_strucuture/features/catalog/data/models/product.dart';
import 'package:new_strucuture/features/shop/presentation/shop_page.dart';
import 'package:new_strucuture/features/shop/presentation/widgets/shop_hero_banner.dart';
import 'package:new_strucuture/features/store/cubit/store_cubit.dart';
import 'package:new_strucuture/features/store/cubit/store_state.dart';
import 'package:new_strucuture/features/store/data/models/store_settings.dart';
import 'package:new_strucuture/features/wishlist/cubit/wishlist_cubit.dart';
import 'package:new_strucuture/features/wishlist/cubit/wishlist_state.dart';

void main() {
  testWidgets('shop displays products directly without category controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => const ShopPage())],
    );
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ProductsCubit>(create: (_) => _TestProductsCubit()),
          BlocProvider<CartCubit>(create: (_) => _TestCartCubit()),
          BlocProvider<WishlistCubit>(create: (_) => _TestWishlistCubit()),
          BlocProvider<StoreCubit>(create: (_) => _TestStoreCubit()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.text('Visible product'), findsOneWidget);
    expect(find.byType(ShopHeroBanner), findsOneWidget);
    expect(find.text('shop_banner_title'), findsOneWidget);
    expect(find.text('categories'), findsNothing);
    expect(find.text('new_arrivals'), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);
  });

  testWidgets('shop banner applies admin visibility and content', (
    tester,
  ) async {
    final storeCubit = _TestStoreCubit(
      const StoreSettings(bannerEnabled: false),
    );
    await tester.pumpWidget(
      BlocProvider<StoreCubit>.value(
        value: storeCubit,
        child: const MaterialApp(home: Scaffold(body: ShopHeroBanner())),
      ),
    );

    expect(find.byIcon(Icons.shopping_bag_outlined), findsNothing);

    storeCubit.update(
      const StoreSettings(bannerTitleEn: 'Admin controlled banner'),
    );
    await tester.pump();

    expect(find.text('Admin controlled banner'), findsOneWidget);
  });
}

class _TestStoreCubit extends Cubit<StoreState> implements StoreCubit {
  _TestStoreCubit([StoreSettings settings = const StoreSettings()])
    : super(StoreState(status: StoreStatus.success, settings: settings));

  void update(StoreSettings settings) {
    emit(StoreState(status: StoreStatus.success, settings: settings));
  }

  @override
  void watch() {}
}

class _TestProductsCubit extends Cubit<ProductsState> implements ProductsCubit {
  _TestProductsCubit()
    : super(
        const ProductsState(
          status: ProductsStatus.success,
          products: [
            Product(
              id: 'product-1',
              ownerId: 'owner-1',
              name: 'Visible product',
              images: ['https://example.com/product.jpg'],
              basePrice: 10000,
            ),
          ],
        ),
      );

  @override
  Future<void> load({CatalogQuery query = const CatalogQuery()}) async {}

  @override
  Future<void> loadMore() async {}
}

class _TestWishlistCubit extends Cubit<WishlistState> implements WishlistCubit {
  _TestWishlistCubit()
    : super(const WishlistState(status: WishlistStatus.success));

  @override
  Future<void> bind(String? userId) async {}

  @override
  Future<void> toggle(String productId) async {}
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
