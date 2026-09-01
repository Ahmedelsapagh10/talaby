import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

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
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: () => context.push('/admin/products/${product.id}/edit'),
      leading: product.images.isEmpty
          ? const Icon(Icons.inventory_2_outlined)
          : Image.network(
              product.images.first,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
      title: Text(product.name),
      subtitle: Text(
        '${(product.finalPrice / 100).toStringAsFixed(2)} EGP · '
        '${'stock_value'.tr(namedArgs: {'value': '${product.stock}'})}',
      ),
      trailing: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Switch(
            value: product.featured,
            onChanged: (value) => context
                .read<AdminProductsCubit>()
                .setFeatured(product.id, value),
          ),
          Switch(
            value: product.active,
            onChanged: (value) =>
                context.read<AdminProductsCubit>().setActive(product.id, value),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    ),
  );
}
