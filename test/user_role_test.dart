import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/auth/data/models/user_role.dart';

void main() {
  test('only store members can manage the store', () {
    expect(UserRole.admin.canManageStore, isTrue);
    expect(UserRole.staff.canManageStore, isTrue);
    expect(UserRole.customer.canManageStore, isFalse);
  });

  test('unknown role values are rejected', () {
    expect(UserRoleCodec.fromValue('owner'), isNull);
    expect(UserRoleCodec.fromValue('admin'), UserRole.admin);
  });
}
