import 'package:equatable/equatable.dart';

import 'user_role.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final UserRole? role;

  bool get isStoreMember => role?.canManageStore ?? false;

  AuthSession copyWith({UserRole? role}) => AuthSession(
    uid: uid,
    email: email,
    displayName: displayName,
    photoUrl: photoUrl,
    role: role ?? this.role,
  );

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl, role];
}
