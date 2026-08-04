import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/medication_repository.dart';
import '../models/medication_model.dart';

/// Repository singleton provider.
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return MedicationRepository();
});

final medicationsProvider =
    AsyncNotifierProvider<MedicationsNotifier, List<MedicationModel>>(
      MedicationsNotifier.new,
    );

class MedicationsNotifier extends AsyncNotifier<List<MedicationModel>> {
  @override
  Future<List<MedicationModel>> build() async {
    final repo = ref.read(medicationRepositoryProvider);
    return repo.fetchMedications();
  }

  Future<void> addMedication(MedicationModel med) async {
    final repo = ref.read(medicationRepositoryProvider);
    final saved = await repo.addMedication(med);
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, saved]);
  }

  Future<void> updateMedication(MedicationModel med) async {
    final repo = ref.read(medicationRepositoryProvider);
    final updated = await repo.updateMedication(med);
    final current = state.valueOrNull ?? [];
    state = AsyncData([
      for (final m in current)
        if (m.id == updated.id) updated else m,
    ]);
  }

  Future<void> deleteMedication(String id) async {
    final repo = ref.read(medicationRepositoryProvider);
    await repo.deleteMedication(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((m) => m.id != id).toList());
  }

  /// Re-fetch everything from Supabase.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(medicationRepositoryProvider);
      return repo.fetchMedications();
    });
  }
}

enum MedicationStatus { pending, taken, skipped }

class MedicationStatusNotifier
    extends StateNotifier<Map<String, MedicationStatus>> {
  MedicationStatusNotifier() : super({});

  void markAsTaken(String id) {
    state = {...state, id: MedicationStatus.taken};
  }

  void markAsSkipped(String id) {
    state = {...state, id: MedicationStatus.skipped};
  }

  void resetStatus(String id) {
    final newState = Map<String, MedicationStatus>.from(state);
    newState.remove(id);
    state = newState;
  }
}

final medicationStatusProvider =
    StateNotifierProvider<
      MedicationStatusNotifier,
      Map<String, MedicationStatus>
    >((ref) => MedicationStatusNotifier());

final morningMedsProvider = Provider<List<MedicationModel>>((ref) {
  final meds = ref.watch(medicationsProvider).valueOrNull ?? [];
  return meds.where((m) => m.timeCategory == 'morning').toList();
});

final afternoonMedsProvider = Provider<List<MedicationModel>>((ref) {
  final meds = ref.watch(medicationsProvider).valueOrNull ?? [];
  return meds.where((m) => m.timeCategory == 'afternoon').toList();
});

final eveningMedsProvider = Provider<List<MedicationModel>>((ref) {
  final meds = ref.watch(medicationsProvider).valueOrNull ?? [];
  return meds.where((m) => m.timeCategory == 'evening').toList();
});
