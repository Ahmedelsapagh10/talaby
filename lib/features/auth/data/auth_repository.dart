import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/config/app_config.dart';
import '../../../core/firebase/firestore_paths.dart';
import '../../../core/utils/search_normalizer.dart';
import 'models/auth_session.dart';
import 'models/user_role.dart';

class AuthRepository {
  AuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  bool _googleInitialized = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<AuthSession?> loadSession(User? user) async {
    if (user == null) return null;
    final member = await _firestore.doc(FirestorePaths.member(user.uid)).get();
    final role = UserRoleCodec.fromValue(member.data()?['role']);
    return AuthSession(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      role: role,
    );
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user!.updateDisplayName(displayName.trim());
    await _ensureUserProfile(credential.user!, displayName: displayName.trim());
    return (await loadSession(credential.user))!;
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return (await loadSession(credential.user))!;
  }

  Future<AuthSession> startGuestCheckout() async {
    final current = _auth.currentUser;
    if (current != null) return (await loadSession(current))!;
    final credential = await _auth.signInAnonymously();
    return (await loadSession(credential.user))!;
  }

  Future<AuthSession> signInWithGoogle() async {
    UserCredential credential;
    if (kIsWeb) {
      credential = await _auth.signInWithPopup(GoogleAuthProvider());
    } else {
      if (!_googleInitialized) {
        await GoogleSignIn.instance.initialize();
        _googleInitialized = true;
      }
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw StateError('Google did not return an ID token.');
      }
      credential = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    }
    await _ensureUserProfile(credential.user!);
    return (await loadSession(credential.user))!;
  }

  Future<AuthSession> signInWithApple() async {
    final rawNonce = _randomNonce();
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
    );
    final credential = await _auth.signInWithCredential(
      OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce),
    );
    await _ensureUserProfile(credential.user!);
    return (await loadSession(credential.user))!;
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() async {
    await _auth.signOut();
    if (_googleInitialized) await GoogleSignIn.instance.signOut();
  }

  Future<void> _ensureUserProfile(User user, {String? displayName}) async {
    final reference = _firestore.doc(FirestorePaths.user(user.uid));
    final snapshot = await reference.get();
    final data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': displayName ?? user.displayName,
      'photoUrl': user.photoURL,
      'lastOwnerId': AppConfig.ownerId,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!snapshot.exists) data['createdAt'] = FieldValue.serverTimestamp();
    await reference.set(data, SetOptions(merge: true));
    final customerReference = _firestore.doc(FirestorePaths.customer(user.uid));
    final customerSnapshot = await customerReference.get();
    final name = displayName ?? user.displayName ?? '';
    await customerReference.set({
      'name': name,
      'email': user.email,
      'phone': '',
      'searchName': SearchNormalizer.normalize(name),
      'searchPhone': SearchNormalizer.normalizePhone(''),
      'updatedAt': FieldValue.serverTimestamp(),
      if (!customerSnapshot.exists) ...{
        'orderCount': 0,
        'lastOrderAt': null,
        'createdAt': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
  }

  static String _randomNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }
}
