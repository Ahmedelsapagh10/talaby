import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/design_system/typography.dart';
import '../../../../../core/widgets/app_buttons.dart';
import '../../../../../core/widgets/app_text_fields.dart';
import '../../../store/data/models/owner.dart';

class OwnerFormFields {
  final name = TextEditingController();
  final slug = TextEditingController();
  final phone = TextEditingController();
  final whatsapp = TextEditingController();
  final email = TextEditingController();
  final instagram = TextEditingController();
  final facebook = TextEditingController();
  final primaryColor = TextEditingController();
  final secondaryColor = TextEditingController();

  void fill(Owner owner) {
    name.text = owner.name;
    slug.text = owner.slug;
    phone.text = owner.phone ?? '';
    whatsapp.text = owner.whatsappPhone ?? '';
    email.text = owner.email ?? '';
    instagram.text = owner.instagram ?? '';
    facebook.text = owner.facebook ?? '';
    primaryColor.text = owner.primaryColor ?? '';
    secondaryColor.text = owner.secondaryColor ?? '';
  }

  Owner toOwner(Owner owner) => owner.copyWith(
    name: name.text.trim(),
    slug: slug.text.trim(),
    phone: phone.text.trim(),
    whatsappPhone: whatsapp.text.trim(),
    email: email.text.trim(),
    instagram: instagram.text.trim(),
    facebook: facebook.text.trim(),
    primaryColor: primaryColor.text.trim(),
    secondaryColor: secondaryColor.text.trim(),
  );

  void dispose() {
    for (final controller in [
      name,
      slug,
      phone,
      whatsapp,
      email,
      instagram,
      facebook,
      primaryColor,
      secondaryColor,
    ]) {
      controller.dispose();
    }
  }
}

class OwnerSettingsForm extends StatelessWidget {
  const OwnerSettingsForm({
    super.key,
    required this.fields,
    required this.logoUrl,
    required this.onUploadLogo,
  });

  final OwnerFormFields fields;
  final String? logoUrl;
  final VoidCallback onUploadLogo;

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'store_profile'.tr(),
    children: [
      if (logoUrl?.isNotEmpty == true)
        Image.network(logoUrl!, width: 80, height: 80, fit: BoxFit.cover),
      AppButton(
        text: 'upload_logo'.tr(),
        isPrimary: false,
        onPressed: onUploadLogo,
      ),
      const SizedBox(height: AppTokens.s16),
      AppTextField(label: 'store_name'.tr(), controller: fields.name),
      const SizedBox(height: AppTokens.s12),
      AppTextField(label: 'slug'.tr(), controller: fields.slug),
      const SizedBox(height: AppTokens.s12),
      AppTextField(label: 'phone'.tr(), controller: fields.phone),
      const SizedBox(height: AppTokens.s12),
      AppTextField(label: 'whatsapp'.tr(), controller: fields.whatsapp),
      const SizedBox(height: AppTokens.s12),
      AppTextField(label: 'email'.tr(), controller: fields.email),
      const SizedBox(height: AppTokens.s12),
      AppTextField(label: 'instagram'.tr(), controller: fields.instagram),
      const SizedBox(height: AppTokens.s12),
      AppTextField(label: 'facebook'.tr(), controller: fields.facebook),
      const SizedBox(height: AppTokens.s12),
      AppTextField(
        label: 'primary_color'.tr(),
        controller: fields.primaryColor,
      ),
      const SizedBox(height: AppTokens.s12),
      AppTextField(
        label: 'secondary_color'.tr(),
        controller: fields.secondaryColor,
      ),
    ],
  );
}

class StoreBehaviorForm extends StatelessWidget {
  const StoreBehaviorForm({
    super.key,
    required this.currency,
    required this.stockControl,
    required this.manualPayment,
    required this.cashOnDelivery,
    required this.onCurrencyChanged,
    required this.onStockControlChanged,
    required this.onManualPaymentChanged,
    required this.onCashOnDeliveryChanged,
  });

  final String currency;
  final bool stockControl;
  final bool manualPayment;
  final bool cashOnDelivery;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<bool> onStockControlChanged;
  final ValueChanged<bool> onManualPaymentChanged;
  final ValueChanged<bool> onCashOnDeliveryChanged;

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'store_behavior'.tr(),
    children: [
      TextFormField(
        initialValue: currency,
        decoration: InputDecoration(labelText: 'currency_code'.tr()),
        onChanged: onCurrencyChanged,
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('stock_control'.tr()),
        value: stockControl,
        onChanged: onStockControlChanged,
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('manual_payments'.tr()),
        value: manualPayment,
        onChanged: onManualPaymentChanged,
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('cash_on_delivery'.tr()),
        value: cashOnDelivery,
        onChanged: onCashOnDeliveryChanged,
      ),
    ],
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 900),
    padding: const EdgeInsets.all(AppTokens.s24),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade200),
      borderRadius: BorderRadius.circular(AppTokens.r8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h4),
        const SizedBox(height: AppTokens.s16),
        ...children,
      ],
    ),
  );
}
