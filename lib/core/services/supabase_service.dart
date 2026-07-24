import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

/// Centralized service for initialized Supabase client access.
class SupabaseService {
  SupabaseService._();

  /// Initialize Supabase client. Call this inside main() before runApp().
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      publishableKey: SupabaseConstants.supabaseAnonKey,
    );
  }

  /// Get active SupabaseClient instance.
  static SupabaseClient get client => Supabase.instance.client;

  /// Quick accessor for current authenticated User (if any).
  static User? get currentUser => client.auth.currentUser;

  /// Helper to check if a user session is active.
  static bool get isAuthenticated => currentUser != null;
}
