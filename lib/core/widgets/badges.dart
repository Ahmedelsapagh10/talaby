import 'package:flutter/material.dart';
import '../design_system/tokens.dart';

enum _StatusTone { success, warning, error, info, neutral, custom }

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final _StatusTone _tone;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  }) : _tone = _StatusTone.custom;

  const StatusBadge._({required this.label, required _StatusTone tone})
    : _tone = tone,
      backgroundColor = Colors.transparent,
      textColor = Colors.transparent;

  factory StatusBadge.success(String label) =>
      StatusBadge._(label: label, tone: _StatusTone.success);

  factory StatusBadge.warning(String label) =>
      StatusBadge._(label: label, tone: _StatusTone.warning);

  factory StatusBadge.error(String label) =>
      StatusBadge._(label: label, tone: _StatusTone.error);

  factory StatusBadge.info(String label) =>
      StatusBadge._(label: label, tone: _StatusTone.info);

  factory StatusBadge.neutral(String label) =>
      StatusBadge._(label: label, tone: _StatusTone.neutral);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolvedText = switch (_tone) {
      _StatusTone.success => scheme.primary,
      _StatusTone.warning => scheme.secondary,
      _StatusTone.error => scheme.error,
      _StatusTone.info => scheme.primary,
      _StatusTone.neutral => scheme.onSurfaceVariant,
      _StatusTone.custom => textColor,
    };
    final resolvedBackground = switch (_tone) {
      _StatusTone.neutral => scheme.surfaceContainerHighest,
      _StatusTone.custom => backgroundColor,
      _ => resolvedText.withValues(alpha: 0.1),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s8,
        vertical: AppTokens.s4,
      ),
      decoration: BoxDecoration(
        color: resolvedBackground,
        borderRadius: BorderRadius.circular(AppTokens.r12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: resolvedText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
