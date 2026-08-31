import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/badges.dart';
import '../../../../core/widgets/pricing.dart';
import '../../../../core/widgets/app_text_fields.dart';

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTokens.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Orders', style: AppTypography.h2),
          const SizedBox(height: AppTokens.s32),
          Row(
            children: [
              const Expanded(
                flex: 2,
                child: AppTextField(
                  label: '',
                  hint: 'Search by order number or customer...',
                ),
              ),
              const SizedBox(width: AppTokens.s16),
              Expanded(
                flex: 1,
                child: AppDropdown<String>(
                  label: '',
                  value: 'All',
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s24),
          _buildDesktopTable(),
        ],
      ),
    );
  }

  Widget _buildDesktopTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(AppTokens.r8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
          dataTextStyle: AppTypography.bodyMedium,
          columns: const [
            DataColumn(label: Text('Order')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Order Status')),
            DataColumn(label: Text('Payment')),
            DataColumn(label: Text('Date')),
          ],
          rows: List.generate(10, (index) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    '#ORD-1045$index',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const DataCell(Text('Ahmed Elsapagh\n01012345678')),
                const DataCell(PriceText(price: 598.00)),
                DataCell(StatusBadge.warning('Pending')),
                DataCell(StatusBadge.error('Unpaid')),
                const DataCell(Text('Oct 24, 2026')),
              ],
            );
          }),
        ),
      ),
    );
  }
}
