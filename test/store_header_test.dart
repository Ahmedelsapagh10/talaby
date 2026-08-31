import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/shop/presentation/store_header.dart';

void main() {
  testWidgets('store name uses the Major Mono Display font', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(appBar: StoreHeader())),
    );

    final title = tester.widget<Text>(find.text('TALABY'));
    expect(title.style?.fontFamily, 'MajorMonoDisplay');
  });
}
