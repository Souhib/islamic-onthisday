import 'package:equatable/equatable.dart';
import 'package:iotd_mobile/api/generated/models/user_public.dart';

/// Sealed-style auth state. The router and feature surfaces watch this
/// to decide what to show. Three concrete shapes:
///   - `unknown`  — still resolving on app boot
///   - `signedOut` — no tokens, anonymous reading mode
///   - `signedIn`  — token pair present, `user` carries the profile
sealed class AuthState extends Equatable {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
  @override
  List<Object?> get props => const [];
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut();
  @override
  List<Object?> get props => const [];
}

class AuthSignedIn extends AuthState {
  const AuthSignedIn({required this.user});

  final UserPublic user;

  @override
  List<Object?> get props => [user.id];
}
