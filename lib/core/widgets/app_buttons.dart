import 'package:flutter/material.dart';
import '../../config/themes/app_colors_extension.dart';
import '../design_system/tokens.dart';

enum AppButtonVariant { primary, secondary, accent }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final AppButtonVariant? variant;
  final bool isLoading;
  final double? width;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.variant,
    this.isLoading = false,
    this.width,
    this.icon,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.extension<AppColorsExtension>() ??
        (theme.brightness == Brightness.dark
            ? AppColorsExtension.dark
            : AppColorsExtension.light);
    final variant =
        widget.variant ??
        (widget.isPrimary
            ? AppButtonVariant.primary
            : AppButtonVariant.secondary);
    final enabled = widget.onPressed != null && !widget.isLoading;
    final (baseBackground, baseForeground, borderColor) = switch (variant) {
      AppButtonVariant.primary => (
        colors.primary,
        Colors.white,
        colors.primary,
      ),
      AppButtonVariant.secondary => (
        colors.surfaceMuted,
        colors.textPrimary,
        colors.border,
      ),
      AppButtonVariant.accent => (colors.accent, Colors.white, colors.accent),
    };
    final backgroundColor = enabled
        ? baseBackground
        : colors.surfaceMuted.withValues(alpha: 0.7);
    final textColor = enabled
        ? baseForeground
        : colors.textSecondary.withValues(alpha: 0.7);
    final hoverOverlay = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final resolvedBackground = _isHovered && enabled
        ? Color.alphaBlend(hoverOverlay, backgroundColor)
        : backgroundColor;

    return Semantics(
      button: true,
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1,
          duration: AppTokens.animFast,
          child: AnimatedContainer(
            duration: AppTokens.animFast,
            width: widget.width,
            height: AppTokens.s48,
            decoration: BoxDecoration(
              color: resolvedBackground,
              borderRadius: BorderRadius.circular(AppTokens.r12),
              border: Border.all(
                color: enabled ? borderColor : colors.border,
                width: AppTokens.bThin,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? widget.onPressed : null,
                onHighlightChanged: (value) =>
                    setState(() => _isPressed = value),
                borderRadius: BorderRadius.circular(AppTokens.r12),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              textColor,
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTokens.s12,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(widget.icon, color: textColor, size: 20),
                                  const SizedBox(width: AppTokens.s8),
                                ],
                                Text(
                                  widget.text,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
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
      color: Theme.of(context).colorScheme.onSurface,
      splashRadius: AppTokens.s24,
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip, child: btn);
    }
    return btn;
  }
}
