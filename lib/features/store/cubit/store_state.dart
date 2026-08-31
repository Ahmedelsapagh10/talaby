import 'package:equatable/equatable.dart';

import '../data/models/owner.dart';
import '../data/models/store_settings.dart';

enum StoreStatus { initial, loading, success, empty, failure }

class StoreState extends Equatable {
  const StoreState({
    this.status = StoreStatus.initial,
    this.owner,
    this.settings,
    this.message,
  });

  final StoreStatus status;
  final Owner? owner;
  final StoreSettings? settings;
  final String? message;

  @override
  List<Object?> get props => [status, owner, settings, message];
}
