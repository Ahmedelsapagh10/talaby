import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:new_strucuture/features/admin/presentation/admin_shell.dart';

void main() {
  testWidgets('desktop admin sidebar navigates to categories', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      initialLocation: '/admin',
      routes: [
        GoRoute(
          path: '/admin',
          builder: (_, _) =>
              const AdminShell(child: Center(child: Text('overview-content'))),
        ),
        GoRoute(
          path: '/admin/categories',
          builder: (_, _) => const Center(child: Text('categories-content')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('categories'));
    await tester.pumpAndSettle();

    expect(find.text('categories-content'), findsOneWidget);
  });

  testWidgets('mobile admin shell exposes overflow sections without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: AdminShell(child: Center(child: Text('overview-content'))),
      ),
    );
    await tester.tap(find.text('more'));
    await tester.pumpAndSettle();

    expect(find.text('categories'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
