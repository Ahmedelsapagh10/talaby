import 'package:flutter/material.dart';
import '../design_system/tokens.dart';
import '../design_system/typography.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  factory StatusBadge.success(String label) => StatusBadge(
    label: label,
    backgroundColor: Colors.green.shade50,
    textColor: Colors.green.shade700,
  );

  factory StatusBadge.warning(String label) => StatusBadge(
    label: label,
    backgroundColor: Colors.orange.shade50,
    textColor: Colors.orange.shade800,
  );

  factory StatusBadge.error(String label) => StatusBadge(
    label: label,
    backgroundColor: Colors.red.shade50,
    textColor: Colors.red.shade700,
  );

  factory StatusBadge.info(String label) => StatusBadge(
    label: label,
    backgroundColor: Colors.blue.shade50,
    textColor: Colors.blue.shade700,
  );

  factory StatusBadge.neutral(String label) => StatusBadge(
    label: label,
    backgroundColor: Colors.grey.shade100,
    textColor: Colors.grey.shade800,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s8,
        vertical: AppTokens.s4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTokens.r4),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
