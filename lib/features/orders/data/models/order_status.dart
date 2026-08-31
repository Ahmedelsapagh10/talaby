enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
  returned,
}

extension OrderStatusCodec on OrderStatus {
  String get value => name;

  static OrderStatus fromValue(Object? value) {
    return OrderStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}
