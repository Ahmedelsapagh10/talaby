import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/store/data/models/store_settings.dart';

void main() {
  test('store settings serialize admin banner configuration', () {
    const settings = StoreSettings(
      bannerEnabled: false,
      bannerTitleAr: 'عنوان',
      bannerSubtitleAr: 'وصف',
      bannerImageUrl: 'https://example.com/banner.jpg',
    );

    expect(settings.toMap(), containsPair('bannerEnabled', false));
    expect(settings.toMap(), containsPair('active', true));
    expect(settings.toMap(), containsPair('bannerTitleAr', 'عنوان'));
    expect(
      settings.toMap(),
      containsPair('bannerImageUrl', 'https://example.com/banner.jpg'),
    );
  });

  test('store settings preserve the admin-controlled active state', () {
    expect(const StoreSettings(active: false).toMap()['active'], isFalse);
  });
}
