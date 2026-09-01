import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/wishlist/cubit/wishlist_state.dart';

void main() {
  test('contains only reports persisted product identifiers', () {
    const state = WishlistState(
      status: WishlistStatus.success,
      productIds: {'product-1'},
    );

    expect(state.contains('product-1'), isTrue);
    expect(state.contains('product-2'), isFalse);
  });
}
