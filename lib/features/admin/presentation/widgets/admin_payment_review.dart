import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/design_system/typography.dart';
import '../../../orders/data/models/commerce_order.dart';
import '../../../orders/data/models/payment_record.dart';
import '../../../orders/data/models/payment_status.dart';
import '../../cubit/admin_order_cubit.dart';

class AdminPaymentReview extends StatelessWidget {
  const AdminPaymentReview({super.key, required this.order});

  final CommerceOrder order;

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
        Text('payment_proofs'.tr(), style: AppTypography.h4),
        const SizedBox(height: AppTokens.s16),
        if (order.payments.isEmpty)
          Text('no_payment_proofs'.tr())
        else
          ...order.payments.map(
            (payment) => _PaymentTile(order: order, payment: payment),
          ),
      ],
    ),
  );
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.order, required this.payment});

  final CommerceOrder order;
  final PaymentRecord payment;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text('${(payment.claimedAmount / 100).toStringAsFixed(2)} EGP'),
    subtitle: Text(_statusLabel(payment.status)),
    leading: IconButton(
      icon: const Icon(Icons.receipt_long_outlined),
      onPressed: () => launchUrl(Uri.parse(payment.proofUrl)),
    ),
    trailing: payment.status == PaymentRecordStatus.proofSubmitted
        ? Wrap(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _review(context, false),
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => _review(context, true),
              ),
            ],
          )
        : null,
  );

  Future<void> _review(BuildContext context, bool approved) {
    return context.read<AdminOrderCubit>().reviewPayment(
      orderId: order.id,
      paymentId: payment.id,
      approved: approved,
      confirmedAmount: approved ? payment.claimedAmount : null,
    );
  }
}

String _statusLabel(PaymentRecordStatus status) => switch (status) {
  PaymentRecordStatus.proofSubmitted => 'proof_submitted'.tr(),
  PaymentRecordStatus.approved => 'approved'.tr(),
  PaymentRecordStatus.rejected => 'rejected'.tr(),
};
