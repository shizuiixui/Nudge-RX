import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

class AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepository({SupabaseClient? client})
    : _supabaseClient = client ?? SupabaseService.client;

  /// Get current user session
  User? get currentUser => _supabaseClient.auth.currentUser;

  /// Stream of Auth state changes (e.g. signedIn, signedOut, tokenRefreshed)
  Stream<AuthState> get onAuthStateChange =>
      _supabaseClient.auth.onAuthStateChange;

  /// Sign up user with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  /// Sign in user with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  /// Request password reset OTP
  Future<void> requestPasswordResetOTP({required String email}) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  Future<void> verifyRecoveryOTP({required String email, required String otpCode}) async {
    await _supabaseClient.auth.verifyOTP(
      email: email,
      token: otpCode,
      type: OtpType.recovery,
    );
  }

  Future<void> updatePassword({required String newPassword}) async {
    await _supabaseClient.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
