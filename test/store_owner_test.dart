import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/store/data/models/owner.dart';

void main() {
  test('owner profile writes the admin-controlled active state', () {
    const owner = Owner(
      id: 'admin-1',
      name: 'Talaby',
      slug: 'talaby',
      active: false,
    );

    expect(owner.toPublicProfileMap()['active'], isFalse);
  });
}
