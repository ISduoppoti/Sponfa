part of 'auth_cubit.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, emailExists, emailNotFound, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user; // Firebase User object
  final String? error;
  final bool isLoading;

  const AuthState._({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    bool? isLoading,
  }) {
    return AuthState._(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  // Initial state, before we've checked for a user
  const AuthState.unknown({bool isLoading = false}) 
      : this._(isLoading: isLoading);

  // User exists
  const AuthState.emailExists({bool isLoading = false}) 
      : this._(status: AuthStatus.emailExists, isLoading: isLoading);

  // User doesnt exists
  const AuthState.emailNotFound({bool isLoading = false}) 
      : this._(status: AuthStatus.emailNotFound, isLoading: isLoading);

  // State when a user is successfully signed in
  const AuthState.authenticated(User user)
      : this._(status: AuthStatus.authenticated, user: user);

  // State when there is no user signed in
  const AuthState.unauthenticated({bool isLoading = false})
      : this._(status: AuthStatus.unauthenticated, isLoading: isLoading);

  // State when there is an error
  const AuthState.failure(String error, {bool isLoading = false})
      : this._(status: AuthStatus.failure, error: error);

  @override
  List<Object?> get props => [status, user];
}