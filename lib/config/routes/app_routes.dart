import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/cubit/auth_cubit.dart';
import '../../features/auth/cubit/auth_state.dart';
import '../../features/cart/presentation/cart_page.dart';
import '../../features/catalog/cubit/products_cubit.dart';
import '../../features/catalog/cubit/product_details_cubit.dart';
import '../../features/checkout/cubit/checkout_cubit.dart';
import '../../features/checkout/presentation/checkout_page.dart';
import '../../features/forget_password/screens/forgot_password_email_screen.dart';
import '../../features/forget_password/screens/forgot_password_otp_screen.dart';
import '../../features/forget_password/screens/forgot_password_reset_screen.dart';
import '../../features/forget_password/data/model/forget_password_model.dart';
import '../../features/login/screens/login_screen.dart';
import '../../features/on_boarding/screen/onboarding_screen.dart';
import '../../features/order_tracking/presentation/order_tracking_page.dart';
import '../../features/orders/cubit/order_tracking_cubit.dart';
import '../../features/orders/cubit/customer_orders_cubit.dart';
import '../../features/orders/presentation/customer_orders_page.dart';
import '../../features/product_details/presentation/product_details_page.dart';
import '../../features/profile/cubit/profile_cubit.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/reviews/cubit/reviews_cubit.dart';
import '../../features/shop/presentation/shop_page.dart';
import '../../features/shop/presentation/search_page.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/wishlist/presentation/wishlist_page.dart';
import '../../injector.dart';
import 'admin_routes.dart';
import 'route_placeholder_page.dart';

class Routes {
  const Routes._();

  static const initialRoute = '/';
  static const productsRoute = '/products';
  static const productRoute = '/product/:id';
  static const cartRoute = '/cart';
  static const checkoutRoute = '/checkout';
  static const orderRoute = '/orders/:id';
  static const accountRoute = '/account';
  static const profileRoute = '/profile';
  static const wishlistRoute = '/wishlist';
  static const searchRoute = '/search';
  static const loginRoute = '/login';
  static const adminLoginRoute = '/admin/login';
  static const splashRoute = '/splash';
  static const onboardingPageScreenRoute = '/onboarding';
  static const mainRoute = productsRoute;
  static const forgotPasswordEmailRoute = '/forgot-password/email';
  static const forgotPasswordOtpRoute = '/forgot-password/otp';
  static const forgotPasswordResetRoute = '/forgot-password/reset';
}

