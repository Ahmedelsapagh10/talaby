import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

String mapFirebaseAuthError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
        return 'error_user_not_found'.tr();
      case 'wrong-password':
        return 'error_wrong_password'.tr();
      case 'invalid-email':
        return 'error_invalid_email'.tr();
      case 'user-disabled':
        return 'error_user_disabled'.tr();
      case 'email-already-in-use':
        return 'error_email_in_use'.tr();
      case 'operation-not-allowed':
        return 'error_operation_not_allowed'.tr();
      case 'weak-password':
        return 'error_weak_password'.tr();
      case 'network-request-failed':
        return 'error_network_request_failed'.tr();
      case 'invalid-credential':
        return 'error_invalid_credential'.tr();
      case 'too-many-requests':
        return 'error_too_many_requests'.tr();
      case 'popup-closed-by-user':
        return 'error_popup_closed'.tr();
      default:
        return 'error_unknown_auth'.tr();
    }
  }
  return error.toString();
}
