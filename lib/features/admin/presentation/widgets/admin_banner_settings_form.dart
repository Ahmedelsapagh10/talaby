import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/design_system/typography.dart';
import '../../../../../core/widgets/app_buttons.dart';
import '../../../../../core/widgets/app_text_fields.dart';
import '../../../store/data/models/store_settings.dart';

class BannerFormFields {
  final titleAr = TextEditingController();
  final titleEn = TextEditingController();
  final subtitleAr = TextEditingController();
  final subtitleEn = TextEditingController();

  void fill(StoreSettings settings) {
    titleAr.text = settings.bannerTitleAr;
    titleEn.text = settings.bannerTitleEn;
    subtitleAr.text = settings.bannerSubtitleAr;
    subtitleEn.text = settings.bannerSubtitleEn;
  }

  void dispose() {
    titleAr.dispose();
    titleEn.dispose();
    subtitleAr.dispose();
    subtitleEn.dispose();
  }
}

class AdminBannerSettingsForm extends StatelessWidget {
  const AdminBannerSettingsForm({
    super.key,
    required this.fields,
    required this.enabled,
    required this.imageUrl,
    required this.busy,
    required this.onEnabledChanged,
    required this.onUploadImage,
    required this.onRemoveImage,
  });

  final BannerFormFields fields;
  final bool enabled;
  final String? imageUrl;
  final bool busy;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onUploadImage;
  final VoidCallback onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      padding: const EdgeInsets.all(AppTokens.s24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(AppTokens.r8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('banner_settings'.tr(), style: AppTypography.h4),
          const SizedBox(height: AppTokens.s8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('show_banner'.tr()),
            value: enabled,
            onChanged: busy ? null : onEnabledChanged,
          ),
          if (imageUrl?.isNotEmpty == true) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.r8),
              child: Image.network(
                imageUrl!,
                width: 700,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: AppTokens.s12),
          ],
          Wrap(
            spacing: AppTokens.s12,
            runSpacing: AppTokens.s8,
            children: [
              AppButton(
                text: 'upload_banner_image'.tr(),
                icon: Icons.image_outlined,
                isPrimary: false,
                isLoading: busy,
                onPressed: busy ? null : onUploadImage,
              ),
              if (imageUrl?.isNotEmpty == true)
                AppButton(
                  text: 'remove_banner_image'.tr(),
                  icon: Icons.delete_outline,
                  isPrimary: false,
                  onPressed: busy ? null : onRemoveImage,
                ),
            ],
          ),
          const SizedBox(height: AppTokens.s16),
          AppTextField(
            label: 'banner_title_ar'.tr(),
            controller: fields.titleAr,
          ),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            label: 'banner_title_en'.tr(),
            controller: fields.titleEn,
          ),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            label: 'banner_subtitle_ar'.tr(),
            controller: fields.subtitleAr,
            maxLines: 2,
          ),
          const SizedBox(height: AppTokens.s12),
          AppTextField(
            label: 'banner_subtitle_en'.tr(),
            controller: fields.subtitleEn,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
