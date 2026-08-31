import 'package:equatable/equatable.dart';

import '../../customers/data/models/customer.dart';

enum AdminCustomersStatus { initial, loading, success, empty, failure }

class AdminCustomersState extends Equatable {
  const AdminCustomersState({
    this.status = AdminCustomersStatus.initial,
    this.customers = const [],
    this.hasMore = false,
    this.message,
  });

  final AdminCustomersStatus status;
  final List<Customer> customers;
  final bool hasMore;
  final String? message;

  @override
  List<Object?> get props => [status, customers, hasMore, message];
}
