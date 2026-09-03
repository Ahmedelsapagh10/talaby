import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/config/themes/app_theme.dart';
import 'package:new_strucuture/features/admin/presentation/widgets/admin_settings_form.dart';
import 'package:new_strucuture/features/store/data/models/owner.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

void main() {
  const owner = Owner(id: 'owner', name: 'Talaby', slug: 'talaby');

  test('brand colors use vivid defaults and normalize saved hex', () {
    final fields = OwnerFormFields()..fill(owner);
    addTearDown(fields.dispose);

    expect(fields.primaryColor.text, OwnerFormFields.defaultPrimaryColor);
    expect(fields.secondaryColor.text, OwnerFormFields.defaultSecondaryColor);

    fields.primaryColor.text = '087e8b';
    fields.secondaryColor.text = 'invalid';
    final updated = fields.toOwner(owner);

    expect(updated.primaryColor, '#087E8B');
    expect(updated.secondaryColor, OwnerFormFields.defaultSecondaryColor);
  });

  testWidgets('brand color fields expose live previews and presets', (
    tester,
  ) async {
    final fields = OwnerFormFields()..fill(owner);
    addTearDown(fields.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightThemeFor(const Locale('ar')),
        home: Scaffold(
          body: SingleChildScrollView(
            child: OwnerSettingsForm(
              fields: fields,
              logoUrl: null,
              onUploadLogo: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(PhosphorIconsRegular.palette), findsNWidgets(2));
    expect(find.text(OwnerFormFields.defaultPrimaryColor), findsWidgets);
    expect(find.text(OwnerFormFields.defaultSecondaryColor), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
