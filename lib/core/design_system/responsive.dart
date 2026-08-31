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

  const ResponsiveContentWidth({
    super.key,
    required this.child,
    this.maxWidth = AppTokens.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
