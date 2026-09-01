import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/design_system/typography.dart';
import '../../../store/cubit/store_cubit.dart';
import '../../../store/cubit/store_state.dart';
import '../../../store/data/models/store_settings.dart';

class ShopHeroBanner extends StatelessWidget {
  const ShopHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      buildWhen: (previous, current) => previous.settings != current.settings,
      builder: (context, state) {
        final settings = state.settings ?? const StoreSettings();
        if (!settings.bannerEnabled) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.s40),
          child: _BannerContent(settings: settings),
        );
      },
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent({required this.settings});

  final StoreSettings settings;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppTokens.mobileMax;
        final isLarge = constraints.maxWidth >= 900;
        final imageUrl = settings.bannerImageUrl?.trim();
        return Container(
          height: isMobile ? 260 : (isLarge ? 340 : 300),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.r24),
            gradient: _backgroundGradient,
          ),
          child: Stack(
            children: [
              if (imageUrl?.isNotEmpty == true)
                Positioned.fill(
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: imageUrl?.isNotEmpty == true
                        ? _imageOverlayGradient
                        : _backgroundGradient,
                  ),
                ),
              ),
              const PositionedDirectional(
                top: -90,
                end: -50,
                child: _DecorativeCircle(size: 290, opacity: 0.08),
              ),
              const PositionedDirectional(
                bottom: -100,
                end: 130,
                child: _DecorativeCircle(size: 230, opacity: 0.06),
              ),
              PositionedDirectional(
                end: isMobile ? -24 : 56,
                bottom: isMobile ? -22 : -28,
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: isMobile ? 160 : 270,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(
                  isMobile ? AppTokens.s24 : (isLarge ? 48 : AppTokens.s40),
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? constraints.maxWidth - 48 : 610,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TALABY',
                          style: AppTypography.brandTitle.copyWith(
                            color: Colors.white70,
                            fontSize: isLarge ? 22 : 18,
                          ),
                        ),
                        const SizedBox(height: AppTokens.s16),
                        Text(
                          _title(context),
                          style: (isLarge ? AppTypography.h1 : AppTypography.h2)
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppTokens.s12),
                        Text(
                          _subtitle(context),
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _title(BuildContext context) {
    final value = settings.bannerTitleAr;
    return value.trim().isEmpty ? 'shop_banner_title'.tr() : value;
  }

  String _subtitle(BuildContext context) {
    final value = settings.bannerSubtitleAr;
    return value.trim().isEmpty ? 'shop_banner_subtitle'.tr() : value;
  }

  static const _backgroundGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF111827), Color(0xFF31538E)],
  );

  static const _imageOverlayGradient = LinearGradient(
    begin: AlignmentDirectional.centerStart,
    end: AlignmentDirectional.centerEnd,
    colors: [Color(0xE6111827), Color(0x4D111827)],
  );
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
