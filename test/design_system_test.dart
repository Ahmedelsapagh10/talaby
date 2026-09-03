import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/config/themes/app_colors_extension.dart';
import 'package:new_strucuture/config/themes/app_theme.dart';
import 'package:new_strucuture/core/widgets/app_buttons.dart';
import 'package:new_strucuture/features/admin/presentation/widgets/admin_table.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

void main() {
  test('theme selects bundled typography for the active locale', () {
    expect(
      AppTheme.lightThemeFor(
        const Locale('ar'),
      ).textTheme.bodyMedium?.fontFamily,
      'Cairo',
    );
    expect(
      AppTheme.lightThemeFor(
        const Locale('en'),
      ).textTheme.bodyMedium?.fontFamily,
      'Manrope',
    );
  });

  test('earthy semantic palette is exposed by the theme extension', () {
    final colors = AppTheme.lightTheme.extension<AppColorsExtension>();

    expect(colors?.primary, const Color(0xFF176B4D));
    expect(colors?.accent, const Color(0xFFEB7D00));
    expect(colors?.secondary, const Color(0xFFF2C14E));
    expect(colors?.surfaceMuted, const Color(0xFFF4F3ED));
  });

  testWidgets('accent button uses the promotional color', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AppButton(
            text: 'Buy now',
            variant: AppButtonVariant.accent,
            onPressed: () {},
          ),
        ),
      ),
    );

    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFFEB7D00));
  });

  testWidgets('long Arabic accent action remains visible at dialog width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 260,
              child: AppButton(
                text: 'إضافة إلى سلة التسوق',
                icon: PhosphorIconsRegular.bag,
                variant: AppButtonVariant.accent,
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('إضافة إلى سلة التسوق'), findsOneWidget);
  });

  testWidgets('admin table scrolls safely on a narrow viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AdminTable(
            columns: const [
              DataColumn(label: Text('Order')),
              DataColumn(label: Text('Customer')),
            ],
            rows: const [
              DataRow(cells: [DataCell(Text('#1')), DataCell(Text('Ahmed'))]),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(DataTable), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
