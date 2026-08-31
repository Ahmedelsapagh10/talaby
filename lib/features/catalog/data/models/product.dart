import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/money_calculator.dart';
import 'discount.dart';
import 'product_color.dart';
import 'product_variant.dart';

class Product {
  const Product({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.basePrice,
    this.shortDescription = '',
    this.description = '',
    this.images = const [],
    this.categoryId,
    this.oldPrice,
    this.discount = const ProductDiscount(),
    this.colors = const [],
    this.sizes = const [],
    this.variants = const [],
    this.stock = 0,
    this.sku = '',
    this.active = true,
    this.featured = false,
    this.stockControlEnabled = true,
    this.averageRating = 0,
    this.reviewsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  final String name;
  final String shortDescription;
  final String description;
  final List<String> images;
  final String? categoryId;
  final int basePrice;
  final int? oldPrice;
  final ProductDiscount discount;
  final List<ProductColor> colors;
  final List<String> sizes;
  final List<ProductVariant> variants;
  final int stock;
  final String sku;
  final bool active;
  final bool featured;
  final bool stockControlEnabled;
  final double averageRating;
  final int reviewsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int get finalPrice => switch (discount.type) {
    DiscountType.none => basePrice,
    DiscountType.percentage =>
      basePrice - MoneyCalculator.percentageDiscount(basePrice, discount.value),
    DiscountType.fixed =>
      basePrice - MoneyCalculator.fixedDiscount(basePrice, discount.value),
  };

  ProductVariant? variantById(String? id) {
    if (id == null) return null;
    for (final variant in variants) {
      if (variant.id == id) return variant;
    }
    return null;
  }

  factory Product.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Product.fromMap(doc.id, doc.data() ?? const {});
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) => Product(
    id: id,
    ownerId: map['ownerId']?.toString() ?? '',
    name: map['name']?.toString() ?? '',
    shortDescription: map['shortDescription']?.toString() ?? '',
    description: map['description']?.toString() ?? '',
    images: List<String>.from(map['images'] as List? ?? const []),
    categoryId: map['categoryId']?.toString(),
    basePrice: (map['basePrice'] as num?)?.toInt() ?? 0,
    oldPrice: (map['oldPrice'] as num?)?.toInt(),
    discount: ProductDiscount(
      type: DiscountTypeCodec.fromValue(map['discountType']),
      value: (map['discountValue'] as num?)?.toInt() ?? 0,
    ),
    colors: (map['colors'] as List? ?? const [])
        .whereType<Map>()
        .map((value) => ProductColor.fromMap(Map<String, dynamic>.from(value)))
        .toList(),
    sizes: List<String>.from(map['sizes'] as List? ?? const []),
    variants: (map['variants'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (value) => ProductVariant.fromMap(Map<String, dynamic>.from(value)),
        )
        .toList(),
    stock: (map['stock'] as num?)?.toInt() ?? 0,
    sku: map['sku']?.toString() ?? '',
    active: map['active'] as bool? ?? true,
    featured: map['featured'] as bool? ?? false,
    stockControlEnabled: map['stockControlEnabled'] as bool? ?? true,
    averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0,
    reviewsCount: (map['reviewsCount'] as num?)?.toInt() ?? 0,
    createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
  );

  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'name': name,
    'shortDescription': shortDescription,
    'description': description,
    'images': images,
    'categoryId': categoryId,
    'basePrice': basePrice,
    'oldPrice': oldPrice,
    'discountType': discount.type.value,
    'discountValue': discount.value,
    'colors': colors.map((value) => value.toMap()).toList(),
    'sizes': sizes,
    'variants': variants.map((value) => value.toMap()).toList(),
    'stock': stock,
    'sku': sku,
    'active': active,
    'featured': featured,
    'stockControlEnabled': stockControlEnabled,
    'averageRating': averageRating,
    'reviewsCount': reviewsCount,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
