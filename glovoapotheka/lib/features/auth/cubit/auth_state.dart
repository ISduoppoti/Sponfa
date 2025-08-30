part of 'auth_cubit.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user; // Firebase User object
  final String? error;
  final bool isLoading;
  final bool isError;

  const AuthState._({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.isLoading = false,
    this.isError = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isLoading,
    bool? isError,
  }) {
    return AuthState._(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
    );
  }

  // Initial state, before we've checked for a user
  const AuthState.unknown({bool isLoading = false}) 
      : this._(isLoading: isLoading);

  // State when a user is successfully signed in
  const AuthState.authenticated(User user)
      : this._(status: AuthStatus.authenticated, user: user);

  // State when there is no user signed in
  const AuthState.unauthenticated({bool isLoading = false})
      : this._(status: AuthStatus.unauthenticated, isLoading: isLoading);

  @override
  List<Object?> get props => [status, user, isError, isLoading, error];
}