import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/design_system/tokens.dart';
import '../../../../core/design_system/typography.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/ux_states.dart';
import '../../reviews/data/models/review.dart';
import '../cubit/admin_reviews_cubit.dart';
import '../cubit/admin_reviews_state.dart';

class AdminReviewsPage extends StatelessWidget {
  const AdminReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminReviewsCubit, AdminReviewsState>(
      builder: (context, state) => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppTokens.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('reviews'.tr(), style: AppTypography.h2),
                const SizedBox(height: AppTokens.s20),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 0, label: Text('all_status'.tr())),
                    ButtonSegment(value: 1, label: Text('pending'.tr())),
                    ButtonSegment(value: 2, label: Text('approved'.tr())),
                  ],
                  selected: {_filterIndex(state.approvedFilter)},
                  onSelectionChanged: (value) {
                    final selected = value.first;
                    context.read<AdminReviewsCubit>().load(
                      approved: selected == 0 ? null : selected == 2,
                    );
                  },
                ),
                const SizedBox(height: AppTokens.s24),
                _content(context, state),
              ],
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

  Widget _content(BuildContext context, AdminReviewsState state) {
    if (state.status == AdminReviewsStatus.loading) {
      return const SizedBox(height: 340, child: LoadingState());
    }
    if (state.status == AdminReviewsStatus.failure && state.reviews.isEmpty) {
      return SizedBox(
        height: 340,
        child: ErrorState(
          message: 'load_reviews_failed'.tr(),
          onRetry: () => context.read<AdminReviewsCubit>().load(
            approved: state.approvedFilter,
          ),
        ),
      );
    }
    if (state.reviews.isEmpty) {
      return SizedBox(
        height: 300,
        child: EmptyState(
          icon: PhosphorIconsRegular.chatCenteredText,
          title: 'no_reviews_found'.tr(),
        ),
      );
    }
    return Column(
      children: [
        ...state.reviews.map((review) => _ReviewCard(review: review)),
        if (state.hasMore) ...[
          const SizedBox(height: AppTokens.s16),
          AppButton(
            text: 'load_more'.tr(),
            isPrimary: false,
            onPressed: context.read<AdminReviewsCubit>().loadMore,
          ),
        ],
      ],
    );
  }

  static int _filterIndex(bool? value) => value == null ? 0 : (value ? 2 : 1);
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppTokens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.productName ?? review.productId,
                  style: AppTypography.h4,
                ),
              ),
              Text('${review.rating}/5 ★'),
            ],
          ),
          const SizedBox(height: AppTokens.s8),
          Text(review.feedback),
          const SizedBox(height: AppTokens.s8),
          Text(
            '${review.displayName} · ${review.createdAt == null ? '—' : DateFormat.yMMMd().format(review.createdAt!)}',
            style: AppTypography.caption,
          ),
          const SizedBox(height: AppTokens.s12),
          Wrap(
            spacing: AppTokens.s8,
            children: [
              OutlinedButton(
                onPressed: () => context.read<AdminReviewsCubit>().setApproved(
                  review.id,
                  !review.approved,
                ),
                child: Text(
                  (review.approved ? 'move_to_pending' : 'approve').tr(),
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.read<AdminReviewsCubit>().delete(review.id),
                child: Text('delete'.tr()),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