class AppRoutes {
  const AppRoutes._();

  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: Routes.initialRoute,
      refreshListenable: CubitRouterRefresh(authCubit),
      redirect: (context, state) => resolveRedirect(authCubit.state, state.uri),
      routes: [
        GoRoute(
          path: Routes.splashRoute,
          builder: (_, _) => const SplashScreen(),
        ),
        GoRoute(
          path: Routes.onboardingPageScreenRoute,
          builder: (_, _) => const OnBoardingScreen(),
        ),
        GoRoute(
          path: Routes.loginRoute,
          builder: (_, _) => const LoginScreen(),
        ),
        GoRoute(
          path: Routes.adminLoginRoute,
          builder: (_, _) => const LoginScreen(adminOnly: true),
        ),
        GoRoute(
          path: Routes.forgotPasswordEmailRoute,
          builder: (_, _) => const ForgotPasswordEmailScreen(),
        ),
        GoRoute(
          path: Routes.forgotPasswordOtpRoute,
          builder: (_, state) =>
              ForgotPasswordOtpScreen(email: state.extra?.toString() ?? ''),
        ),
        GoRoute(
          path: Routes.forgotPasswordResetRoute,
          builder: (_, state) => ForgotPasswordResetScreen(
            args: state.extra is ForgotPasswordResetArgs
                ? state.extra! as ForgotPasswordResetArgs
                : const ForgotPasswordResetArgs(email: '', code: ''),
          ),
        ),
        GoRoute(
          path: Routes.initialRoute,
          builder: (_, _) => BlocProvider(
            create: (_) => serviceLocator<ProductsCubit>()..load(),
            child: const ShopPage(),
          ),
        ),
        GoRoute(
          path: Routes.productsRoute,
          builder: (_, _) => BlocProvider(
            create: (_) => serviceLocator<ProductsCubit>()..load(),
            child: const ShopPage(),
          ),
        ),
        GoRoute(
          path: Routes.productRoute,
          builder: (_, state) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) =>
                    serviceLocator<ProductDetailsCubit>()
                      ..watch(state.pathParameters['id']!),
              ),
              BlocProvider(
                create: (_) =>
                    serviceLocator<ReviewsCubit>()
                      ..load(state.pathParameters['id']!),
              ),
            ],
            child: const ProductDetailsPage(),
          ),
        ),
        GoRoute(
          path: Routes.searchRoute,
          builder: (_, state) => BlocProvider(
            create: (_) => serviceLocator<ProductsCubit>(),
            child: SearchPage(
              initialQuery: state.uri.queryParameters['q'] ?? '',
            ),
          ),
        ),
        GoRoute(
          path: Routes.wishlistRoute,
          builder: (_, _) => const WishlistPage(),
        ),
        GoRoute(
          path: Routes.profileRoute,
          builder: (_, _) => BlocProvider(
            create: (_) =>
                serviceLocator<ProfileCubit>()
                  ..load(authCubit.state.session!.uid),
            child: const ProfilePage(),
          ),
        ),
        GoRoute(path: Routes.cartRoute, builder: (_, _) => const CartPage()),
        GoRoute(
          path: Routes.checkoutRoute,
          builder: (_, _) => BlocProvider(
            create: (_) =>
                serviceLocator<CheckoutCubit>()
                  ..loadProfile(authCubit.state.session!.uid),
            child: const CheckoutPage(),
          ),
        ),
        GoRoute(
          path: Routes.orderRoute,
          builder: (_, state) => BlocProvider(
            create: (_) =>
                serviceLocator<OrderTrackingCubit>()
                  ..watch(state.pathParameters['id']!),
            child: const OrderTrackingPage(),
          ),
        ),
        GoRoute(
          path: Routes.accountRoute,
          builder: (_, _) => BlocProvider(
            create: (_) =>
                serviceLocator<CustomerOrdersCubit>()
                  ..load(authCubit.state.session!.uid),
            child: const CustomerOrdersPage(),
          ),
        ),
        ...buildAdminRoutes(),
      ],
      errorBuilder: (_, state) => RoutePlaceholderPage(
        title: 'page_not_found'.tr(),
        message: state.error?.toString(),
      ),
    );
  }

  @visibleForTesting
  static String? resolveRedirect(AuthState auth, Uri uri) {
    if (auth.status == AuthStatus.initial ||
        auth.status == AuthStatus.loading) {
      return null;
    }
    final path = uri.path;
    final isAdminLogin = path == Routes.adminLoginRoute;
    final isAdminPath = path == '/admin' || path.startsWith('/admin/');
    final requiresCustomerAuth =
        path == Routes.checkoutRoute ||
        path == Routes.accountRoute ||
        path == Routes.profileRoute ||
        path == Routes.wishlistRoute ||
        path.startsWith('/orders/');
    if (isAdminLogin) {
      if (!auth.isAuthenticated || !auth.isAdmin) return null;
      final requested = uri.queryParameters['redirect'];
      return requested != null &&
              requested != Routes.adminLoginRoute &&
              (requested == '/admin' || requested.startsWith('/admin/'))
          ? requested
          : '/admin';
    }
    if (isAdminPath && !auth.isAuthenticated) {
      return '${Routes.adminLoginRoute}?redirect=${Uri.encodeComponent(uri.toString())}';
    }
    if (requiresCustomerAuth && !auth.isAuthenticated) {
      return '${Routes.loginRoute}?redirect=${Uri.encodeComponent(uri.toString())}';
    }
    if (isAdminPath && !auth.isAdmin) return Routes.initialRoute;
    if (path == Routes.loginRoute && auth.isAuthenticated) {
      final requested = uri.queryParameters['redirect'];
      if (auth.isAdmin) {
        return requested?.startsWith('/admin') == true ? requested : '/admin';
      }
      return requested?.startsWith('/admin') == true
          ? Routes.initialRoute
          : requested ?? Routes.initialRoute;
    }
    return null;
  }
}

class CubitRouterRefresh extends ChangeNotifier {
  CubitRouterRefresh(AuthCubit cubit) {
    _subscription = cubit.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
