import 'package:equatable/equatable.dart';

import '../../store/data/models/store_settings.dart';
import '../../store/data/models/owner.dart';

enum AdminSettingsStatus {
  initial,
  loading,
  ready,
  uploading,
  saving,
  success,
  failure,
}

class AdminSettingsState extends Equatable {
  const AdminSettingsState({
    this.status = AdminSettingsStatus.initial,
    this.owner,
    this.settings,
    this.message,
  });

  final AdminSettingsStatus status;
  final Owner? owner;
  final StoreSettings? settings;
  final String? message;

  @override
  List<Object?> get props => [status, owner, settings, message];
}
