import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/widgets/pricing.dart';
import '../../../catalog/data/models/product.dart';
import '../../cubit/admin_products_cubit.dart';
import 'admin_product_tile.dart';
import 'admin_table.dart';

enum _ProductAction { edit, delete }

class AdminProductsTable extends StatelessWidget {
  const AdminProductsTable({
    super.key,
    required this.products,
    required this.onDelete,
  });

  final List<Product> products;
  final ValueChanged<Product> onDelete;

  @override
  Widget build(BuildContext context) {
    return AdminTable(
      columns: [
        DataColumn(label: Text('products'.tr())),
        DataColumn(label: Text('price_egp'.tr())),
        DataColumn(label: Text('stock'.tr())),
        DataColumn(label: Text('featured'.tr())),
        DataColumn(label: Text('active'.tr())),
        const DataColumn(label: SizedBox.shrink()),
      ],
      rows: products
          .map(
            (product) => DataRow(
              onSelectChanged: (_) => _edit(context, product),
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AdminProductThumbnail(product: product),
                      const SizedBox(width: AppTokens.s12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(PriceText(price: product.finalPrice / 100)),
                DataCell(Text('${product.stock}')),
                DataCell(
                  Switch(
                    value: product.featured,
                    onChanged: (value) => context
                        .read<AdminProductsCubit>()
                        .setFeatured(product.id, value),
                  ),
                ),
                DataCell(
                  Switch(
                    value: product.active,
                    onChanged: (value) => context
                        .read<AdminProductsCubit>()
                        .setActive(product.id, value),
                  ),
                ),
                DataCell(_actions(context, product)),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _actions(BuildContext context, Product product) {
    return PopupMenuButton<_ProductAction>(
      icon: const Icon(PhosphorIconsRegular.dotsThreeVertical),
      onSelected: (action) {
        switch (action) {
          case _ProductAction.edit:
            _edit(context, product);
          case _ProductAction.delete:
            onDelete(product);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _ProductAction.edit,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(PhosphorIconsRegular.pencilSimple),
            title: Text('edit_product'.tr()),
          ),
        ),
        PopupMenuItem(
          value: _ProductAction.delete,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              PhosphorIconsRegular.trash,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text('delete'.tr()),
          ),
        ),
      ],
    );
  }

  void _edit(BuildContext context, Product product) =>
      context.push('/admin/products/${product.id}/edit');
}
