import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/ux_states.dart';
import '../../store/data/models/store_settings.dart';
import '../cubit/admin_settings_cubit.dart';
import '../cubit/admin_settings_state.dart';
import 'widgets/admin_banner_settings_form.dart';
import 'widgets/admin_settings_form.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final fields = OwnerFormFields();
  final bannerFields = BannerFormFields();
  bool _initialized = false;
  bool _dirty = false;
  String _currency = 'EGP';
  bool _stockControl = true;
  bool _manualPayment = true;
  bool _cashOnDelivery = true;
  bool _storeActive = true;
  bool _bannerEnabled = true;
  String? _bannerImageUrl;

  @override
  void dispose() {
    fields.dispose();
    bannerFields.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminSettingsCubit, AdminSettingsState>(
      listener: (context, state) {
        if (state.status == AdminSettingsStatus.success) {
          setState(() => _dirty = false);
          AppToast.success(context, 'settings_saved'.tr());
        } else if (state.status == AdminSettingsStatus.failure &&
            _initialized) {
          AppToast.error(context, state.message ?? 'settings_save_failed'.tr());
        }
      },
      builder: (context, state) {
        if (state.status == AdminSettingsStatus.loading) {
          return const LoadingState();
        }
        if (state.status == AdminSettingsStatus.failure && !_initialized) {
          return ErrorState(
            message: 'load_settings_failed'.tr(),
            onRetry: context.read<AdminSettingsCubit>().load,
          );
        }
        if (state.owner == null) {
          return EmptyState(
            icon: PhosphorIconsRegular.storefront,
            title: 'store_not_configured'.tr(),
          );
        }
        _initialize(state);
        final busy =
            state.status == AdminSettingsStatus.saving ||
            state.status == AdminSettingsStatus.uploading;
        return PopScope(
          canPop: !_dirty,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _dirty) _showUnsavedMessage();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTokens.s24),
            child: Form(
              onChanged: () => setState(() => _dirty = true),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('store_settings'.tr(), style: AppTypography.h2),
                  const SizedBox(height: AppTokens.s24),
                  OwnerSettingsForm(
                    fields: fields,
                    logoUrl: state.owner!.logoUrl,
                    onUploadLogo: context
                        .read<AdminSettingsCubit>()
                        .uploadAndSaveLogo,
                  ),
                  const SizedBox(height: AppTokens.s24),
                  AdminBannerSettingsForm(
                    fields: bannerFields,
                    enabled: _bannerEnabled,
                    imageUrl: _bannerImageUrl,
                    busy: busy,
                    onEnabledChanged: (value) => setState(() {
                      _bannerEnabled = value;
                      _dirty = true;
                    }),
                    onUploadImage: _uploadBannerImage,
                    onRemoveImage: () => setState(() {
                      _bannerImageUrl = null;
                      _dirty = true;
                    }),
                  ),
                  const SizedBox(height: AppTokens.s24),
                  StoreBehaviorForm(
                    currency: _currency,
                    storeActive: _storeActive,
                    stockControl: _stockControl,
                    manualPayment: _manualPayment,
                    cashOnDelivery: _cashOnDelivery,
                    onCurrencyChanged: (value) => setState(() {
                      _currency = value;
                      _dirty = true;
                    }),
                    onStoreActiveChanged: (value) => setState(() {
                      _storeActive = value;
                      _dirty = true;
                    }),
                    onStockControlChanged: (value) => setState(() {
                      _stockControl = value;
                      _dirty = true;
                    }),
                    onManualPaymentChanged: (value) => setState(() {
                      _manualPayment = value;
                      _dirty = true;
                    }),
                    onCashOnDeliveryChanged: (value) => setState(() {
                      _cashOnDelivery = value;
                      _dirty = true;
                    }),
                  ),
                  const SizedBox(height: AppTokens.s32),
                  AppButton(
                    text: 'save_settings'.tr(),
                    isLoading: busy,
                    onPressed: busy ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _initialize(AdminSettingsState state) {
    if (_initialized) return;
    _initialized = true;
    fields.fill(state.owner!);
    final settings = state.settings ?? const StoreSettings();
    _currency = settings.currencyCode;
    _storeActive = settings.active;
    _stockControl = settings.stockControlEnabled;
    _manualPayment = settings.manualPaymentEnabled;
    _cashOnDelivery = settings.cashOnDeliveryEnabled;
    _bannerEnabled = settings.bannerEnabled;
    _bannerImageUrl = settings.bannerImageUrl;
    bannerFields.fill(settings);
  }

  Future<void> _save() async {
    final cubit = context.read<AdminSettingsCubit>();
    final owner = cubit.state.owner!;
    await cubit.saveAll(
      fields.toOwner(owner),
      StoreSettings(
        active: _storeActive,
        currencyCode: _currency.trim().toUpperCase(),
        stockControlEnabled: _stockControl,
        manualPaymentEnabled: _manualPayment,
        cashOnDeliveryEnabled: _cashOnDelivery,
        bannerEnabled: _bannerEnabled,
        bannerTitleAr: bannerFields.title.text.trim(),
        bannerSubtitleAr: bannerFields.subtitle.text.trim(),
        bannerImageUrl: _bannerImageUrl,
      ),
    );
  }

  Future<void> _uploadBannerImage() async {
    final url = await context.read<AdminSettingsCubit>().uploadBannerImage();
    if (!mounted || url == null) return;
    setState(() {
      _bannerImageUrl = url;
      _dirty = true;
    });
  }

  void _showUnsavedMessage() {
    AppToast.info(context, 'unsaved_changes'.tr());
  }
}
