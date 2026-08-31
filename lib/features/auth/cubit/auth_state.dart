import 'package:equatable/equatable.dart';

import '../data/models/auth_session.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.session,
    this.message,
  });

  final AuthStatus status;
  final AuthSession? session;
  final String? message;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isAdmin => session?.isStoreMember ?? false;

  @override
  List<Object?> get props => [status, session, message];
}
