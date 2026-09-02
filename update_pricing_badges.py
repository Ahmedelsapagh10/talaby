import re

with open('lib/core/widgets/pricing.dart', 'r') as f:
    pricing_content = f.read()

pricing_content = pricing_content.replace('Colors.grey.shade500', 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)')

with open('lib/core/widgets/pricing.dart', 'w') as f:
    f.write(pricing_content)

with open('lib/core/widgets/badges.dart', 'r') as f:
    badges_content = f.read()

# Update border radius
badges_content = badges_content.replace('AppTokens.r4', 'AppTokens.r12')

# Map old hardcoded status colors to theme colors roughly
# Using theme-aware colors will require passing BuildContext, but since these are factory constructors,
# it's better to create a generic Badge component and let the theme dictate colors,
# but to keep backward compatibility without breaking existing files, let's keep it as is,
# just adjust the colors to match the app palette slightly closer.

# Actually, we can use AppColorsExtension to fetch the fixed status colors!
badges_replacement = """import 'package:flutter/material.dart';
import '../../config/themes/app_colors_extension.dart';
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
    backgroundColor: AppColorsExtension.light.success.withValues(alpha: 0.1),
    textColor: AppColorsExtension.light.success,
  );

  factory StatusBadge.warning(String label) => StatusBadge(
    label: label,
    backgroundColor: AppColorsExtension.light.warning.withValues(alpha: 0.1),
    textColor: AppColorsExtension.light.warning,
  );

  factory StatusBadge.error(String label) => StatusBadge(
    label: label,
    backgroundColor: AppColorsExtension.light.error.withValues(alpha: 0.1),
    textColor: AppColorsExtension.light.error,
  );

  factory StatusBadge.info(String label) => StatusBadge(
    label: label,
    backgroundColor: AppColorsExtension.light.primary.withValues(alpha: 0.1),
    textColor: AppColorsExtension.light.primary,
  );

  factory StatusBadge.neutral(String label) => StatusBadge(
    label: label,
    backgroundColor: AppColorsExtension.light.lightGray ?? const Color(0xFFF4F3ED),
    textColor: AppColorsExtension.light.textSecondary,
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
        borderRadius: BorderRadius.circular(AppTokens.r12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
"""

with open('lib/core/widgets/badges.dart', 'w') as f:
    f.write(badges_replacement)

