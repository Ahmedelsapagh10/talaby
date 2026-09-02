import re

with open('lib/features/shop/presentation/store_header.dart', 'r') as f:
    content = f.read()

replacement = """import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/cubit/cart_state.dart';
import '../../cart/presentation/widgets/cart_checkout_dialog.dart';
import 'widgets/store_header_menu.dart';

class StoreHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onCartPressed;
  final VoidCallback? onAccountPressed;
  final VoidCallback? onWishlistPressed;

  const StoreHeader({
    super.key,
    this.onMenuPressed,
    this.onSearchPressed,
    this.onCartPressed,
    this.onAccountPressed,
    this.onWishlistPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
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
    final bool canPop =
        context.canPop() &&
        GoRouterState.of(context).uri.path != Routes.initialRoute;
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (canPop)
              IconActionButton(
                icon: PhosphorIconsRegular.arrowLeft,
                onPressed: () => context.pop(),
              )
            else
              IconActionButton(
                icon: PhosphorIconsRegular.list,
                onPressed: onMenuPressed ?? () => showStoreMenu(context),
              ),
          ],
        ),
        GestureDetector(
          onTap: () => context.go(Routes.initialRoute),
          child: Text('TALABY', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        ),
        Row(
          children: [
            IconActionButton(
              icon: PhosphorIconsRegular.magnifyingGlass,
              onPressed:
                  onSearchPressed ?? () => context.push(Routes.searchRoute),
            ),
            _buildCartButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final bool canPop =
        context.canPop() &&
        GoRouterState.of(context).uri.path != Routes.initialRoute;
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (canPop) ...[
              IconActionButton(
                icon: PhosphorIconsRegular.arrowLeft,
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: AppTokens.s16),
            ],
            GestureDetector(
              onTap: () => context.go(Routes.initialRoute),
              child: Text('TALABY', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
            ),
          ],
        ),
        Row(
          children: [
            IconActionButton(
              icon: PhosphorIconsRegular.magnifyingGlass,
              onPressed:
                  onSearchPressed ?? () => context.push(Routes.searchRoute),
            ),
            const SizedBox(width: AppTokens.s8),
            IconActionButton(
              icon: PhosphorIconsRegular.user,
              onPressed:
                  onAccountPressed ??
                  () => openProtectedStoreRoute(context, Routes.profileRoute),
            ),
            const SizedBox(width: AppTokens.s8),
            IconActionButton(
              icon: PhosphorIconsRegular.heart,
              onPressed:
                  onWishlistPressed ??
                  () => openProtectedStoreRoute(context, Routes.wishlistRoute),
            ),
            const SizedBox(width: AppTokens.s8),
            _buildCartButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildCartButton(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Badge(
          isLabelVisible: state.itemCount > 0,
          label: Text(state.itemCount.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: theme.colorScheme.error,
          child: IconActionButton(
            icon: PhosphorIconsRegular.bag,
            onPressed: () {
              if (onCartPressed != null) {
                onCartPressed!();
              } else {
                CartCheckoutDialog.show(context);
              }
            },
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
"""

with open('lib/features/shop/presentation/store_header.dart', 'w') as f:
    f.write(replacement)
