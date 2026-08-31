class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.sku,
    required this.stock,
    this.colorId,
    this.sizeId,
    this.active = true,
  });

  final String id;
  final String? colorId;
  final String? sizeId;
  final String sku;
  final int stock;
  final bool active;

  bool canFulfill(int quantity) => active && quantity > 0 && stock >= quantity;

  factory ProductVariant.fromMap(Map<String, dynamic> map) => ProductVariant(
    id: map['id']?.toString() ?? '',
    colorId: map['colorId']?.toString(),
    sizeId: map['sizeId']?.toString(),
    sku: map['sku']?.toString() ?? '',
    stock: (map['stock'] as num?)?.toInt() ?? 0,
    active: map['active'] as bool? ?? true,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'colorId': colorId,
    'sizeId': sizeId,
    'sku': sku,
    'stock': stock,
    'active': active,
  };
}
