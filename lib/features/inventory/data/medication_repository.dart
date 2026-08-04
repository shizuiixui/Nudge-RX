import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../models/medication_model.dart';

class MedicationRepository {
  final SupabaseClient _client;

  MedicationRepository({SupabaseClient? client})
      : _client = client ?? SupabaseService.client;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.id;
  }

  /// Fetch all medications for the current user, ordered by reminder_time.
  Future<List<MedicationModel>> fetchMedications() async {
    final data = await _client
        .from('medications')
        .select()
        .eq('user_id', _userId)
        .order('reminder_time', ascending: true);

    return (data as List)
        .map((row) => MedicationModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Ensure the current user has a row in the `profiles` table.
  /// Required because `medications.user_id` is a FK to `profiles.id`.
  Future<void> _ensureProfileExists() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final fullName =
        (user.userMetadata?['full_name'] as String?) ?? '';

    await _client.from('profiles').upsert(
      {
        'id': user.id,
        'full_name': fullName,
      },
      onConflict: 'id',
    );
  }

  /// Insert a new medication for the current user.
  Future<MedicationModel> addMedication(MedicationModel med) async {
    await _ensureProfileExists();

    final row = med.copyWith(userId: _userId).toJson();
    final result = await _client
        .from('medications')
        .insert(row)
        .select()
        .single();

    return MedicationModel.fromJson(result);
  }

  /// Update an existing medication by id.
  Future<MedicationModel> updateMedication(MedicationModel med) async {
    if (med.id == null) throw Exception('Cannot update medication without id');
    final row = med.toJson();
    final result = await _client
        .from('medications')
        .update(row)
        .eq('id', med.id!)
        .eq('user_id', _userId)
        .select()
        .single();

    return MedicationModel.fromJson(result);
  }

  /// Delete a medication by id.
  Future<void> deleteMedication(String id) async {
    await _client
        .from('medications')
        .delete()
        .eq('id', id)
        .eq('user_id', _userId);
  }
}
