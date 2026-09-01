import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_repository.dart';
import '../data/models/auth_session.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState()) {
    _subscription = _repository.authStateChanges.listen(_handleUser);
  }

  final AuthRepository _repository;
  late final StreamSubscription<User?> _subscription;

  Future<void> _handleUser(User? user) async {
    if (user == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final session = await _repository.loadSession(user);
      emit(AuthState(status: AuthStatus.authenticated, session: session));
    } catch (error) {
      emit(AuthState(status: AuthStatus.failure, message: error.toString()));
    }
  }

  Future<void> login(String email, String password) =>
      _authenticate(() => _repository.login(email: email, password: password));

  Future<void> register(String email, String password, String name) =>
      _authenticate(
        () => _repository.register(
          email: email,
          password: password,
          displayName: name,
        ),
      );

  Future<void> signInWithGoogle() =>
      _authenticate(_repository.signInWithGoogle);
  Future<void> signInWithApple() => _authenticate(_repository.signInWithApple);

  Future<void> startGuestCheckout() =>
      _authenticate(_repository.startGuestCheckout);

  Future<void> forgotPassword(String email) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      await _repository.sendPasswordReset(email);
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (error) {
      emit(AuthState(status: AuthStatus.failure, message: error.toString()));
    }
  }

  Future<void> logout() => _repository.logout();

  Future<void> _authenticate(Future<AuthSession> Function() operation) async {
    emit(const AuthState(status: AuthStatus.loading));
    try {
      final session = await operation();
      emit(AuthState(status: AuthStatus.authenticated, session: session));
    } catch (error) {
      emit(AuthState(status: AuthStatus.failure, message: error.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
