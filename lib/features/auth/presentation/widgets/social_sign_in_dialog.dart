import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/auth_state.dart';

Future<bool> requireSocialSignIn(BuildContext context) async {
  final authCubit = context.read<AuthCubit>();
  if (authCubit.state.isAuthenticated) return true;

  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => BlocProvider.value(
          value: authCubit,
          child: const SocialSignInDialog(),
        ),
      ) ??
      false;
}

enum _SignInProvider { google, apple }

class SocialSignInDialog extends StatefulWidget {
  const SocialSignInDialog({super.key});

  @override
  State<SocialSignInDialog> createState() => _SocialSignInDialogState();
}

class _SocialSignInDialogState extends State<SocialSignInDialog> {
  _SignInProvider? _activeProvider;

  void _signIn(_SignInProvider provider) {
    setState(() => _activeProvider = provider);
    final authCubit = context.read<AuthCubit>();
    if (provider == _SignInProvider.google) {
      authCubit.signInWithGoogle();
    } else {
      authCubit.signInWithApple();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated) Navigator.of(context).pop(true);
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.r16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.s24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'auth_required_title'.tr(),
                          style: AppTypography.h3,
                        ),
                      ),
                      IconButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).pop(false),
                        icon: const Icon(PhosphorIconsRegular.x),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s8),
                  Text(
                    'auth_required_message'.tr(),
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (state.status == AuthStatus.failure) ...[
                    const SizedBox(height: AppTokens.s16),
                    Text(
                      'auth_sign_in_failed'.tr(),
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTokens.s24),
                  AppButton(
                    text: 'continue_with_google'.tr(),
                    icon: PhosphorIconsRegular.googleLogo,
                    isPrimary: false,
                    isLoading:
                        isLoading && _activeProvider == _SignInProvider.google,
                    onPressed: isLoading
                        ? null
                        : () => _signIn(_SignInProvider.google),
                  ),
                  const SizedBox(height: AppTokens.s12),
                  AppButton(
                    text: 'continue_with_apple'.tr(),
                    icon: PhosphorIconsRegular.appleLogo,
                    isLoading:
                        isLoading && _activeProvider == _SignInProvider.apple,
                    onPressed: isLoading
                        ? null
                        : () => _signIn(_SignInProvider.apple),
                  ),
                  const SizedBox(height: AppTokens.s8),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: Text('cancel'.tr()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
