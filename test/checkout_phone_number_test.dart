import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/cart/presentation/widgets/checkout_phone_field.dart';
import 'package:new_strucuture/features/checkout/data/checkout_phone_number.dart';

void main() {
  group('CheckoutPhoneNumber', () {
    test('normalizes an Egyptian local mobile number to E.164', () {
      expect(
        CheckoutPhoneNumber.complete(
          countryCode: 'EG',
          dialCode: '+20',
          input: '01201709414',
        ),
        '+201201709414',
      );
    });

    test('keeps a valid Egyptian national number without a trunk prefix', () {
      expect(
        CheckoutPhoneNumber.complete(
          countryCode: 'EG',
          dialCode: '20',
          input: '1201709414',
        ),
        '+201201709414',
      );
    });

    test('rejects a number outside the selected country length', () {
      expect(
        CheckoutPhoneNumber.isValid(
          countryCode: 'EG',
          input: '12017',
          minLength: 10,
          maxLength: 10,
        ),
        isFalse,
      );
    });

    test('accepts an Egyptian number entered with its local trunk prefix', () {
      expect(
        CheckoutPhoneNumber.isValid(
          countryCode: 'EG',
          input: '01201709414',
          minLength: 10,
          maxLength: 10,
        ),
        isTrue,
      );
    });
  });

  testWidgets('checkout phone field selects Egypt and returns E.164', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var completeNumber = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: CheckoutPhoneField(
              controller: controller,
              initialCountryCode: 'EG',
              onChanged: (value) => completeNumber = value,
            ),
          ),
        ),
      ),
    );

    expect(find.text('+20'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '01201709414');
    await tester.pump();

    expect(formKey.currentState?.validate(), isTrue);
    expect(completeNumber, '+201201709414');
  });

  testWidgets('checkout phone field rejects a short number', (tester) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: CheckoutPhoneField(
              controller: controller,
              initialCountryCode: 'EG',
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), '123');
    await tester.pump();

    expect(formKey.currentState?.validate(), isFalse);
  });
}
