import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/firebase/firestore_paths.dart';
import '../../../core/utils/search_normalizer.dart';
import 'models/customer_profile.dart';

class ProfileRepository {
  ProfileRepository(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<CustomerProfile> getProfile(String userId) async {
    final results = await Future.wait([
      _firestore.doc(FirestorePaths.user(userId)).get(),
      _firestore.doc(FirestorePaths.customer(userId)).get(),
    ]);
    final user = results[0].data() ?? const <String, dynamic>{};
    final customer = results[1].data() ?? const <String, dynamic>{};
    return CustomerProfile(
      userId: userId,
      name:
          customer['name']?.toString() ??
          user['displayName']?.toString() ??
          _auth.currentUser?.displayName ??
          '',
      email:
          user['email']?.toString() ??
          _auth.currentUser?.email?.toString() ??
          '',
      phone: customer['phone']?.toString() ?? '',
      defaultCity: customer['defaultCity']?.toString() ?? '',
      defaultAddress: customer['defaultAddress']?.toString() ?? '',
    );
  }

  Future<void> updateProfile(CustomerProfile profile) async {
    final now = FieldValue.serverTimestamp();
    final customerReference = _firestore.doc(
      FirestorePaths.customer(profile.userId),
    );
    final customerSnapshot = await customerReference.get();
    await _auth.currentUser?.updateDisplayName(profile.name.trim());
    final batch = _firestore.batch();
    batch.set(_firestore.doc(FirestorePaths.user(profile.userId)), {
      'displayName': profile.name.trim(),
      'updatedAt': now,
    }, SetOptions(merge: true));
    batch.set(customerReference, {
      'name': profile.name.trim(),
      'phone': profile.phone.trim(),
      'email': profile.email.trim(),
      'defaultCity': profile.defaultCity.trim(),
      'defaultAddress': profile.defaultAddress.trim(),
      'searchName': SearchNormalizer.normalize(profile.name),
      'searchPhone': SearchNormalizer.normalizePhone(profile.phone),
      'updatedAt': now,
      if (!customerSnapshot.exists) ...{
        'orderCount': 0,
        'lastOrderAt': null,
        'createdAt': now,
      },
    }, SetOptions(merge: true));
    await batch.commit();
  }
}
