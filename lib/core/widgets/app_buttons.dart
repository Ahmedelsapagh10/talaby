import 'package:flutter/material.dart';
import '../design_system/tokens.dart';
import '../design_system/typography.dart';

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.width,
    this.icon,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use theme primary color or fallback to near-black for primary buttons
    final primaryColor = theme.primaryColor;
    final backgroundColor = widget.isPrimary
        ? (widget.onPressed == null ? Colors.grey.shade300 : primaryColor)
        : Colors.transparent;
    final textColor = widget.isPrimary
        ? (widget.onPressed == null ? Colors.grey.shade500 : Colors.white)
        : primaryColor;
    final borderColor = widget.isPrimary ? Colors.transparent : primaryColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppTokens.animFast,
        width: widget.width,
        height: AppTokens.s48,
        decoration: BoxDecoration(
          color: widget.isPrimary && _isHovered && widget.onPressed != null
              ? primaryColor.withValues(alpha: 0.9)
              : backgroundColor,
          borderRadius: BorderRadius.circular(AppTokens.r4),
          border: Border.all(
            color: widget.isPrimary ? Colors.transparent : borderColor,
            width: AppTokens.bThin,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(AppTokens.r4),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: textColor, size: 20),
                          const SizedBox(width: AppTokens.s8),
                        ],
                        Text(
                          widget.text,
                          style: AppTypography.buttonText.copyWith(
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const IconActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      color: const Color(0xFF191B1A),
      splashRadius: AppTokens.s24,
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: btn);
    }
    return btn;
  }
}
