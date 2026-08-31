import '../config/app_config.dart';

class FirestorePaths {
  const FirestorePaths._();

  static String get owner => 'owners/${AppConfig.ownerId}';
  static String get products => '$owner/products';
  static String get categories => '$owner/categories';
  static String get orders => '$owner/orders';
  static String get customers => '$owner/customers';
  static String get reviews => '$owner/reviews';
  static String get members => '$owner/members';
  static String get settings => '$owner/settings';
  static String get orderCounter => '$owner/counters/orders';
  static String get generalSettings => '$settings/general';
  static String user(String uid) => 'users/$uid';
  static String member(String uid) => '$members/$uid';
  static String product(String id) => '$products/$id';
  static String order(String id) => '$orders/$id';
  static String customer(String id) => '$customers/$id';
  static String review(String id) => '$reviews/$id';
}
