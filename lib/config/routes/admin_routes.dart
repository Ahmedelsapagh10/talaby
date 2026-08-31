import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/cubit/admin_order_cubit.dart';
import '../../features/admin/cubit/admin_categories_cubit.dart';
import '../../features/admin/cubit/admin_customers_cubit.dart';
import '../../features/admin/cubit/admin_products_cubit.dart';
import '../../features/admin/cubit/admin_reviews_cubit.dart';
import '../../features/admin/cubit/admin_settings_cubit.dart';
import '../../features/admin/cubit/product_editor_cubit.dart';
import '../../features/admin/presentation/admin_overview_page.dart';
import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/presentation/order_details_page.dart';
import '../../features/admin/presentation/orders_list_page.dart';
import '../../features/orders/cubit/order_tracking_cubit.dart';
import '../../injector.dart';
import 'route_placeholder_page.dart';

List<RouteBase> buildAdminRoutes() => [
  GoRoute(
    path: '/admin',
    builder: (_, _) => const AdminShell(child: AdminOverviewPage()),
  ),
  GoRoute(
    path: '/admin/orders',
    builder: (_, _) => BlocProvider(
      create: (_) => serviceLocator<AdminOrderCubit>()..load(),
      child: const AdminShell(selectedIndex: 1, child: OrdersListPage()),
    ),
  ),
  GoRoute(
    path: '/admin/orders/:id',
    builder: (_, state) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AdminOrderCubit>()),
        BlocProvider(
          create: (_) =>
              serviceLocator<OrderTrackingCubit>()
                ..watch(state.pathParameters['id']!),
        ),
      ],
      child: const AdminShell(selectedIndex: 1, child: OrderDetailsPage()),
    ),
  ),
  GoRoute(
    path: '/admin/products',
    builder: (_, _) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<AdminProductsCubit>()..load(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<AdminCategoriesCubit>()..load(),
        ),
      ],
      child: const AdminShell(
        selectedIndex: 2,
        child: RoutePlaceholderPage(title: 'Products'),
      ),
    ),
  ),
  GoRoute(
    path: '/admin/products/new',
    builder: (_, _) => BlocProvider(
      create: (_) => serviceLocator<ProductEditorCubit>()..load(),
      child: const AdminShell(
        selectedIndex: 2,
        child: RoutePlaceholderPage(title: 'New product'),
      ),
    ),
  ),
  GoRoute(
    path: '/admin/products/:id/edit',
    builder: (_, state) => BlocProvider(
      create: (_) =>
          serviceLocator<ProductEditorCubit>()
            ..load(productId: state.pathParameters['id']!),
      child: const AdminShell(
        selectedIndex: 2,
        child: RoutePlaceholderPage(title: 'Edit product'),
      ),
    ),
  ),
  GoRoute(
    path: '/admin/customers',
    builder: (_, _) => BlocProvider(
      create: (_) => serviceLocator<AdminCustomersCubit>()..load(),
      child: const AdminShell(
        selectedIndex: 3,
        child: RoutePlaceholderPage(title: 'Customers'),
      ),
    ),
  ),
  GoRoute(
    path: '/admin/reviews',
    builder: (_, _) => BlocProvider(
      create: (_) => serviceLocator<AdminReviewsCubit>()..load(),
      child: const AdminShell(
        selectedIndex: 4,
        child: RoutePlaceholderPage(title: 'Reviews'),
      ),
    ),
  ),
  GoRoute(
    path: '/admin/settings',
    builder: (_, _) => BlocProvider(
      create: (_) => serviceLocator<AdminSettingsCubit>()..load(),
      child: const AdminShell(
        selectedIndex: 5,
        child: RoutePlaceholderPage(title: 'Settings'),
      ),
    ),
  ),
];
