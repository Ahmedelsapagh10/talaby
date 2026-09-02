import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
      border: Border.all(color: Theme.of(context).dividerColor),
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
    contentPadding: const EdgeInsets.symmetric(vertical: AppTokens.s8),
    title: Text('${(payment.claimedAmount / 100).toStringAsFixed(2)} EGP', style: AppTypography.h4),
    subtitle: Text(_statusLabel(payment.status)),
    leading: GestureDetector(
      onTap: () => _showProofImage(context, payment.proofUrl),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTokens.r8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          payment.proofUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(PhosphorIconsRegular.imageBroken),
        ),
      ),
    ),
    trailing: payment.status == PaymentRecordStatus.proofSubmitted
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(PhosphorIconsRegular.xCircle),
                color: Theme.of(context).colorScheme.error,
                tooltip: 'reject'.tr(),
                onPressed: () => _review(context, false),
              ),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.checkCircle),
                color: Colors.green,
                tooltip: 'approve'.tr(),
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

  void _showProofImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.r16),
        ),
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(PhosphorIconsRegular.imageBroken, size: 64),
                ),
              ),
            ),
            Positioned(
              top: AppTokens.s16,
              right: AppTokens.s16,
              child: IconButton(
                icon: const Icon(PhosphorIconsRegular.xCircle, size: 32),
                color: Colors.white,
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(PaymentRecordStatus status) => switch (status) {
  PaymentRecordStatus.proofSubmitted => 'proof_submitted'.tr(),
  PaymentRecordStatus.approved => 'approved'.tr(),
  PaymentRecordStatus.rejected => 'rejected'.tr(),
};
