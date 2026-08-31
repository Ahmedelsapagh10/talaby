import 'package:hive/hive.dart';
import 'models/cart_item.dart';

class CartLocalDataSource {
  CartLocalDataSource(this._box);

  final Box<CartItem> _box;

  List<CartItem> read() {
    return _box.values.toList();
  }

  Future<void> write(List<CartItem> items) async {
    await _box.clear();
    await _box.addAll(items);
  }

  Future<void> clear() => _box.clear();
}
