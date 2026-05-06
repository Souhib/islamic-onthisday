// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/change_display_name_request.dart';
import '../models/change_email_confirm.dart';
import '../models/change_email_request.dart';
import '../models/change_password_request.dart';
import '../models/email_verify_confirm.dart';
import '../models/email_verify_resend.dart';
import '../models/login_request.dart';
import '../models/password_reset_confirm.dart';
import '../models/password_reset_request.dart';
import '../models/refresh_request.dart';
import '../models/signup_request.dart';
import '../models/token_pair.dart';
import '../models/user_public.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String? baseUrl}) = _AuthClient;

  /// Create a new account and receive a token pair
  @POST('/api/v1/auth/signup')
  Future<TokenPair> signupApiV1AuthSignupPost({
    @Body() required SignupRequest body,
  });

  /// Exchange email + password for a token pair
  @POST('/api/v1/auth/login')
  Future<TokenPair> loginApiV1AuthLoginPost({
    @Body() required LoginRequest body,
  });

  /// Exchange a refresh token for a fresh pair
  @POST('/api/v1/auth/refresh')
  Future<TokenPair> refreshApiV1AuthRefreshPost({
    @Body() required RefreshRequest body,
  });

  /// Return the authenticated user's profile
  @GET('/api/v1/auth/me')
  Future<UserPublic> meApiV1AuthMeGet({
    @Header('Authorization') String? authorization,
  });

  /// Update the authenticated user's display name
  @PATCH('/api/v1/auth/me')
  Future<UserPublic> changeDisplayNameApiV1AuthMePatch({
    @Body() required ChangeDisplayNameRequest body,
    @Header('Authorization') String? authorization,
  });

  /// Permanently delete the authenticated user's account.
  ///
  /// Permanently delete the authenticated user.
  ///
  /// Cascades the user's bookmarks + every one-time-token row in a single.
  /// transaction. Idempotent — a re-tried delete on a token whose user is.
  /// already gone resolves to a no-op via the existing 401-on-missing-user.
  /// flow.
  @DELETE('/api/v1/auth/me')
  Future<void> deleteAccountApiV1AuthMeDelete({
    @Header('Authorization') String? authorization,
  });

  /// Send a password-reset email if the address is registered
  @POST('/api/v1/auth/password-reset/request')
  Future<void> requestPasswordResetApiV1AuthPasswordResetRequestPost({
    @Body() required PasswordResetRequest body,
  });

  /// Consume a password-reset token and set a new password
  @POST('/api/v1/auth/password-reset/confirm')
  Future<void> confirmPasswordResetApiV1AuthPasswordResetConfirmPost({
    @Body() required PasswordResetConfirm body,
  });

  /// Consume an email-verification token and mark the user verified
  @POST('/api/v1/auth/email/verify')
  Future<void> verifyEmailApiV1AuthEmailVerifyPost({
    @Body() required EmailVerifyConfirm body,
  });

  /// Re-send the verification email if the address is registered
  @POST('/api/v1/auth/email/resend')
  Future<void> resendVerificationEmailApiV1AuthEmailResendPost({
    @Body() required EmailVerifyResend body,
  });

  /// Rotate the authenticated user's password
  @POST('/api/v1/auth/me/password')
  Future<void> changePasswordApiV1AuthMePasswordPost({
    @Body() required ChangePasswordRequest body,
    @Header('Authorization') String? authorization,
  });

  /// Start the email-change flow (verify link sent to the new address)
  @POST('/api/v1/auth/me/email')
  Future<void> requestEmailChangeApiV1AuthMeEmailPost({
    @Body() required ChangeEmailRequest body,
    @Header('Authorization') String? authorization,
  });

  /// Consume an email-change token and apply the new address
  @POST('/api/v1/auth/me/email/confirm')
  Future<UserPublic> confirmEmailChangeApiV1AuthMeEmailConfirmPost({
    @Body() required ChangeEmailConfirm body,
  });
}
