enum DiscountType { none, percentage, fixed }

extension DiscountTypeCodec on DiscountType {
  String get value => name;

  static DiscountType fromValue(Object? value) {
    return DiscountType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => DiscountType.none,
    );
  }
}

class ProductDiscount {
  const ProductDiscount({this.type = DiscountType.none, this.value = 0})
    : assert(value >= 0);

  final DiscountType type;

  /// Fixed discounts use minor units. Percentage discounts use basis points.
  final int value;
}
