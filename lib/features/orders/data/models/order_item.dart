class OrderItem {
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.discountAmount,
    required this.lineTotal,
    this.variantId,
    this.sku,
    this.imageUrl,
    this.colorId,
    this.colorName,
    this.sizeId,
  });

  final String productId;
  final String productName;
  final String? variantId;
  final String? sku;
  final String? imageUrl;
  final String? colorId;
  final String? colorName;
  final String? sizeId;
  final int quantity;
  final int unitPrice;
  final int discountAmount;
  final int lineTotal;

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
    productId: map['productId']?.toString() ?? '',
    productName: map['productName']?.toString() ?? '',
    variantId: map['variantId']?.toString(),
    sku: map['sku']?.toString(),
    imageUrl: map['imageUrl']?.toString(),
    colorId: map['colorId']?.toString(),
    colorName: map['colorName']?.toString(),
    sizeId: map['sizeId']?.toString(),
    quantity: (map['quantity'] as num?)?.toInt() ?? 0,
    unitPrice: (map['unitPrice'] as num?)?.toInt() ?? 0,
    discountAmount: (map['discountAmount'] as num?)?.toInt() ?? 0,
    lineTotal: (map['lineTotal'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'variantId': variantId,
    'sku': sku,
    'imageUrl': imageUrl,
    'colorId': colorId,
    'colorName': colorName,
    'sizeId': sizeId,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'discountAmount': discountAmount,
    'lineTotal': lineTotal,
  };
}
