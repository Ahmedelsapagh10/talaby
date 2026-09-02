import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_fields.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/ux_states.dart';
import '../../catalog/data/models/product.dart';
import '../cubit/admin_products_cubit.dart';
import '../cubit/admin_products_state.dart';
import 'widgets/admin_product_tile.dart';
import 'widgets/admin_products_table.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminProductsCubit, AdminProductsState>(
      listener: (context, state) {
        if (state.status == AdminProductsStatus.failure) {
          AppToast.error(
            context,
            state.message ?? 'product_operation_failed'.tr(),
          );
        }
      },
      builder: (context, state) => Stack(
        children: [
          ResponsiveContentWidth(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTokens.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  const SizedBox(height: AppTokens.s24),
                  AppTextField(
                    label: '',
                    hint: 'search_products_admin'.tr(),
                    onChanged: _search,
                  ),
                  const SizedBox(height: AppTokens.s24),
                  _content(context, state),
                ],
              ),
            ),
          ),
          if (state.isUpdating)
            Positioned.fill(
              child: ColoredBox(
                color: Theme.of(
                  context,
                ).colorScheme.scrim.withValues(alpha: 0.18),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('products'.tr(), style: Theme.of(context).textTheme.headlineMedium),
      AppButton(
        text: 'new_product'.tr(),
        icon: PhosphorIconsRegular.plus,
        onPressed: () => context.push('/admin/products/new'),
      ),
    ],
  );

  Widget _content(BuildContext context, AdminProductsState state) {
    if (state.status == AdminProductsStatus.loading && state.products.isEmpty) {
      return const SizedBox(height: 340, child: LoadingState());
    }
    if (state.status == AdminProductsStatus.failure && state.products.isEmpty) {
      return SizedBox(
        height: 340,
        child: ErrorState(
          message: 'load_products_failed'.tr(),
          onRetry: context.read<AdminProductsCubit>().load,
        ),
      );
    }
    if (state.products.isEmpty) {
      return SizedBox(
        height: 320,
        child: EmptyState(
          icon: PhosphorIconsRegular.package,
          title: 'no_products_found'.tr(),
        ),
      );
    }
    return Column(
      children: [
        ResponsiveLayout(
          mobile: Column(
            children: state.products
                .map(
                  (product) => AdminProductTile(
                    product: product,
                    onDelete: () => _delete(product),
                  ),
                )
                .toList(),
          ),
          desktop: AdminProductsTable(
            products: state.products,
            onDelete: _delete,
          ),
        ),
        if (state.hasMore) ...[
          const SizedBox(height: AppTokens.s16),
          AppButton(
            text: 'load_more'.tr(),
            isPrimary: false,
            onPressed: context.read<AdminProductsCubit>().loadMore,
          ),
        ],
      ],
    );
  }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => context.read<AdminProductsCubit>().load(query: value),
    );
  }

  Future<void> _delete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('delete_product_title'.tr()),
        content: Text(
          'delete_product_message'.tr(namedArgs: {'name': product.name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AdminProductsCubit>().delete(product.id);
    }
  }
}
