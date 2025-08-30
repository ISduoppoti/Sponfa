import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:glovoapotheka/domain/repositories/auth_repository.dart'; // Adjust import

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.unknown()) {
    // Listen to only auth changes and update the state
    _authRepository.user.listen((user) {
      if (user == null) {
        emit(const AuthState.unauthenticated());
      } else {
        emit(AuthState.authenticated(user));
      }
    });
  }

  Future<void> signWithEmail(String email, String password) async {
    emit(state.copyWith(isLoading: true, isError: false, error: null));
    try {
      await _authRepository.signInWithEmail(email: email, password: password);
    } catch (e) {
      emit(state.copyWith(isError: true, error: e.toString(), isLoading: false));
    }
  }

  Future<void> registerWithEmail(String email, String password, String firstName) async {
    emit(state.copyWith(isLoading: true, isError: false, error: null));
    try {
      await _authRepository.signUpWithEmail(email: email, password: password, firstName: firstName);
    } catch (e) {
      emit(state.copyWith(isError: true, error: e.toString(), isLoading: false));
    }
  }

  void signOut() {
    _authRepository.signOut();
  }
}