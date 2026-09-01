import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/ux_states.dart';
import '../../catalog/data/models/category.dart';
import '../cubit/admin_categories_cubit.dart';
import '../cubit/admin_categories_state.dart';

class AdminCategoriesPage extends StatelessWidget {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCategoriesCubit, AdminCategoriesState>(
      builder: (context, state) => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppTokens.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('categories'.tr(), style: AppTypography.h2),
                    AppButton(
                      text: 'add_category'.tr(),
                      icon: Icons.add,
                      onPressed: () => _edit(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.s24),
                _content(context, state),
              ],
            ),
          ),
          if (state.isUpdating)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, AdminCategoriesState state) {
    if (state.status == AdminCategoriesStatus.loading) {
      return const SizedBox(height: 340, child: LoadingState());
    }
    if (state.status == AdminCategoriesStatus.failure) {
      return SizedBox(
        height: 340,
        child: ErrorState(
          message: state.message ?? 'load_categories_failed'.tr(),
          onRetry: context.read<AdminCategoriesCubit>().load,
        ),
      );
    }
    if (state.categories.isEmpty) {
      return SizedBox(
        height: 300,
        child: EmptyState(
          icon: Icons.category_outlined,
          title: 'no_categories'.tr(),
        ),
      );
    }
    return Column(
      children: state.categories.map((category) {
        return Card(
          child: ListTile(
            onTap: () => _edit(context, category),
            leading: category.imageUrl?.isNotEmpty == true
                ? Image.network(
                    category.imageUrl!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.category_outlined),
            title: Text(category.name),
            subtitle: Text(
              'sort_order_value'.tr(
                namedArgs: {'value': '${category.sortOrder}'},
              ),
            ),
            trailing: Switch(
              value: category.active,
              onChanged: (value) => context
                  .read<AdminCategoriesCubit>()
                  .setActive(category.id, value),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _edit(BuildContext context, [Category? category]) async {
    final name = TextEditingController(text: category?.name);
    final image = TextEditingController(text: category?.imageUrl);
    final order = TextEditingController(
      text: (category?.sortOrder ?? 0).toString(),
    );
    var active = category?.active ?? true;
    final result = await showDialog<Category>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: Text(
            (category == null ? 'add_category_title' : 'edit_category_title')
                .tr(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: InputDecoration(labelText: 'name'.tr()),
              ),
              TextField(
                controller: image,
                decoration: InputDecoration(labelText: 'image_url'.tr()),
              ),
              TextField(
                controller: order,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'sort_order'.tr()),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('active'.tr()),
                value: active,
                onChanged: (value) => setDialogState(() => active = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty) return;
                Navigator.pop(
                  dialogContext,
                  Category(
                    id: category?.id ?? '',
                    name: name.text.trim(),
                    imageUrl: image.text.trim().isEmpty
                        ? null
                        : image.text.trim(),
                    active: active,
                    sortOrder: int.tryParse(order.text) ?? 0,
                  ),
                );
              },
              child: Text('save'.tr()),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    image.dispose();
    order.dispose();
    if (result != null && context.mounted) {
      await context.read<AdminCategoriesCubit>().save(result);
    }
  }
}
