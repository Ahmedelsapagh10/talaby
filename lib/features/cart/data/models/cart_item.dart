import 'package:hive/hive.dart';
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
  };
}

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 0;

  @override
  CartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItem(
      productId: fields[0] as String,
      productName: fields[1] as String,
      quantity: fields[2] as int,
      unitPrice: fields[3] as int,
      discountPerUnit: fields[4] as int,
      variantId: fields[5] as String?,
      colorId: fields[6] as String?,
      colorName: fields[7] as String?,
      sizeId: fields[8] as String?,
      imageUrl: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitPrice)
      ..writeByte(4)
      ..write(obj.discountPerUnit)
      ..writeByte(5)
      ..write(obj.variantId)
      ..writeByte(6)
      ..write(obj.colorId)
      ..writeByte(7)
      ..write(obj.colorName)
      ..writeByte(8)
      ..write(obj.sizeId)
      ..writeByte(9)
      ..write(obj.imageUrl);
  }
}
