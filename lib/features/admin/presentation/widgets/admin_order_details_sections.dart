import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/design_system/typography.dart';
import '../../../../../core/widgets/app_buttons.dart';
import '../../../../../core/widgets/pricing.dart';
import '../../../orders/data/models/commerce_order.dart';
import '../../cubit/admin_order_cubit.dart';

class AdminCustomerCard extends StatelessWidget {
  const AdminCustomerCard({super.key, required this.order});

  final CommerceOrder order;

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'customer'.tr(),
    children: [
      Text(order.customerName, style: AppTypography.h4),
      Text(order.phone),
      const SizedBox(height: AppTokens.s16),
      Text('delivery_address'.tr(), style: AppTypography.bodyLarge),
      Text('${order.address}\n${order.city}'),
      if (order.notes?.isNotEmpty == true) ...[
        const SizedBox(height: AppTokens.s16),
        Text('notes'.tr(), style: AppTypography.bodyLarge),
        Text(order.notes!),
      ],
    ],
  );
}

class AdminOrderItems extends StatelessWidget {
  const AdminOrderItems({super.key, required this.order});

  final CommerceOrder order;

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'items'.tr(),
    children: order.items.map((item) {
      final options = [
        item.colorName,
        item.sizeId,
      ].whereType<String>().where((value) => value.isNotEmpty).join(' · ');
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: item.imageUrl?.isNotEmpty == true
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppTokens.r4),
                child: Image.network(
                  item.imageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                ),
              )
            : const Icon(Icons.inventory_2_outlined),
        title: Text(item.productName),
        subtitle: options.isEmpty ? null : Text(options),
        trailing: Text(
          '${item.quantity} × ${(item.unitPrice / 100).toStringAsFixed(2)}',
        ),
      );
    }).toList(),
  );
}

class AdminFinancialCard extends StatelessWidget {
  const AdminFinancialCard({super.key, required this.order});

  final CommerceOrder order;

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'financial_summary'.tr(),
    children: [
      _MoneyRow(label: 'subtotal'.tr(), value: order.subtotal),
      _MoneyRow(label: 'discount'.tr(), value: -order.discountAmount),
      _MoneyRow(label: 'delivery'.tr(), value: order.deliveryFee ?? 0),
      const Divider(),
      _MoneyRow(label: 'total'.tr(), value: order.total, bold: true),
      _MoneyRow(label: 'paid'.tr(), value: order.paidAmount),
      _MoneyRow(label: 'remaining'.tr(), value: order.remainingAmount),
      const SizedBox(height: AppTokens.s16),
      AppButton(
        text: 'update_delivery_fee'.tr(),
        isPrimary: false,
        onPressed: () => _editDeliveryFee(context),
      ),
    ],
  );

  Future<void> _editDeliveryFee(BuildContext context) async {
    final controller = TextEditingController(
      text: ((order.deliveryFee ?? 0) / 100).toStringAsFixed(2),
    );
    final value = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('delivery_fee'.tr()),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('cancel'.tr()),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(controller.text.trim());
              Navigator.pop(
                dialogContext,
                amount == null ? null : (amount * 100).round(),
              );
            },
            child: Text('save'.tr()),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null && context.mounted) {
      await context.read<AdminOrderCubit>().updateDeliveryFee(order.id, value);
    }
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final int value;
  final bool bold;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: bold ? AppTypography.h4 : AppTypography.bodyMedium),
      PriceText(price: value / 100),
    ],
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppTokens.s24),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade200),
      borderRadius: BorderRadius.circular(AppTokens.r8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h4),
        const SizedBox(height: AppTokens.s16),
        ...children,
      ],
    ),
  );
}
