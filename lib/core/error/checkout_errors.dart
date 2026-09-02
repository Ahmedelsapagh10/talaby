import 'package:easy_localization/easy_localization.dart';

String mapCheckoutError(Object error) {
  final message = error.toString();
  
  if (message.contains('A product is unavailable')) {
    return 'error_product_unavailable'.tr();
  }
  if (message.contains('A selected variant is unavailable')) {
    return 'error_variant_unavailable'.tr();
  }
  if (message.contains('Product stock is insufficient')) {
    return 'error_stock_insufficient'.tr();
  }
  if (message.contains('Store is not active')) {
    return 'error_store_inactive'.tr();
  }
  if (message.contains('Order items are invalid') || message.contains('Order item quantity is invalid')) {
    return 'error_invalid_items'.tr();
  }
  if (message.contains('Authentication is required')) {
    return 'error_auth_required'.tr();
  }

  // Fallback for StateError wrapping
  if (error is StateError) {
    return error.message;
  }

  return message;
}
