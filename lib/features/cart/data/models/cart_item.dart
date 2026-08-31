import '../../../../core/utils/money_calculator.dart';

class CartItem {
  const CartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.discountPerUnit,
    this.variantId,
    this.colorId,
    this.colorName,
    this.sizeId,
    this.imageUrl,
  });

  final String productId;
  final String productName;
  final String? variantId;
  final String? colorId;
  final String? colorName;
  final String? sizeId;
  final String? imageUrl;
  final int quantity;
  final int unitPrice;
  final int discountPerUnit;

  String get key =>
      '$productId:${variantId ?? ''}:${colorId ?? ''}:${sizeId ?? ''}';
  int get finalUnitPrice => unitPrice - discountPerUnit;
  int get lineTotal =>
      MoneyCalculator.lineTotal(unitPrice: finalUnitPrice, quantity: quantity);

  CartItem copyWith({int? quantity}) => CartItem(
    productId: productId,
    productName: productName,
    variantId: variantId,
    colorId: colorId,
    colorName: colorName,
    sizeId: sizeId,
    imageUrl: imageUrl,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice,
    discountPerUnit: discountPerUnit,
  );

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
    productId: map['productId']?.toString() ?? '',
    productName: map['productName']?.toString() ?? '',
    variantId: map['variantId']?.toString(),
    colorId: map['colorId']?.toString(),
    colorName: map['colorName']?.toString(),
    sizeId: map['sizeId']?.toString(),
    imageUrl: map['imageUrl']?.toString(),
    quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    unitPrice: (map['unitPrice'] as num?)?.toInt() ?? 0,
    discountPerUnit: (map['discountPerUnit'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'variantId': variantId,
    'colorId': colorId,
    'colorName': colorName,
    'sizeId': sizeId,
    'imageUrl': imageUrl,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'discountPerUnit': discountPerUnit,
  };
}
