import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/themes/app_colors_extension.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import 'admin_section.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.child,
    this.section = AdminSection.overview,
  });

  final Widget child;
  final AdminSection section;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ResponsiveLayout(
        mobile: _MobileAdminLayout(section: section, child: child),
        desktop: Row(
          children: [
            _AdminSidebar(section: section),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _MobileAdminLayout extends StatelessWidget {
  const _MobileAdminLayout({required this.child, required this.section});

  final Widget child;
  final AdminSection section;

  @override
  Widget build(BuildContext context) {
    final index = section.isMore ? 3 : section.index.clamp(0, 2);
    return Column(
      children: [
        Expanded(child: child),
        NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (value) => _onSelected(context, value),
          destinations: [
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.squaresFour),
              label: 'overview'.tr(),
            ),
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.shoppingBag),
              label: 'orders'.tr(),
            ),
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.package),
              label: 'products'.tr(),
            ),
            NavigationDestination(
              icon: Icon(PhosphorIconsRegular.dotsThree),
              label: 'more'.tr(),
            ),
          ],
        ),
      ],
    );
  }

  void _onSelected(BuildContext context, int value) {
    if (value < 3) {
      context.go(AdminSection.values[value].route);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...AdminSection.values.where((item) => item.isMore).map((item) {
              return ListTile(
                leading: Icon(_iconFor(item)),
                title: Text(_labelFor(item)),
                selected: item == section,
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.go(item.route);
                },
              );
            }),
            ListTile(
              leading: Icon(PhosphorIconsRegular.storefront),
              title: Text('view_store'.tr()),
              onTap: () {
                Navigator.pop(sheetContext);
                context.go(Routes.initialRoute);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({required this.section});

  final AdminSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.extension<AppColorsExtension>() ??
        (theme.brightness == Brightness.dark
            ? AppColorsExtension.dark
            : AppColorsExtension.light);
    final sidebarColor = theme.brightness == Brightness.light
        ? colors.textPrimary
        : colors.surface;
    final textColor = colors.onPrimaryBackground;
    final mutedTextColor = textColor.withValues(alpha: 0.68);
    final selectedTileColor = colors.primary.withValues(alpha: 0.45);

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: sidebarColor,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTokens.s32),
            child: Text(
              'admin_title'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...AdminSection.values.map((item) {
            final selected = section == item;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.s16,
                vertical: 2,
              ),
              child: AnimatedContainer(
                duration: AppTokens.animFast,
                decoration: BoxDecoration(
                  color: selected ? selectedTileColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTokens.r12),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: AppTokens.animFast,
                      width: 4,
                      height: selected ? 32 : 0,
                      decoration: BoxDecoration(
                        color: colors.accent,
                        borderRadius: BorderRadius.circular(AppTokens.rMax),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        leading: Icon(
                          _iconFor(item),
                          color: selected ? textColor : mutedTextColor,
                        ),
                        title: Text(
                          _labelFor(item),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: selected ? textColor : mutedTextColor,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        selected: selected,
                        onTap: () => context.go(item.route),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.s12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.s16,
              vertical: AppTokens.s16,
            ),
            child: ListTile(
              leading: Icon(
                PhosphorIconsRegular.storefront,
                color: mutedTextColor,
              ),
              title: Text(
                'view_store'.tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: mutedTextColor,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.r12),
              ),
              onTap: () => context.go(Routes.initialRoute),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTokens.s16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _labelFor(AdminSection section) => switch (section) {
  AdminSection.overview => 'overview',
  AdminSection.orders => 'orders',
  AdminSection.products => 'products',
  AdminSection.categories => 'categories',
  AdminSection.customers => 'customers',
  AdminSection.reviews => 'reviews',
  AdminSection.settings => 'settings',
}.tr();

IconData _iconFor(AdminSection section) => switch (section) {
  AdminSection.overview => PhosphorIconsRegular.squaresFour,
  AdminSection.orders => PhosphorIconsRegular.shoppingBag,
  AdminSection.products => PhosphorIconsRegular.package,
  AdminSection.categories => PhosphorIconsRegular.tag,
  AdminSection.customers => PhosphorIconsRegular.users,
  AdminSection.reviews => PhosphorIconsRegular.star,
  AdminSection.settings => PhosphorIconsRegular.gear,
};
