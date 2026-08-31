import 'package:equatable/equatable.dart';

import '../data/models/commerce_order.dart';

enum CustomerOrdersStatus { initial, loading, success, empty, failure }

class CustomerOrdersState extends Equatable {
  const CustomerOrdersState({
    this.status = CustomerOrdersStatus.initial,
    this.orders = const [],
    this.hasMore = false,
    this.isSubmittingProof = false,
    this.proofSubmitted = false,
    this.message,
  });

  final CustomerOrdersStatus status;
  final List<CommerceOrder> orders;
  final bool hasMore;
  final bool isSubmittingProof;
  final bool proofSubmitted;
  final String? message;

  CustomerOrdersState copyWith({
    CustomerOrdersStatus? status,
    List<CommerceOrder>? orders,
    bool? hasMore,
    bool? isSubmittingProof,
    bool? proofSubmitted,
    String? message,
  }) => CustomerOrdersState(
    status: status ?? this.status,
    orders: orders ?? this.orders,
    hasMore: hasMore ?? this.hasMore,
    isSubmittingProof: isSubmittingProof ?? this.isSubmittingProof,
    proofSubmitted: proofSubmitted ?? this.proofSubmitted,
    message: message,
  );

  @override
  List<Object?> get props => [
    status,
    orders,
    hasMore,
    isSubmittingProof,
    proofSubmitted,
    message,
  ];
}
