import 'package:equatable/equatable.dart';

enum CheckoutStatus { initial, loading, success, failure }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.orderId,
    this.message,
  });

  final CheckoutStatus status;
  final String? orderId;
  final String? message;

  @override
  List<Object?> get props => [status, orderId, message];
}
