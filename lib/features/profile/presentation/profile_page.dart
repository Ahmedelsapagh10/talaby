import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_fields.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/ux_states.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
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
  bool _socialSignInLoading = false;

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
            AppToast.success(context, 'profile_saved'.tr());
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
              maxWidth: 820,
              child: ResponsiveGutter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppTokens.s32),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTokens.s24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'my_profile'.tr(),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
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
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, authState) {
                                final hasEmail =
                                    authState.session?.email != null &&
                                    authState.session!.email!.isNotEmpty;
                                if (hasEmail) return const SizedBox.shrink();
                                return _buildSocialSignInSection(context);
                              },
                            ),
                            const Divider(height: AppTokens.s48),
                            ListTile(
                              leading: const Icon(PhosphorIconsRegular.receipt),
                              title: Text('my_orders'.tr()),
                              onTap: () => context.push(Routes.accountRoute),
                            ),
                            ListTile(
                              leading: const Icon(PhosphorIconsRegular.heart),
                              title: Text('wishlist'.tr()),
                              onTap: () => context.push(Routes.wishlistRoute),
                            ),
                            ListTile(
                              leading: const Icon(PhosphorIconsRegular.signOut),
                              title: Text('sign_out'.tr()),
                              onTap: context.read<AuthCubit>().logout,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSocialSignInSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: AppTokens.s48),
        Text(
          'sign_in_with_account'.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTokens.s8),
        Text(
          'sign_in_with_account_hint'.tr(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppTokens.s16),
        AppButton(
          text: 'continue_with_google'.tr(),
          icon: PhosphorIconsRegular.googleLogo,
          isPrimary: false,
          isLoading: _socialSignInLoading,
          onPressed: _socialSignInLoading ? null : _signInWithGoogle,
        ),
        const SizedBox(height: AppTokens.s12),
        AppButton(
          text: 'continue_with_apple'.tr(),
          icon: PhosphorIconsRegular.appleLogo,
          isLoading: _socialSignInLoading,
          onPressed: _socialSignInLoading ? null : _signInWithApple,
        ),
      ],
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _socialSignInLoading = true);
    try {
      await context.read<AuthCubit>().signInWithGoogle();
      if (!mounted) return;
      final authState = context.read<AuthCubit>().state;
      if (authState.status == AuthStatus.failure) {
        _showSignInError(authState.message);
      }
    } catch (_) {
      if (mounted) _showSignInError(null);
    } finally {
      if (mounted) setState(() => _socialSignInLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _socialSignInLoading = true);
    try {
      await context.read<AuthCubit>().signInWithApple();
      if (!mounted) return;
      final authState = context.read<AuthCubit>().state;
      if (authState.status == AuthStatus.failure) {
        _showSignInError(authState.message);
      }
    } catch (_) {
      if (mounted) _showSignInError(null);
    } finally {
      if (mounted) setState(() => _socialSignInLoading = false);
    }
  }

  void _showSignInError(String? message) {
    AppToast.error(context, message ?? 'auth_sign_in_failed'.tr());
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
