import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/cart_repository.dart';
import '../data/models/cart_item.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._repository) : super(const CartState());

  final CartRepository _repository;

  void load() => emit(CartState(items: _repository.load()));

  Future<void> add(CartItem item) async {
    final items = [...state.items];
    final index = items.indexWhere((existing) => existing.key == item.key);
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + item.quantity,
      );
    }
    await _emitAndPersist(items);
  }

  Future<void> updateQuantity(String key, int quantity) async {
    if (quantity <= 0) return remove(key);
    final items = state.items
        .map(
          (item) => item.key == key ? item.copyWith(quantity: quantity) : item,
        )
        .toList();
    await _emitAndPersist(items);
  }

  Future<void> remove(String key) async {
    await _emitAndPersist(
      state.items.where((item) => item.key != key).toList(),
    );
  }

  Future<void> clear() async {
    await _repository.clear();
    emit(const CartState());
  }

  Future<void> _emitAndPersist(List<CartItem> items) async {
    await _repository.save(items);
    emit(CartState(items: items));
  }
}
