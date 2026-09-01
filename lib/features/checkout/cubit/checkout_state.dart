import 'package:equatable/equatable.dart';
import '../../profile/data/models/customer_profile.dart';

enum CheckoutStatus { initial, loading, success, failure }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.orderId,
    this.message,
    this.profile,
  });

  final CheckoutStatus status;
  final String? orderId;
  final String? message;
  final CustomerProfile? profile;

  @override
  List<Object?> get props => [status, orderId, message, profile];
}
