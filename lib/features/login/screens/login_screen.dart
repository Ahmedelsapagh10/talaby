import 'package:easy_localization/easy_localization.dart';
import 'package:new_strucuture/core/exports.dart';
import 'package:new_strucuture/config/themes/theme_helper.dart';
import 'package:new_strucuture/core/widgets/custom_button.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../config/routes/app_routes.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.adminOnly = false});

  final bool adminOnly;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final authCubit = context.read<AuthCubit>();
    await authCubit.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (authCubit.state.status == AuthStatus.failure) {
      setState(() => _isLoading = false);
      _showError(authCubit.state.message ?? 'auth_sign_in_failed'.tr());
      return;
    }
    if (widget.adminOnly && !authCubit.state.isAdmin) {
      await authCubit.logout();
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('admin_access_denied'.tr());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 600;

    final colors = ThemeHelper.colorsOf(context);
    final scaffoldBg = colors.background2;
    final cardBg = colors.surface;
    final cardBorder = colors.borderColor;
    final textColor = colors.black;
    final primaryTextColor = colors.textPrimary;
    final fieldBg = colors.background;
    final fieldBorder = colors.borderColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 400.0 : double.infinity,
              ),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Logo/Icon
                    Center(
                      child: Hero(
                        tag: 'app-logo',
                        transitionOnUserGestures: true,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            ImageAssets.appIconWithoutBG,
                            height: 64,
                            width: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Welcome Text
                    Center(
                      child: Text(
                        (widget.adminOnly
                                ? 'admin_login_title'
                                : 'welcome_back')
                            .tr(),
                        style: getBoldStyle(
                          fontSize: 22.0,
                          color: primaryTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        (widget.adminOnly
                                ? 'admin_login_subtitle'
                                : 'sign_in_subtitle')
                            .tr(),
                        style: getRegularStyle(
                          fontSize: 13.0,
                          color: AppColors.greya8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Username/Email Field
                    Text(
                      (widget.adminOnly ? 'email' : 'username_email').tr(),
                      style: getBoldStyle(
                        fontSize: 13.0,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      style: TextStyle(fontSize: 14, color: textColor),
                      decoration: InputDecoration(
                        hintText:
                            (widget.adminOnly
                                    ? 'enter_email'
                                    : 'enter_username_email')
                                .tr(),
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppColors.greya8,
                        ),
                        prefixIcon: const Icon(
                          PhosphorIconsRegular.user,
                          size: 20,
                          color: AppColors.greya8,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        filled: true,
                        fillColor: fieldBg,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: fieldBorder, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.red,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.red,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return (widget.adminOnly
                                  ? 'email_required'
                                  : 'username_email_required')
                              .tr();
                        }
                        if (widget.adminOnly &&
                            !RegExp(
                              r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                            ).hasMatch(value.trim())) {
                          return 'email_invalid'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    Text(
                      "password".tr(),
                      style: getBoldStyle(
                        fontSize: 13.0,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      autofillHints: const [AutofillHints.password],
                      style: TextStyle(fontSize: 14, color: textColor),
                      decoration: InputDecoration(
                        hintText: "enter_password".tr(),
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: AppColors.greya8,
                        ),
                        prefixIcon: const Icon(
                          PhosphorIconsRegular.lock,
                          size: 20,
                          color: AppColors.greya8,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? PhosphorIconsRegular.eyeSlash
                                : PhosphorIconsRegular.eye,
                            size: 20,
                            color: AppColors.greya8,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        filled: true,
                        fillColor: fieldBg,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: fieldBorder, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.red,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.red,
                            width: 1.5,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "password_required".tr();
                        }
                        if (value.length < 4) {
                          return "password_min_length".tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          context.push(Routes.forgotPasswordEmailRoute);
                        },
                        child: Text(
                          "forgot_password".tr(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    CustomButton(
                      title: (widget.adminOnly ? 'admin_sign_in' : 'sign_in')
                          .tr(),
                      onTap: _handleLogin,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () => context.go(
                              widget.adminOnly
                                  ? Routes.loginRoute
                                  : Routes.adminLoginRoute,
                            ),
                      icon: Icon(
                        widget.adminOnly
                            ? PhosphorIconsRegular.storefront
                            : PhosphorIconsRegular.shieldCheck,
                      ),
                      label: Text(
                        (widget.adminOnly
                                ? 'customer_sign_in'
                                : 'admin_sign_in')
                            .tr(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
