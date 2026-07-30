import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/auth_repository.dart';

const int _maxSignInAttempts = 3;
const Duration _signInLockoutDuration = Duration(minutes: 30);
const String _attemptsKeyPrefix = 'auth_sign_in_attempts_';
const String _lockoutUntilKeyPrefix = 'auth_sign_in_lockout_until_';

String _normalizeEmail(String email) => email.trim().toLowerCase();

String _attemptsKey(String email) =>
    '$_attemptsKeyPrefix${_normalizeEmail(email)}';

String _lockoutUntilKey(String email) =>
    '$_lockoutUntilKeyPrefix${_normalizeEmail(email)}';

class _LockoutData {
  final int failedAttempts;
  final DateTime? lockoutUntil;

  const _LockoutData({
    required this.failedAttempts,
    required this.lockoutUntil,
  });
}

/// Represents the state of an authentication operation.
class AuthUiState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final bool isOTPVerified;
  final String? lockedEmail;
  final DateTime? lockoutUntil;
  final int failedAttempts;

  const AuthUiState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.isOTPVerified = false,
    this.lockedEmail,
    this.lockoutUntil,
    this.failedAttempts = 0,
  });

  static const Object _sentinel = Object();

  AuthUiState copyWith({
    bool? isLoading,
    Object? errorMessage = _sentinel,
    bool? isSuccess,
    Object? lockedEmail = _sentinel,
    Object? lockoutUntil = _sentinel,
    int? failedAttempts,
    bool? isOTPVerified,
  }) {
    return AuthUiState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      isSuccess: isSuccess ?? this.isSuccess,
      lockedEmail: identical(lockedEmail, _sentinel)
          ? this.lockedEmail
          : lockedEmail as String?,
      lockoutUntil: identical(lockoutUntil, _sentinel)
          ? this.lockoutUntil
          : lockoutUntil as DateTime?,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      isOTPVerified: isOTPVerified ?? this.isOTPVerified,
    );
  }

  bool get isLocked =>
      lockedEmail != null &&
      lockoutUntil != null &&
      DateTime.now().isBefore(lockoutUntil!);

  bool isLockedForEmail(String email) {
    final normalizedEmail = _normalizeEmail(email);
    return lockedEmail == normalizedEmail && isLocked;
  }
}

/// Manages authentication state for sign-up and sign-in flows.
class AuthNotifier extends StateNotifier<AuthUiState> {
  final AuthRepository _authRepository;
  Timer? _lockoutTimer;

  AuthNotifier(this._authRepository) : super(const AuthUiState());

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  Future<SharedPreferences> _preferences() async {
    return SharedPreferences.getInstance();
  }

  Future<_LockoutData> _readLockoutData(String email) async {
    final prefs = await _preferences();
    final normalizedEmail = _normalizeEmail(email);
    final attempts = prefs.getInt(_attemptsKey(normalizedEmail)) ?? 0;
    final lockoutRaw = prefs.getString(_lockoutUntilKey(normalizedEmail));
    final lockoutUntil = lockoutRaw == null
        ? null
        : DateTime.tryParse(lockoutRaw);

    if (lockoutUntil != null && !DateTime.now().isBefore(lockoutUntil)) {
      await prefs.remove(_attemptsKey(normalizedEmail));
      await prefs.remove(_lockoutUntilKey(normalizedEmail));
      return const _LockoutData(failedAttempts: 0, lockoutUntil: null);
    }

    return _LockoutData(failedAttempts: attempts, lockoutUntil: lockoutUntil);
  }

