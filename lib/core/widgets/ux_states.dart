import 'package:flutter/material.dart';
import '../design_system/tokens.dart';
import '../design_system/typography.dart';
import 'app_buttons.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: AppTokens.bThick,
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF191B1A)),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: AppTokens.s16),
            Text(title, style: AppTypography.h4, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppTokens.s8),
              Text(
                subtitle!,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTokens.s24),
              AppButton(text: actionLabel!, onPressed: onAction, width: 200),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Oops, something went wrong',
      subtitle: message,
      actionLabel: 'Try Again',
      onAction: onRetry,
    );
  }
}
