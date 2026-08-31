import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import 'models/cart_item.dart';

class CartLocalDataSource {
  CartLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  String get _key => 'cart_${AppConfig.ownerId}';

  List<CartItem> read() {
    final json = _preferences.getString(_key);
    if (json == null || json.isEmpty) return const [];
    final values = jsonDecode(json) as List;
    return values
        .whereType<Map>()
        .map((value) => CartItem.fromMap(Map<String, dynamic>.from(value)))
        .toList();
  }

  Future<void> write(List<CartItem> items) {
    return _preferences.setString(
      _key,
      jsonEncode(items.map((item) => item.toMap()).toList()),
    );
  }

  Future<void> clear() => _preferences.remove(_key);
}
