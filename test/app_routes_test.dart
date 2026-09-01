import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/config/routes/app_routes.dart';
import 'package:new_strucuture/features/auth/cubit/auth_state.dart';
import 'package:new_strucuture/features/auth/data/models/auth_session.dart';
import 'package:new_strucuture/features/auth/data/models/user_role.dart';

void main() {
  const unauthenticated = AuthState(status: AuthStatus.unauthenticated);
  const customer = AuthState(
    status: AuthStatus.authenticated,
    session: AuthSession(
      uid: 'customer-id',
      email: 'customer@example.com',
      role: UserRole.customer,
    ),
  );
  const admin = AuthState(
    status: AuthStatus.authenticated,
    session: AuthSession(
      uid: 'admin-id',
      email: 'admin@example.com',
      role: UserRole.admin,
    ),
  );

  test('protected admin routes preserve their target through admin login', () {
    final redirect = AppRoutes.resolveRedirect(
      unauthenticated,
      Uri.parse('/admin/products/42/edit'),
    );

    expect(redirect, '/admin/login?redirect=%2Fadmin%2Fproducts%2F42%2Fedit');
  });

  test('admin login returns an authorized member to the requested page', () {
    final redirect = AppRoutes.resolveRedirect(
      admin,
      Uri.parse('/admin/login?redirect=%2Fadmin%2Forders'),
    );

    expect(redirect, '/admin/orders');
  });

  test('customer cannot open a protected admin route', () {
    expect(
      AppRoutes.resolveRedirect(customer, Uri.parse('/admin/products')),
      Routes.initialRoute,
    );
  });

  test('customer stays on admin login long enough to show access denied', () {
    expect(
      AppRoutes.resolveRedirect(customer, Uri.parse('/admin/login')),
      isNull,
    );
  });
}
