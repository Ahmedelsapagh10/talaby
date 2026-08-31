import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';

class StoreHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onCartPressed;
  final VoidCallback? onAccountPressed;

  const StoreHeader({
    super.key,
    this.onMenuPressed,
    this.onSearchPressed,
    this.onCartPressed,
    this.onAccountPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        bottom: false,
        child: ResponsiveContentWidth(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
            child: SizedBox(
              height: 64,
              child: ResponsiveLayout(
                mobile: _buildMobile(context),
                desktop: _buildDesktop(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconActionButton(icon: Icons.menu, onPressed: onMenuPressed),
        Text('TALABY', style: AppTypography.h3),
        Row(
          children: [
            IconActionButton(icon: Icons.search, onPressed: onSearchPressed),
            IconActionButton(
              icon: Icons.shopping_bag_outlined,
              onPressed: onCartPressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('TALABY', style: AppTypography.h3),
            const SizedBox(width: AppTokens.s32),
            TextButton(
              onPressed: () {},
              child: Text('Categories', style: AppTypography.buttonText),
            ),
            TextButton(
              onPressed: () {},
              child: Text('New Arrivals', style: AppTypography.buttonText),
            ),
          ],
        ),
        Row(
          children: [
            IconActionButton(icon: Icons.search, onPressed: onSearchPressed),
            const SizedBox(width: AppTokens.s8),
            IconActionButton(
              icon: Icons.person_outline,
              onPressed: onAccountPressed,
            ),
            const SizedBox(width: AppTokens.s8),
            IconActionButton(icon: Icons.favorite_border, onPressed: () {}),
            const SizedBox(width: AppTokens.s8),
            IconActionButton(
              icon: Icons.shopping_bag_outlined,
              onPressed: onCartPressed,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
