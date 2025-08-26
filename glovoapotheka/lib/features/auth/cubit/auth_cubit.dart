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

  Future<void> checkEmail(String email) async {
    emit(state.copyWith(isLoading: true));
    try {
      final exists = await _authRepository.checkEmailExists(email: email);
      print(email);
      print('Email exists: $exists');
      if (exists) {
        emit(AuthState.emailExists());   // user already registered
      } else {
        emit(AuthState.emailNotFound()); // new user
      }
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  void signOut() {
    _authRepository.signOut();
  }
}