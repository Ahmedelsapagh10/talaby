import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:new_strucuture/features/main_screen/cubit/cubit.dart';
import 'package:new_strucuture/features/forget_password/cubit/cubit.dart';
import 'package:go_router/go_router.dart';
import 'config/routes/app_routes.dart';
import 'config/themes/app_theme.dart';
import 'config/themes/theme_cubit.dart';
import 'core/utils/app_strings.dart';
import 'core/config/app_flavor.dart';
import 'package:new_strucuture/injector.dart' as injector;
import 'features/login/cubit/cubit.dart';
import 'features/splash/cubit/cubit.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/cart/cubit/cart_cubit.dart';
import 'features/store/cubit/store_cubit.dart';
import 'features/store/cubit/store_state.dart';
import 'features/store/presentation/store_brand_theme.dart';
import 'features/wishlist/cubit/wishlist_cubit.dart';

class MyApp extends StatefulWidget {
  final AppFlavor flavor;
  const MyApp({super.key, required this.flavor});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthCubit _authCubit;
  late final CartCubit _cartCubit;
  late final WishlistCubit _wishlistCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = injector.serviceLocator<AuthCubit>();
    _cartCubit = injector.serviceLocator<CartCubit>();
    _wishlistCubit = injector.serviceLocator<WishlistCubit>();
    _wishlistCubit.bind(_authCubit.state.session?.uid);
    _router = AppRoutes.createRouter(_authCubit, widget.flavor);
  }

  @override
  void dispose() {
    _router.dispose();
    _wishlistCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => injector.serviceLocator<SplashCubit>()),
        BlocProvider(create: (_) => injector.serviceLocator<LoginCubit>()),
        BlocProvider(create: (_) => injector.serviceLocator<MainCubit>()),
        BlocProvider(create: (_) => injector.serviceLocator<ThemeCubit>()),
        BlocProvider(
          create: (_) => injector.serviceLocator<ForgetPasswordCubit>(),
        ),
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _cartCubit),
        BlocProvider.value(value: _wishlistCubit),
        BlocProvider(
          create: (_) => injector.serviceLocator<StoreCubit>()..watch(),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (_, state) => _wishlistCubit.bind(state.session?.uid),
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return BlocBuilder<StoreCubit, StoreState>(
              buildWhen: (previous, current) =>
                  previous.owner?.primaryColor != current.owner?.primaryColor ||
                  previous.owner?.secondaryColor !=
                      current.owner?.secondaryColor,
              builder: (context, storeState) => MaterialApp.router(
                supportedLocales: const [Locale('ar')],
                locale: const Locale('ar'),
                theme: applyStoreBrandColors(
                  AppTheme.lightThemeFor(context.locale),
                  storeState.owner,
                ),
                darkTheme: applyStoreBrandColors(
                  AppTheme.darkThemeFor(context.locale),
                  storeState.owner,
                ),
                themeMode: themeMode,
                localizationsDelegates: context.localizationDelegates,
                debugShowCheckedModeBanner: false,
                title: AppStrings.appName,
                routerConfig: _router,
              ),
            );
          },
        ),
      ),
    );
  }
}
