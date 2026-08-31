import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_strucuture/config/themes/theme_cubit.dart';
import 'package:new_strucuture/features/login/cubit/cubit.dart';
import 'package:new_strucuture/features/login/data/login_repo.dart';
import 'package:new_strucuture/features/main_screen/cubit/cubit.dart';
import 'package:new_strucuture/features/splash/cubit/cubit.dart';
import 'package:new_strucuture/features/forget_password/cubit/cubit.dart';
import 'package:new_strucuture/features/forget_password/data/forget_password_repo.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/app_config.dart';
import 'core/api/app_interceptors.dart';
import 'core/api/base_api_consumer.dart';
import 'core/api/dio_consumer.dart';
import 'core/services/image_upload_service.dart';
import 'core/services/imagekit_upload_service.dart';
import 'core/services/template_image_picker.dart';
import 'features/admin/cubit/admin_order_cubit.dart';
import 'features/admin/cubit/admin_categories_cubit.dart';
import 'features/admin/cubit/admin_customers_cubit.dart';
import 'features/admin/cubit/admin_products_cubit.dart';
import 'features/admin/cubit/admin_reviews_cubit.dart';
import 'features/admin/cubit/admin_settings_cubit.dart';
import 'features/admin/cubit/product_editor_cubit.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/cart/cubit/cart_cubit.dart';
import 'features/cart/data/cart_local_data_source.dart';
import 'features/cart/data/cart_repository.dart';
import 'features/cart/data/models/cart_item.dart';
import 'features/catalog/cubit/products_cubit.dart';
import 'features/catalog/cubit/product_details_cubit.dart';
import 'features/catalog/cubit/categories_cubit.dart';
import 'features/catalog/data/product_repository.dart';
import 'features/checkout/cubit/checkout_cubit.dart';
import 'features/customers/data/customer_repository.dart';
import 'features/main_screen/data/main_repo.dart';
import 'features/orders/cubit/order_tracking_cubit.dart';
import 'features/orders/cubit/customer_orders_cubit.dart';
import 'features/orders/data/order_admin_data_source.dart';
import 'features/orders/data/order_checkout_data_source.dart';
import 'features/orders/data/order_item_resolver.dart';
import 'features/orders/data/order_payment_data_source.dart';
import 'features/orders/data/order_repository.dart';
import 'features/reviews/data/review_repository.dart';
import 'features/reviews/cubit/reviews_cubit.dart';
import 'features/store/data/store_repository.dart';
import 'features/store/cubit/store_cubit.dart';
import 'features/uploads/data/image_upload_repository.dart';

final serviceLocator = GetIt.instance;
Future<void> setupCubit() async {
  serviceLocator.registerFactory(() => SplashCubit());

  serviceLocator.registerFactory(() => LoginCubit(serviceLocator()));
  serviceLocator.registerFactory(() => MainCubit(serviceLocator()));
  serviceLocator.registerFactory(() => ThemeCubit());
  serviceLocator.registerFactory(() => ForgetPasswordCubit(serviceLocator()));
  serviceLocator.registerLazySingleton(() => AuthCubit(serviceLocator()));
  serviceLocator.registerFactory(() => ProductsCubit(serviceLocator()));
  serviceLocator.registerFactory(() => CategoriesCubit(serviceLocator()));
  serviceLocator.registerFactory(() => ProductDetailsCubit(serviceLocator()));
  serviceLocator.registerFactory(() => StoreCubit(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => CartCubit(serviceLocator())..load(),
  );
  serviceLocator.registerFactory(
    () => CheckoutCubit(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerFactory(() => OrderTrackingCubit(serviceLocator()));
  serviceLocator.registerFactory(() => CustomerOrdersCubit(serviceLocator()));
  serviceLocator.registerFactory(() => ReviewsCubit(serviceLocator()));
  serviceLocator.registerFactory(() => AdminOrderCubit(serviceLocator()));
  serviceLocator.registerFactory(() => AdminCategoriesCubit(serviceLocator()));
  serviceLocator.registerFactory(() => AdminProductsCubit(serviceLocator()));
  serviceLocator.registerFactory(
    () => ProductEditorCubit(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerFactory(() => AdminReviewsCubit(serviceLocator()));
  serviceLocator.registerFactory(() => AdminCustomersCubit(serviceLocator()));
  serviceLocator.registerFactory(
    () => AdminSettingsCubit(serviceLocator(), serviceLocator()),
  );
}

Future<void> setupRepo() async {
  serviceLocator.registerLazySingleton(() => LoginRepo(serviceLocator()));
  serviceLocator.registerLazySingleton(() => MainRepo(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => ForgetPasswordRepo(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => AuthRepository(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => StoreRepository(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => ProductRepository(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => CartLocalDataSource(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => CartRepository(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => ImageUploadRepository(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerLazySingleton(OrderItemResolver.new);
  serviceLocator.registerLazySingleton(
    () => OrderCheckoutDataSource(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton(
    () => OrderPaymentDataSource(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => OrderAdminDataSource(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => OrderRepository(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton(
    () => ReviewRepository(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => CustomerRepository(serviceLocator()),
  );
}

Future<void> setupDependencyInjection() async {
  await serviceLocator.reset();
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);
  serviceLocator.registerLazySingleton<Box<CartItem>>(
    () => Hive.box<CartItem>('cart_${AppConfig.ownerId}'),
  );
  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton(() => FirebaseFirestore.instance);
  serviceLocator.registerLazySingleton<TemplateImagePicker>(
    GalleryTemplateImagePicker.new,
  );
  serviceLocator.registerLazySingleton<ImageUploadService>(
    ImageKitUploadService.new,
  );

  ///! (dio)
  serviceLocator.registerLazySingleton<BaseApiConsumer>(
    () => DioConsumer(client: serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => AppInterceptors());

  // Dio
  serviceLocator.registerLazySingleton(
    () => Dio(
      BaseOptions(
        contentType: "application/x-www-form-urlencoded",
        headers: {
          "Accept": "application/json",
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
    ),
  );
}
