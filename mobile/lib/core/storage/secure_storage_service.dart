import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists auth tokens in the platform secure store (Keychain on iOS,
/// Keystore on Android). Single source of truth for the access /
/// refresh token pair so the auth interceptor and the auth state
/// notifier never disagree about whether the user is signed in.
class SecureStorageService {
  SecureStorageService(this._storage);

  static const _kAccessToken = 'thaqafa.access_token';
  static const _kRefreshToken = 'thaqafa.refresh_token';
  static const _kAccessExpiresAt = 'thaqafa.access_expires_at';
  static const _kRefreshExpiresAt = 'thaqafa.refresh_expires_at';

  final FlutterSecureStorage _storage;

  static SecureStorageService create() => SecureStorageService(
        const FlutterSecureStorage(
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        ),
      );

  Future<void> writeTokens({
    required String access,
    required String refresh,
    required DateTime accessExpiresAt,
    required DateTime refreshExpiresAt,
  }) async {
    await _storage.write(key: _kAccessToken, value: access);
    await _storage.write(key: _kRefreshToken, value: refresh);
    await _storage.write(
      key: _kAccessExpiresAt,
      value: accessExpiresAt.toIso8601String(),
    );
    await _storage.write(
      key: _kRefreshExpiresAt,
      value: refreshExpiresAt.toIso8601String(),
    );
  }

  Future<String?> readAccess() => _storage.read(key: _kAccessToken);
  Future<String?> readRefresh() => _storage.read(key: _kRefreshToken);

  Future<DateTime?> readAccessExpiresAt() async {
    final v = await _storage.read(key: _kAccessExpiresAt);
    return v != null ? DateTime.tryParse(v) : null;
  }

  Future<DateTime?> readRefreshExpiresAt() async {
    final v = await _storage.read(key: _kRefreshExpiresAt);
    return v != null ? DateTime.tryParse(v) : null;
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
    await _storage.delete(key: _kAccessExpiresAt);
    await _storage.delete(key: _kRefreshExpiresAt);
  }
}
