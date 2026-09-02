import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../../core/design_system/tokens.dart';
import '../../../checkout/data/checkout_phone_number.dart';

class CheckoutPhoneField extends StatelessWidget {
  const CheckoutPhoneField({
    super.key,
    required this.controller,
    required this.initialCountryCode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String initialCountryCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'phone'.tr(),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppTokens.s8),
        IntlPhoneField(
          controller: controller,
          initialCountryCode: initialCountryCode,
          languageCode: Localizations.localeOf(context).languageCode,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          disableLengthCheck: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(hintText: 'phone_number_hint'.tr()),
          style: theme.textTheme.bodyLarge,
          validator: _validate,
          onChanged: (phone) => onChanged(_completeNumber(phone)),
          onCountryChanged: (country) =>
              onChanged(_completeNumberForCountry(country, controller.text)),
        ),
      ],
    );
  }

  String? _validate(PhoneNumber? phone) {
    if (phone == null || phone.number.trim().isEmpty) {
      return 'required_field'.tr();
    }

    final country = countries.firstWhere(
      (candidate) => candidate.code == phone.countryISOCode,
    );
    if (!CheckoutPhoneNumber.isValid(
      countryCode: country.code,
      input: phone.number,
      minLength: country.minLength,
      maxLength: country.maxLength,
    )) {
      return 'invalid_phone_number'.tr();
    }
    return null;
  }

  String _completeNumber(PhoneNumber phone) {
    return CheckoutPhoneNumber.complete(
      countryCode: phone.countryISOCode,
      dialCode: phone.countryCode,
      input: phone.number,
    );
  }

  String _completeNumberForCountry(Country country, String number) {
    return CheckoutPhoneNumber.complete(
      countryCode: country.code,
      dialCode: country.fullCountryCode,
      input: number,
    );
  }
}
