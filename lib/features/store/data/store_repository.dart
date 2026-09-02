import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firestore_paths.dart';
import 'models/owner.dart';
import 'models/store_settings.dart';

class StoreRepository {
  StoreRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<Owner?> watchOwner() {
    return _firestore.doc(FirestorePaths.owner).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Owner.fromDocument(doc);
    });
  }

  Future<Owner?> getOwner() async {
    final doc = await _firestore.doc(FirestorePaths.owner).get();
    return doc.exists ? Owner.fromDocument(doc) : null;
  }

  Future<void> updateOwnerProfile(Owner owner) {
    return _firestore.doc(FirestorePaths.owner).update({
      ...owner.toPublicProfileMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateOwnerAndSettings(
    Owner owner,
    StoreSettings settings,
  ) async {
    final batch = _firestore.batch();
    batch.update(_firestore.doc(FirestorePaths.owner), {
      ...owner.toPublicProfileMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_firestore.doc(FirestorePaths.generalSettings), {
      ...settings.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit();
  }

  Stream<StoreSettings?> watchSettings() {
    return _firestore
        .doc(FirestorePaths.generalSettings)
        .snapshots()
        .map((doc) => doc.exists ? StoreSettings.fromDocument(doc) : null);
  }

  Future<StoreSettings?> getSettings() async {
    final document = await _firestore.doc(FirestorePaths.generalSettings).get();
    return document.exists ? StoreSettings.fromDocument(document) : null;
  }

  Future<void> updateSettings(StoreSettings settings) {
    return _firestore.doc(FirestorePaths.generalSettings).set({
      ...settings.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
