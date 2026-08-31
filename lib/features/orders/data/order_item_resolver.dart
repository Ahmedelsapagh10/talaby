import '../../cart/data/models/cart_item.dart';

class ResolvedOrderItem {
  const ResolvedOrderItem({required this.item, this.stockUpdate});

  final Map<String, dynamic> item;
  final Map<String, dynamic>? stockUpdate;
}

class OrderItemResolver {
  const OrderItemResolver();

  ResolvedOrderItem resolve(CartItem requested, Map<String, dynamic> product) {
    if (product['active'] != true) {
      throw StateError('A product is unavailable.');
    }
    if (requested.quantity <= 0 || requested.quantity > 99) {
      throw StateError('Order item quantity is invalid.');
    }
    final basePrice = (product['basePrice'] as num?)?.toInt() ?? 0;
    if (basePrice <= 0 || basePrice > 1000000000000) {
      throw StateError('Product price is invalid.');
    }

    final discount = _discount(product, basePrice);
    final controlsStock = product['stockControlEnabled'] != false;
    final variants = (product['variants'] as List? ?? const [])
        .whereType<Map>()
        .map((value) => Map<String, dynamic>.from(value))
        .toList();
    final variantIndex = requested.variantId == null
        ? -1
        : variants.indexWhere(
            (variant) => variant['id']?.toString() == requested.variantId,
          );

    Map<String, dynamic>? stockUpdate;
    Map<String, dynamic>? variant;
    if (variantIndex >= 0) {
      variant = variants[variantIndex];
      final stock = (variant['stock'] as num?)?.toInt() ?? 0;
      if (variant['active'] != true ||
          (controlsStock && stock < requested.quantity)) {
        throw StateError('A selected variant is unavailable.');
      }
      if (controlsStock) {
        variants[variantIndex] = {
          ...variant,
          'stock': stock - requested.quantity,
        };
        product['variants'] = variants;
        stockUpdate = {'variants': variants};
      }
    } else {
      if (requested.variantId != null) {
        throw StateError('Product stock is insufficient.');
      }
      final stock = (product['stock'] as num?)?.toInt() ?? 0;
      if (controlsStock && stock < requested.quantity) {
        throw StateError('Product stock is insufficient.');
      }
      if (controlsStock) {
        product['stock'] = stock - requested.quantity;
        stockUpdate = {'stock': product['stock']};
      }
    }

    return ResolvedOrderItem(
      stockUpdate: stockUpdate,
      item: {
        'productId': requested.productId,
        'productName': product['name']?.toString() ?? requested.productName,
        'variantId': requested.variantId,
        'sku': variant?['sku']?.toString() ?? product['sku']?.toString(),
        'imageUrl': _firstImage(product['images']),
        'colorId': requested.colorId,
        'colorName': _colorName(product['colors'], requested.colorId),
        'sizeId': requested.sizeId,
        'quantity': requested.quantity,
        'unitPrice': basePrice,
        'discountAmount': discount * requested.quantity,
        'lineTotal': (basePrice - discount) * requested.quantity,
      },
    );
  }

  int _discount(Map<String, dynamic> product, int price) {
    final rawValue = (product['discountValue'] as num?)?.toInt() ?? 0;
    final value = rawValue < 0 ? 0 : rawValue;
    return switch (product['discountType']) {
      'percentage' => ((price * value.clamp(0, 10000)) ~/ 10000),
      'fixed' => value.clamp(0, price),
      _ => 0,
    };
  }

  String? _firstImage(Object? value) {
    final images = value as List?;
    return images == null || images.isEmpty ? null : images.first?.toString();
  }

  String? _colorName(Object? value, String? colorId) {
    if (colorId == null || value is! List) return null;
    for (final color in value.whereType<Map>()) {
      if (color['id']?.toString() == colorId) return color['name']?.toString();
    }
    return null;
  }
}
