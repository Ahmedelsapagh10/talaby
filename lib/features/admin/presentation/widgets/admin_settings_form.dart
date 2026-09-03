import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/design_system/typography.dart';
import '../../../../../core/widgets/app_buttons.dart';
import '../../../../../core/widgets/app_text_fields.dart';
import '../../../store/data/models/owner.dart';

class OwnerFormFields {
  static const defaultPrimaryColor = '#176B4D';
  static const defaultSecondaryColor = '#F2C14E';

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
    primaryColor.text = _normalizeHexColor(
      owner.primaryColor,
      fallback: defaultPrimaryColor,
    );
    secondaryColor.text = _normalizeHexColor(
      owner.secondaryColor,
      fallback: defaultSecondaryColor,
    );
  }

  Owner toOwner(Owner owner) => owner.copyWith(
    name: name.text.trim(),
    slug: slug.text.trim(),
    phone: phone.text.trim(),
    whatsappPhone: whatsapp.text.trim(),
    email: email.text.trim(),
    instagram: instagram.text.trim(),
    facebook: facebook.text.trim(),
    primaryColor: _normalizeHexColor(
      primaryColor.text,
      fallback: defaultPrimaryColor,
    ),
    secondaryColor: _normalizeHexColor(
      secondaryColor.text,
      fallback: defaultSecondaryColor,
    ),
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
      _ColorField(
        label: 'primary_color'.tr(),
        controller: fields.primaryColor,
        fallback: OwnerFormFields.defaultPrimaryColor,
        presets: const ['#176B4D', '#087E8B', '#31538E', '#7A284B'],
      ),
      const SizedBox(height: AppTokens.s12),
      _ColorField(
        label: 'secondary_color'.tr(),
        controller: fields.secondaryColor,
        fallback: OwnerFormFields.defaultSecondaryColor,
        presets: const ['#F2C14E', '#EB7D00', '#D95D39', '#6C5CE7'],
      ),
    ],
  );
}

class _ColorField extends StatefulWidget {
  const _ColorField({
    required this.label,
    required this.controller,
    required this.fallback,
    required this.presets,
  });

  final String label;
  final TextEditingController controller;
  final String fallback;
  final List<String> presets;

  @override
  State<_ColorField> createState() => _ColorFieldState();
}

class _ColorFieldState extends State<_ColorField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refreshPreview);
  }

  @override
  void didUpdateWidget(covariant _ColorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_refreshPreview);
    widget.controller.addListener(_refreshPreview);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refreshPreview);
    super.dispose();
  }

  void _refreshPreview() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = _normalizeHexColor(
      widget.controller.text,
      fallback: widget.fallback,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppTokens.s8),
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.visiblePassword,
          textCapitalization: TextCapitalization.characters,
          maxLength: 7,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[#0-9a-fA-F]')),
          ],
          style: theme.textTheme.bodyLarge?.copyWith(
            fontFamily: AppTypography.latinFontFamily,
          ),
          decoration: InputDecoration(
            hintText: widget.fallback,
            counterText: '',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(AppTokens.s12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _colorFromHex(normalized),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: const SizedBox.square(dimension: AppTokens.s24),
              ),
            ),
            suffixIcon: PopupMenuButton<String>(
              tooltip: widget.label,
              icon: const Icon(PhosphorIconsRegular.palette),
              onSelected: (value) => widget.controller.text = value,
              itemBuilder: (_) => widget.presets
                  .map(
                    (value) => PopupMenuItem(
                      value: value,
                      child: Row(
                        children: [
                          Container(
                            width: AppTokens.s24,
                            height: AppTokens.s24,
                            decoration: BoxDecoration(
                              color: _colorFromHex(value),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTokens.s12),
                          Text(
                            value,
                            style: const TextStyle(
                              fontFamily: AppTypography.latinFontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

String _normalizeHexColor(String? value, {required String fallback}) {
  final trimmed = value?.trim().toUpperCase() ?? '';
  final normalized = trimmed.startsWith('#') ? trimmed : '#$trimmed';
  return RegExp(r'^#[0-9A-F]{6}$').hasMatch(normalized) ? normalized : fallback;
}

Color _colorFromHex(String value) =>
    Color(int.parse('FF${value.substring(1)}', radix: 16));

class StoreBehaviorForm extends StatelessWidget {
  const StoreBehaviorForm({
    super.key,
    required this.currency,
    required this.storeActive,
    required this.stockControl,
    required this.manualPayment,
    required this.cashOnDelivery,
    required this.onCurrencyChanged,
    required this.onStoreActiveChanged,
    required this.onStockControlChanged,
    required this.onManualPaymentChanged,
    required this.onCashOnDeliveryChanged,
  });

  final String currency;
  final bool storeActive;
  final bool stockControl;
  final bool manualPayment;
  final bool cashOnDelivery;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<bool> onStoreActiveChanged;
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
        title: Text('active'.tr()),
        value: storeActive,
        onChanged: onStoreActiveChanged,
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
      border: Border.all(color: Theme.of(context).dividerColor),
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
