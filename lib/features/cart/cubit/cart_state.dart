import 'package:equatable/equatable.dart';

import '../../../core/utils/money_calculator.dart';
import '../data/models/cart_item.dart';

class CartState extends Equatable {
  const CartState({this.items = const [], this.message});

  final List<CartItem> items;
  final String? message;

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get subtotal => MoneyCalculator.calculate(
    lineTotals: items.map((item) => item.lineTotal),
  ).subtotal;

  @override
  List<Object?> get props => [items, message];
}
