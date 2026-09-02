import 'package:flutter/material.dart';
import 'tokens.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= AppTokens.mobileMax;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > AppTokens.mobileMax &&
      MediaQuery.of(context).size.width <= AppTokens.tabletMax;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > AppTokens.tabletMax;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > AppTokens.tabletMax) {
          return desktop;
        }
        if (constraints.maxWidth > AppTokens.mobileMax && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

class ResponsiveContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveContentWidth({
    super.key,
    required this.child,
    this.maxWidth = AppTokens.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Consistent page gutters that preserve useful tablet width and add breathing
/// room on wide desktop layouts.
class ResponsiveGutter extends StatelessWidget {
  const ResponsiveGutter({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth > AppTokens.tabletMax
            ? AppTokens.s32
            : constraints.maxWidth > AppTokens.mobileMax
            ? AppTokens.s24
            : AppTokens.s16;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          child: child,
        );
      },
    );
  }
}
