import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../catalog/data/models/product.dart';
import '../../cubit/admin_products_cubit.dart';

class AdminProductTile extends StatelessWidget {
  const AdminProductTile({
    super.key,
    required this.product,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTokens.s12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/admin/products/${product.id}/edit'),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.s16),
          child: Column(
            children: [
              Row(
                children: [
                  AdminProductThumbnail(product: product, size: 64),
                  const SizedBox(width: AppTokens.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTokens.s4),
                        Text(
                          '${(product.finalPrice / 100).toStringAsFixed(2)} EGP · '
                          '${'stock_value'.tr(namedArgs: {'value': '${product.stock}'})}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.trash),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: onDelete,
                  ),
                ],
              ),
              const Divider(height: AppTokens.s24),
              Row(
                children: [
                  Expanded(
                    child: _Toggle(
                      label: 'featured'.tr(),
                      value: product.featured,
                      onChanged: (value) => context
                          .read<AdminProductsCubit>()
                          .setFeatured(product.id, value),
                    ),
                  ),
                  const SizedBox(width: AppTokens.s16),
                  Expanded(
                    child: _Toggle(
                      label: 'active'.tr(),
                      value: product.active,
                      onChanged: (value) => context
                          .read<AdminProductsCubit>()
                          .setActive(product.id, value),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminProductThumbnail extends StatelessWidget {
  const AdminProductThumbnail({
    super.key,
    required this.product,
    this.size = 48,
  });

  final Product product;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTokens.r8),
      ),
      child: product.images.isEmpty
          ? const Icon(PhosphorIconsRegular.package)
          : CachedNetworkImage(
              imageUrl: product.images.first,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) =>
                  const Icon(PhosphorIconsRegular.imageBroken),
            ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
