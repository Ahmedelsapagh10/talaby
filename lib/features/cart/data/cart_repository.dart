import 'cart_local_data_source.dart';
import 'models/cart_item.dart';

class CartRepository {
  CartRepository(this._localDataSource);

  final CartLocalDataSource _localDataSource;

  List<CartItem> load() => _localDataSource.read();
  Future<void> save(List<CartItem> items) => _localDataSource.write(items);
  Future<void> clear() => _localDataSource.clear();
}
