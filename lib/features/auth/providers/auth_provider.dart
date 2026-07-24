import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

/// Represents the state of an authentication operation.
class AuthUiState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  const AuthUiState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  AuthUiState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return AuthUiState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Manages authentication state for sign-up and sign-in flows.
class AuthNotifier extends StateNotifier<AuthUiState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthUiState());

  /// Sign up a new user with full name, email, and password.
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, isSuccess: false);

    try {
      await _authRepository.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Reset state back to initial (useful when navigating away).
  void resetState() {
    state = const AuthUiState();
  }
}

/// Provider for the AuthRepository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider for the AuthNotifier.
final authProvider = StateNotifierProvider<AuthNotifier, AuthUiState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
