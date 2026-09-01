import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/ux_states.dart';
import '../../catalog/cubit/categories_cubit.dart';
import '../../catalog/cubit/categories_state.dart';
import '../../catalog/cubit/products_cubit.dart';
import '../../catalog/cubit/products_state.dart';
import '../../catalog/data/models/catalog_query.dart';
import '../../catalog/data/models/category.dart';
import '../../catalog/data/models/product.dart';
import 'store_header.dart';
import 'widgets/shop_product_grid.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String? _categoryId;
  bool _newest = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: StoreHeader(
        onMenuPressed: _showCategories,
        onCategoriesPressed: _showCategories,
        onNewArrivalsPressed: () => _select(newest: true),
      ),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          if (state.status == ProductsStatus.loading) {
            return const LoadingState();
          }
          if (state.status == ProductsStatus.failure) {
            return ErrorState(
              message: state.message ?? 'products_load_failed'.tr(),
              onRetry: _load,
            );
          }
          final products = state.products.where(_hasVisibleData).toList();
          return SingleChildScrollView(
            child: ResponsiveContentWidth(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.s16,
                  AppTokens.s32,
                  AppTokens.s16,
                  AppTokens.s64,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryFilters(
                      selectedId: _categoryId,
                      onSelected: (value) => _select(categoryId: value),
                    ),
                    const SizedBox(height: AppTokens.s24),
                    Text(
                      _newest ? 'new_arrivals'.tr() : 'products'.tr(),
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: AppTokens.s24),
                    if (products.isEmpty)
                      SizedBox(
                        height: 300,
                        child: EmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: 'no_products_found'.tr(),
                        ),
                      )
                    else
                      ResponsiveLayout(
                        mobile: ShopProductGrid(
                          products: products,
                          crossAxisCount: 2,
                        ),
                        tablet: ShopProductGrid(
                          products: products,
                          crossAxisCount: 3,
                        ),
                        desktop: ShopProductGrid(
                          products: products,
                          crossAxisCount: 4,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _select({String? categoryId, bool newest = false}) {
    setState(() {
      _categoryId = categoryId;
      _newest = newest;
    });
    _load();
  }

  void _load() {
    context.read<ProductsCubit>().load(
      query: CatalogQuery(
        categoryId: _categoryId,
        sort: _newest ? ProductSort.newest : ProductSort.defaultOrder,
      ),
    );
  }

  Future<void> _showCategories() async {
    final categories = context.read<CategoriesCubit>().state.categories;
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text('all_categories'.tr()),
              onTap: () => Navigator.pop(sheetContext, ''),
            ),
            ...categories.map(
              (category) => ListTile(
                title: Text(category.name),
                onTap: () => Navigator.pop(sheetContext, category.id),
              ),
            ),
          ],
        ),
      ),
    );
    if (mounted && selected != null) {
      _select(categoryId: selected.isEmpty ? null : selected);
    }
  }

  bool _hasVisibleData(Product product) =>
      product.id.isNotEmpty &&
      product.name.trim().isNotEmpty &&
      product.finalPrice > 0 &&
      product.images.any((image) => image.trim().isNotEmpty);
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({required this.selectedId, required this.onSelected});

  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: Text('all'.tr()),
              selected: selectedId == null,
              onSelected: (_) => onSelected(null),
            ),
            ...state.categories.map(
              (Category category) => Padding(
                padding: const EdgeInsets.only(left: AppTokens.s8),
                child: ChoiceChip(
                  label: Text(category.name),
                  selected: selectedId == category.id,
                  onSelected: (_) => onSelected(category.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
