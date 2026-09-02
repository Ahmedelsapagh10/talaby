import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/design_system/tokens.dart';
import '../../../../../core/design_system/typography.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/social_sign_in_dialog.dart';
import '../../../catalog/data/models/product.dart';
import '../../../reviews/cubit/reviews_cubit.dart';
import '../../../reviews/cubit/reviews_state.dart';

class ProductReviewsSection extends StatelessWidget {
  const ProductReviewsSection({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewsCubit, ReviewsState>(
      listener: (context, state) {
        if (state.submitted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('review_pending'.tr())));
        }
        if (state.status == ReviewsStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text((state.message ?? 'review_submit_failed').tr()),
            ),
          );
        }
      },
      builder: (context, state) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTokens.s24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(AppTokens.r16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('reviews'.tr(), style: AppTypography.h3)),
                TextButton.icon(
                  onPressed: state.status == ReviewsStatus.submitting
                      ? null
                      : () => _writeReview(context),
                  icon: const Icon(PhosphorIconsRegular.notePencil),
                  label: Text('write_review'.tr()),
                ),
              ],
            ),
            Text(
              '${product.averageRating.toStringAsFixed(1)} ★ · ${product.reviewsCount} reviews',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppTokens.s16),
            if (state.status == ReviewsStatus.loading)
              const Center(child: CircularProgressIndicator())
            else if (state.reviews.isEmpty)
              Text('no_approved_reviews'.tr())
            else
              ...state.reviews.map(
                (review) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${review.displayName} · ${review.rating}/5 ★'),
                  subtitle: Text(review.feedback),
                  trailing: review.createdAt == null
                      ? null
                      : Text(DateFormat.yMMMd().format(review.createdAt!)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _writeReview(BuildContext context) async {
    if (!await requireSocialSignIn(context) || !context.mounted) return;
    final feedback = TextEditingController();
    var rating = 5;
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: Text('write_review'.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: rating,
                decoration: InputDecoration(labelText: 'rating'.tr()),
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1} stars'),
                  ),
                ),
                onChanged: (value) => setDialogState(() => rating = value ?? 5),
              ),
              TextField(
                controller: feedback,
                maxLines: 4,
                decoration: InputDecoration(labelText: 'feedback'.tr()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('cancel'.tr()),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, feedback.text.trim().isNotEmpty),
              child: Text('submit'.tr()),
            ),
          ],
        ),
      ),
    );
    final text = feedback.text.trim();
    feedback.dispose();
    if (submitted != true || !context.mounted) return;
    final session = context.read<AuthCubit>().state.session!;
    await context.read<ReviewsCubit>().submit(
      productId: product.id,
      productName: product.name,
      customerId: session.uid,
      displayName: session.displayName ?? session.email ?? 'Customer',
      rating: rating,
      feedback: text,
    );
  }
}
