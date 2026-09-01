import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_fields.dart';
import '../../../../core/widgets/ux_states.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../shop/presentation/store_header.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../data/models/customer_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    for (final controller in [_name, _email, _phone, _city, _address]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StoreHeader(),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('profile_saved'.tr())));
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const LoadingState();
          }
          if (state.status == ProfileStatus.failure && state.profile == null) {
            return ErrorState(
              message: 'profile_load_failed'.tr(),
              onRetry: () => context.read<ProfileCubit>().load(
                context.read<AuthCubit>().state.session!.uid,
              ),
            );
          }
          final profile = state.profile;
          if (profile == null) return const SizedBox.shrink();
          _initialize(profile);
          return SingleChildScrollView(
            child: ResponsiveContentWidth(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.s24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('my_profile'.tr(), style: AppTypography.h2),
                      const SizedBox(height: AppTokens.s24),
                      AppTextField(
                        label: 'name'.tr(),
                        controller: _name,
                        validator: _required,
                      ),
                      const SizedBox(height: AppTokens.s16),
                      AppTextField(
                        label: 'email'.tr(),
                        controller: _email,
                        enabled: false,
                      ),
                      const SizedBox(height: AppTokens.s16),
                      AppTextField(
                        label: 'phone'.tr(),
                        controller: _phone,
                        validator: _required,
                      ),
                      const SizedBox(height: AppTokens.s16),
                      AppTextField(
                        label: 'city'.tr(),
                        controller: _city,
                        validator: _required,
                      ),
                      const SizedBox(height: AppTokens.s16),
                      AppTextField(
                        label: 'default_address'.tr(),
                        controller: _address,
                        maxLines: 3,
                        validator: _required,
                      ),
                      const SizedBox(height: AppTokens.s24),
                      AppButton(
                        text: 'save_profile'.tr(),
                        isLoading: state.status == ProfileStatus.saving,
                        onPressed: _save,
                      ),
                      const Divider(height: AppTokens.s48),
                      ListTile(
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: Text('my_orders'.tr()),
                        onTap: () => context.push(Routes.accountRoute),
                      ),
                      ListTile(
                        leading: const Icon(Icons.favorite_border),
                        title: Text('wishlist'.tr()),
                        onTap: () => context.push(Routes.wishlistRoute),
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: Text('sign_out'.tr()),
                        onTap: context.read<AuthCubit>().logout,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _initialize(CustomerProfile profile) {
    if (_initialized) return;
    _initialized = true;
    _name.text = profile.name;
    _email.text = profile.email;
    _phone.text = profile.phone;
    _city.text = profile.defaultCity;
    _address.text = profile.defaultAddress;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final current = context.read<ProfileCubit>().state.profile!;
    context.read<ProfileCubit>().save(
      CustomerProfile(
        userId: current.userId,
        name: _name.text,
        email: current.email,
        phone: _phone.text,
        defaultCity: _city.text,
        defaultAddress: _address.text,
      ),
    );
  }
}

String? _required(String? value) =>
    value == null || value.trim().isEmpty ? 'required_field'.tr() : null;
