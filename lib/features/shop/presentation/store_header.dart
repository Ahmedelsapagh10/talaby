import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../cart/cubit/cart_cubit.dart';
import '../../cart/cubit/cart_state.dart';

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
    final bool canPop = context.canPop() && GoRouterState.of(context).uri.path != Routes.initialRoute;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (canPop)
              IconActionButton(
                icon: Icons.arrow_back,
                onPressed: () => context.pop(),
              )
            else
              IconActionButton(icon: Icons.menu, onPressed: onMenuPressed),
          ],
        ),
        GestureDetector(
          onTap: () => context.go(Routes.initialRoute),
          child: Text('TALABY', style: AppTypography.brandTitle),
        ),
        Row(
          children: [
            _buildLanguageButton(context),
            IconActionButton(icon: Icons.search, onPressed: onSearchPressed),
            _buildCartButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    final bool canPop = context.canPop() && GoRouterState.of(context).uri.path != Routes.initialRoute;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (canPop) ...[
              IconActionButton(
                icon: Icons.arrow_back,
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: AppTokens.s16),
            ],
            GestureDetector(
              onTap: () => context.go(Routes.initialRoute),
              child: Text('TALABY', style: AppTypography.brandTitle),
            ),
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
            _buildLanguageButton(context),
            const SizedBox(width: AppTokens.s8),
            IconActionButton(icon: Icons.search, onPressed: onSearchPressed),
            const SizedBox(width: AppTokens.s8),
            IconActionButton(
              icon: Icons.person_outline,
              onPressed: onAccountPressed,
            ),
            const SizedBox(width: AppTokens.s8),
            IconActionButton(icon: Icons.favorite_border, onPressed: () {}),
            const SizedBox(width: AppTokens.s8),
            _buildCartButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildCartButton(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Badge(
          isLabelVisible: state.itemCount > 0,
          label: Text(state.itemCount.toString()),
          backgroundColor: Colors.red,
          child: IconActionButton(
            icon: Icons.shopping_bag_outlined,
            onPressed: () {
              if (onCartPressed != null) {
                onCartPressed!();
              } else {
                context.push(Routes.cartRoute);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildLanguageButton(BuildContext context) {
    return IconActionButton(
      icon: Icons.language,
      onPressed: () {
        final newLocale = context.locale.languageCode == 'ar'
            ? const Locale('en')
            : const Locale('ar');
        context.setLocale(newLocale);
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
