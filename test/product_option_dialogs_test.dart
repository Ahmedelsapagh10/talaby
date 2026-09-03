import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/config/themes/app_theme.dart';
import 'package:new_strucuture/core/widgets/app_text_fields.dart';
import 'package:new_strucuture/features/admin/presentation/widgets/product_option_dialogs.dart';
import 'package:new_strucuture/features/catalog/data/models/product_color.dart';

void main() {
  testWidgets('variant dialog keeps fields separated at desktop width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightThemeFor(const Locale('ar')),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => showProductVariantDialog(
                    context,
                    const [
                      ProductColor(id: 'black', name: 'أسود', hex: '#000000'),
                    ],
                    const ['20'],
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(AppDropdown<String>), findsNWidgets(2));
    expect(find.byType(AppTextField), findsNWidgets(2));
    expect(tester.getSize(find.byType(AlertDialog)).width, greaterThan(400));

    final fields = <Finder>[
      find.byType(AppDropdown<String>).at(0),
      find.byType(AppDropdown<String>).at(1),
      find.byType(AppTextField).at(0),
      find.byType(AppTextField).at(1),
    ];
    for (var index = 1; index < fields.length; index++) {
      expect(
        tester.getTopLeft(fields[index]).dy,
        greaterThan(tester.getBottomLeft(fields[index - 1]).dy),
      );
    }
    expect(tester.takeException(), isNull);
  });
}
