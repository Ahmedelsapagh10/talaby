import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/widgets/ux_states.dart';
import '../../catalog/cubit/products_cubit.dart';
import '../../catalog/cubit/products_state.dart';
import '../../catalog/data/models/catalog_query.dart';
import 'store_header.dart';
import 'widgets/shop_product_grid.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.trim().length >= 2) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _search(widget.initialQuery),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StoreHeader(),
      body: ResponsiveContentWidth(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.s24),
          child: Column(
            children: [
              SearchBar(
                controller: _controller,
                autoFocus: true,
                hintText: 'search_products'.tr(),
                leading: const Icon(Icons.search),
                onChanged: _scheduleSearch,
                onSubmitted: _search,
              ),
              const SizedBox(height: AppTokens.s24),
              Expanded(
                child: BlocBuilder<ProductsCubit, ProductsState>(
                  builder: (context, state) => _results(context, state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _results(BuildContext context, ProductsState state) {
    if (_controller.text.trim().length < 2) {
      return EmptyState(icon: Icons.search, title: 'search_min_chars'.tr());
    }
    if (state.status == ProductsStatus.loading) return const LoadingState();
    if (state.status == ProductsStatus.failure) {
      return ErrorState(
        message: 'search_failed'.tr(),
        onRetry: () => _search(_controller.text),
      );
    }
    if (state.products.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'no_matching_products'.tr(),
      );
    }
    return SingleChildScrollView(
      child: ResponsiveLayout(
        mobile: ShopProductGrid(products: state.products, crossAxisCount: 2),
        tablet: ShopProductGrid(products: state.products, crossAxisCount: 3),
        desktop: ShopProductGrid(products: state.products, crossAxisCount: 4),
      ),
    );
  }

  void _scheduleSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  void _search(String value) {
    final query = value.trim();
    if (query.length < 2) {
      setState(() {});
      return;
    }
    context.read<ProductsCubit>().load(query: CatalogQuery(searchQuery: query));
  }
}
