import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../auth/cubit/auth_cubit.dart';
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
      backgroundColor: Colors.white,
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
              icon: const Icon(Icons.dashboard_outlined),
              label: 'overview'.tr(),
            ),
            NavigationDestination(
              icon: const Icon(Icons.shopping_bag_outlined),
              label: 'orders'.tr(),
            ),
            NavigationDestination(
              icon: const Icon(Icons.inventory_2_outlined),
              label: 'products'.tr(),
            ),
            NavigationDestination(
              icon: const Icon(Icons.more_horiz),
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
              leading: const Icon(Icons.logout),
              title: Text('sign_out'.tr()),
              onTap: () {
                final authCubit = context.read<AuthCubit>();
                Navigator.pop(sheetContext);
                authCubit.logout();
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
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTokens.s24),
            child: Text('admin_title'.tr(), style: AppTypography.h4),
          ),
          ...AdminSection.values.map(
            (item) => ListTile(
              leading: Icon(_iconFor(item)),
              title: Text(_labelFor(item)),
              selected: section == item,
              selectedTileColor: Colors.grey.shade200,
              onTap: () => context.go(item.route),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTokens.s24,
              ),
            ),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('sign_out'.tr()),
            onTap: () => context.read<AuthCubit>().logout(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTokens.s24,
            ),
          ),
          const SizedBox(height: AppTokens.s16),
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
  AdminSection.overview => Icons.dashboard_outlined,
  AdminSection.orders => Icons.shopping_bag_outlined,
  AdminSection.products => Icons.inventory_2_outlined,
  AdminSection.categories => Icons.category_outlined,
  AdminSection.customers => Icons.people_outline,
  AdminSection.reviews => Icons.star_outline,
  AdminSection.settings => Icons.settings_outlined,
};