  void _cancelLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = null;
  }

  void _scheduleLockoutRefresh(String email, DateTime lockoutUntil) {
    _cancelLockoutTimer();

    final remaining = lockoutUntil.difference(DateTime.now());
    if (remaining.isNegative || remaining == Duration.zero) {
      return;
    }

    _lockoutTimer = Timer(remaining + const Duration(milliseconds: 250), () {
      syncLoginLockState(email);
    });
  }

  void _applyLockoutState(String email, _LockoutData data) {
    final normalizedEmail = _normalizeEmail(email);
    if (data.lockoutUntil == null) {
      _cancelLockoutTimer();
    } else {
      _scheduleLockoutRefresh(normalizedEmail, data.lockoutUntil!);
    }

    state = state.copyWith(
      lockedEmail: data.lockoutUntil == null ? null : normalizedEmail,
      lockoutUntil: data.lockoutUntil,
      failedAttempts: data.failedAttempts,
    );
  }

  Future<void> _clearStoredLockout(String email) async {
    final prefs = await _preferences();
    final normalizedEmail = _normalizeEmail(email);
    await prefs.remove(_attemptsKey(normalizedEmail));
    await prefs.remove(_lockoutUntilKey(normalizedEmail));
  }

  Future<void> syncLoginLockState(String email) async {
    final normalizedEmail = _normalizeEmail(email);

    if (normalizedEmail.isEmpty) {
      _cancelLockoutTimer();
      state = state.copyWith(
        lockedEmail: null,
        lockoutUntil: null,
        failedAttempts: 0,
      );
      return;
    }

    final data = await _readLockoutData(normalizedEmail);
    _applyLockoutState(normalizedEmail, data);
  }

  Future<void> _handleFailedSignIn(String email, String errorMessage) async {
    final normalizedEmail = _normalizeEmail(email);
    final data = await _readLockoutData(normalizedEmail);

    if (data.lockoutUntil != null) {
      _applyLockoutState(normalizedEmail, data);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Too many failed attempts. Try again after 30 minutes.',
      );
      return;
    }

    final nextAttempts = data.failedAttempts + 1;
    final prefs = await _preferences();

    if (nextAttempts >= _maxSignInAttempts) {
      final lockoutUntil = DateTime.now().add(_signInLockoutDuration);
      await prefs.setString(
        _lockoutUntilKey(normalizedEmail),
        lockoutUntil.toIso8601String(),
      );
      await prefs.setInt(_attemptsKey(normalizedEmail), 0);
      _applyLockoutState(
        normalizedEmail,
        _LockoutData(failedAttempts: 0, lockoutUntil: lockoutUntil),
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Too many failed attempts. Try again after 30 minutes.',
      );
      return;
    }

    await prefs.setInt(_attemptsKey(normalizedEmail), nextAttempts);
    await prefs.remove(_lockoutUntilKey(normalizedEmail));
    state = state.copyWith(
      isLoading: false,
      errorMessage: errorMessage,
      failedAttempts: nextAttempts,
      lockedEmail: null,
      lockoutUntil: null,
    );
  }

  // Forgot Password Step 1: Request OTP
  Future<void> requestPasswordReset(String email) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
      isOTPVerified: false,
    );

    try {
      await _authRepository.requestPasswordResetOTP(email: email);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Step 2: Verify OTP
  Future<void> verifyOTP({
    required String email,
    required String otpCode,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.verifyRecoveryOTP(email: email, otpCode: otpCode);
      state = state.copyWith(isLoading: false, isOTPVerified: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Step 3: Update Password
  Future<void> updatePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.updatePassword(newPassword: newPassword);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        isOTPVerified: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Sign up a new user with full name, email, and password.
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, isSuccess: false);

    try {
      final response = await _authRepository.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      // Supabase returns an empty identities list when email is already registered
      if (response.user?.identities?.isEmpty ?? true) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'An account with this email already exists.',
        );
        return;
      }

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    final normalizedEmail = _normalizeEmail(email);
    await syncLoginLockState(normalizedEmail);

    if (state.isLockedForEmail(normalizedEmail)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Too many failed attempts. Try again after 30 minutes.',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      errorMessage: null,
    );

    try {
      await _authRepository.signIn(email: email, password: password);
      await _clearStoredLockout(normalizedEmail);
      _cancelLockoutTimer();
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      await _handleFailedSignIn(normalizedEmail, e.toString());
    }
  }

  /// Reset state back to initial (useful when navigating away).
  void resetState() {
    state = const AuthUiState();
  }

  Future<void> verifyResetOtp({required String email, required String otpCode}) {
    return verifyOTP(email: email, otpCode: otpCode);
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
