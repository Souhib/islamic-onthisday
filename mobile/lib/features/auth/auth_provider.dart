import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thaqafa/api/generated/models/login_request.dart';
import 'package:thaqafa/api/generated/models/signup_request.dart';
import 'package:thaqafa/api/generated/models/token_pair.dart';
import 'package:thaqafa/core/di/api_providers.dart';
import 'package:thaqafa/core/storage/secure_storage_service.dart';
import 'package:thaqafa/features/auth/auth_state.dart';

/// The secure storage instance lives at app scope; constructed once
/// in bootstrap and provided here without a real init step.
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService.create();
});

/// Auth state notifier. On boot reads any persisted token pair and,
/// if valid, fetches `/auth/me` to hydrate the user. Login / signup /
/// logout flips the state and pushes tokens to secure storage.
class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final storage = ref.read(secureStorageProvider);
    final access = await storage.readAccess();
    final accessExp = await storage.readAccessExpiresAt();
    if (access == null || accessExp == null || accessExp.isBefore(DateTime.now())) {
      // No token, or expired and we don't auto-refresh on boot — the
      // interceptor will handle refresh on the first 401 instead.
      return const AuthSignedOut();
    }

    try {
      final me = await ref.read(thaqafaClientProvider).auth.meApiV1AuthMeGet();
      return AuthSignedIn(user: me);
    } on DioException {
      await storage.clear();
      return const AuthSignedOut();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      final pair = await ref.read(thaqafaClientProvider).auth.loginApiV1AuthLoginPost(
            body: LoginRequest(email: email, password: password),
          );
      await _persist(pair);
      state = AsyncValue.data(AuthSignedIn(user: pair.user));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final pair = await ref.read(thaqafaClientProvider).auth.signupApiV1AuthSignupPost(
            body: SignupRequest(
              email: email,
              password: password,
              displayName: displayName,
            ),
          );
      await _persist(pair);
      state = AsyncValue.data(AuthSignedIn(user: pair.user));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).clear();
    state = const AsyncValue.data(AuthSignedOut());
  }

  Future<void> deleteAccount() async {
    await ref.read(thaqafaClientProvider).auth.deleteAccountApiV1AuthMeDelete();
    await ref.read(secureStorageProvider).clear();
    state = const AsyncValue.data(AuthSignedOut());
  }

  Future<void> _persist(TokenPair pair) async {
    await ref.read(secureStorageProvider).writeTokens(
          access: pair.accessToken,
          refresh: pair.refreshToken,
          accessExpiresAt: pair.accessExpiresAt,
          refreshExpiresAt: pair.refreshExpiresAt,
        );
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
