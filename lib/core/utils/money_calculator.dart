class MoneyBreakdown {
  const MoneyBreakdown({
    required this.subtotal,
    required this.discount,
    required this.deliveryFee,
    required this.total,
    required this.paid,
    required this.remaining,
  });

  final int subtotal;
  final int discount;
  final int? deliveryFee;
  final int total;
  final int paid;
  final int remaining;
}

class MoneyCalculator {
  const MoneyCalculator._();

  static int percentageDiscount(int amount, int percentageBasisPoints) {
    _requireNonNegative(amount, 'amount');
    if (percentageBasisPoints < 0 || percentageBasisPoints > 10000) {
      throw ArgumentError.value(
        percentageBasisPoints,
        'percentageBasisPoints',
        'Must be between 0 and 10000.',
      );
    }
    return (amount * percentageBasisPoints) ~/ 10000;
  }

  static int fixedDiscount(int amount, int discount) {
    _requireNonNegative(amount, 'amount');
    _requireNonNegative(discount, 'discount');
    return discount > amount ? amount : discount;
  }

  static int lineTotal({required int unitPrice, required int quantity}) {
    _requireNonNegative(unitPrice, 'unitPrice');
    if (quantity <= 0) {
      throw ArgumentError.value(quantity, 'quantity', 'Must be positive.');
    }
    return unitPrice * quantity;
  }

  static MoneyBreakdown calculate({
    required Iterable<int> lineTotals,
    int discount = 0,
    int? deliveryFee,
    int paid = 0,
  }) {
    final subtotal = lineTotals.fold<int>(0, (sum, value) {
      _requireNonNegative(value, 'lineTotal');
      return sum + value;
    });
    final safeDiscount = fixedDiscount(subtotal, discount);
    if (deliveryFee != null) _requireNonNegative(deliveryFee, 'deliveryFee');
    _requireNonNegative(paid, 'paid');
    final total = subtotal - safeDiscount + (deliveryFee ?? 0);
    final remaining = total > paid ? total - paid : 0;
    return MoneyBreakdown(
      subtotal: subtotal,
      discount: safeDiscount,
      deliveryFee: deliveryFee,
      total: total,
      paid: paid,
      remaining: remaining,
    );
  }

  static void _requireNonNegative(int value, String name) {
    if (value < 0) {
      throw ArgumentError.value(value, name, 'Must not be negative.');
    }
  }
}
