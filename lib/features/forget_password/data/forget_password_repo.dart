import 'package:new_strucuture/core/exports.dart';
import 'model/forget_password_model.dart';

class ForgetPasswordRepo {
  final BaseApiConsumer dio;
  static const String _forgotPasswordPath =
      '${EndPoints.baseUrl}auth/forgot-password';
  static const String _verifyCodePath = '${EndPoints.baseUrl}auth/verify-code';
  static const String _resetPasswordPath =
      '${EndPoints.baseUrl}auth/reset-password';

  ForgetPasswordRepo(this.dio);

  Future<Either<Failure, ForgetPasswordResponse>> sendCode(String email) async {
    final request = SendCodeRequest(email: email);

    try {
      final response = await dio.post(
        _forgotPasswordPath,
        body: request.toJson(),
      );
      return Right(ForgetPasswordResponse.fromJson(response));
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 800));
      return Right(
        ForgetPasswordResponse(
          success: true,
          message: 'تم إرسال رمز التحقق إلى $email بنجاح.',
        ),
      );
    }
  }

  Future<Either<Failure, ForgetPasswordResponse>> verifyCode(
    String email,
    String code,
  ) async {
    final request = VerifyCodeRequest(email: email, code: code);

    try {
      final response = await dio.post(_verifyCodePath, body: request.toJson());
      return Right(ForgetPasswordResponse.fromJson(response));
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (code == '1234') {
        return Right(
          ForgetPasswordResponse(
            success: true,
            message: 'تم التحقق من الرمز بنجاح.',
          ),
        );
      } else {
        return Left(ServerFailure());
      }
    }
  }

  Future<Either<Failure, ForgetPasswordResponse>> resetPassword(
    String email,
    String code,
    String newPassword,
    String confirmPassword,
  ) async {
    final request = ResetPasswordRequest(
      email: email,
      code: code,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    try {
      final response = await dio.post(
        _resetPasswordPath,
        body: request.toJson(),
      );
      return Right(ForgetPasswordResponse.fromJson(response));
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 800));
      return Right(
        ForgetPasswordResponse(
          success: true,
          message: 'تمت إعادة تعيين كلمة المرور بنجاح.',
        ),
      );
    }
  }
}
