import 'package:equatable/equatable.dart';

import '../data/models/customer_profile.dart';

enum ProfileStatus { initial, loading, ready, saving, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.message,
  });

  final ProfileStatus status;
  final CustomerProfile? profile;
  final String? message;

  @override
  List<Object?> get props => [status, profile, message];
}
