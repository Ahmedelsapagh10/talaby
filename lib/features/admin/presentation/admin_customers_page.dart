import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_text_fields.dart';
import '../../../../core/widgets/ux_states.dart';
import '../cubit/admin_customers_cubit.dart';
import '../cubit/admin_customers_state.dart';

class AdminCustomersPage extends StatefulWidget {
  const AdminCustomersPage({super.key});

  @override
  State<AdminCustomersPage> createState() => _AdminCustomersPageState();
}

class _AdminCustomersPageState extends State<AdminCustomersPage> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCustomersCubit, AdminCustomersState>(
      builder: (context, state) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('customers'.tr(), style: AppTypography.h2),
            const SizedBox(height: AppTokens.s24),
            AppTextField(
              label: '',
              hint: 'search_customers'.tr(),
              onChanged: _search,
            ),
            const SizedBox(height: AppTokens.s24),
            _content(context, state),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, AdminCustomersState state) {
    if (state.status == AdminCustomersStatus.loading &&
        state.customers.isEmpty) {
      return const SizedBox(height: 340, child: LoadingState());
    }
    if (state.status == AdminCustomersStatus.failure &&
        state.customers.isEmpty) {
      return SizedBox(
        height: 340,
        child: ErrorState(
          message: state.message ?? 'load_failed'.tr(),
          onRetry: context.read<AdminCustomersCubit>().load,
        ),
      );
    }
    if (state.customers.isEmpty) {
      return SizedBox(
        height: 300,
        child: EmptyState(
          icon: Icons.people_outline,
          title: 'no_customers_found'.tr(),
        ),
      );
    }
    return Column(
      children: [
        ...state.customers.map(
          (customer) => Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(
                customer.name.isEmpty ? 'unnamed_customer'.tr() : customer.name,
              ),
              subtitle: Text(
                '${customer.phone}\n${customer.defaultCity ?? ''}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'orders_count'.tr(
                      namedArgs: {'count': '${customer.orderCount}'},
                    ),
                  ),
                  Text(
                    customer.lastOrderAt == null
                        ? 'no_orders'.tr()
                        : DateFormat.yMMMd().format(customer.lastOrderAt!),
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (state.hasMore) ...[
          const SizedBox(height: AppTokens.s16),
          AppButton(
            text: 'load_more'.tr(),
            isPrimary: false,
            onPressed: context.read<AdminCustomersCubit>().loadMore,
          ),
        ],
      ],
    );
  }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => context.read<AdminCustomersCubit>().load(query: value),
    );
  }
}
