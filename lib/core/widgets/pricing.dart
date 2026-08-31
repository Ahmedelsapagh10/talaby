import 'package:flutter/material.dart';
import '../design_system/tokens.dart';
import '../design_system/typography.dart';

class PriceText extends StatelessWidget {
  final double price;
  final String currency;
  final bool isLarge;

  const PriceText({
    super.key,
    required this.price,
    this.currency = 'EGP',
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '${price.toStringAsFixed(2)} $currency',
      style: isLarge ? AppTypography.priceLarge : AppTypography.priceMedium,
    );
  }
}

class DiscountPrice extends StatelessWidget {
  final double originalPrice;
  final double discountedPrice;
  final String currency;

  const DiscountPrice({
    super.key,
    required this.originalPrice,
    required this.discountedPrice,
    this.currency = 'EGP',
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: AppTokens.s8,
      children: [
        PriceText(price: discountedPrice, currency: currency, isLarge: true),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 2,
          ), // small adjustment for baseline alignment visually
          child: Text(
            '${originalPrice.toStringAsFixed(2)} $currency',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.grey.shade500,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ),
      ],
    );
  }
}
