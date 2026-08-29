import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class ScanCooldownStatus {
  final int usedScans;
  final int maxScans;
  final bool isCoolingDown;
  final Duration remainingTime;

  const ScanCooldownStatus({
    required this.usedScans,
    required this.maxScans,
    required this.isCoolingDown,
    required this.remainingTime,
  });

  int get remainingScans => max(0, maxScans - usedScans);

  String get formattedRemainingTime {
    final totalSeconds = max(0, remainingTime.inSeconds);
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class ScanCooldownService {
  ScanCooldownService._();

  static const int maxScans = 5;
  static const Duration cooldownDuration = Duration(minutes: 5);

  static const String _keyScanCount = 'ai_scanner_successful_scans';
  static const String _keyCooldownUntil = 'ai_scanner_cooldown_until';

  /// Returns current cooldown and remaining scan status.
  static Future<ScanCooldownStatus> getStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final count = prefs.getInt(_keyScanCount) ?? 0;
    final cooldownIso = prefs.getString(_keyCooldownUntil);

    if (cooldownIso != null) {
      final cooldownUntil = DateTime.tryParse(cooldownIso);
      if (cooldownUntil != null) {
        final now = DateTime.now();
        if (now.isBefore(cooldownUntil)) {
          // Cooldown is actively ticking
          return ScanCooldownStatus(
            usedScans: maxScans,
            maxScans: maxScans,
            isCoolingDown: true,
            remainingTime: cooldownUntil.difference(now),
          );
        } else {
          // Cooldown period has finished -> reset
          await prefs.setInt(_keyScanCount, 0);
          await prefs.remove(_keyCooldownUntil);
          return const ScanCooldownStatus(
            usedScans: 0,
            maxScans: maxScans,
            isCoolingDown: false,
            remainingTime: Duration.zero,
          );
        }
      }
    }

    // No active cooldown
    if (count >= maxScans) {
      // Reached limit, trigger cooldown starting now
      final cooldownUntil = DateTime.now().add(cooldownDuration);
      await prefs.setString(_keyCooldownUntil, cooldownUntil.toIso8601String());
      return ScanCooldownStatus(
        usedScans: maxScans,
        maxScans: maxScans,
        isCoolingDown: true,
        remainingTime: cooldownDuration,
      );
    }

    return ScanCooldownStatus(
      usedScans: count,
      maxScans: maxScans,
      isCoolingDown: false,
      remainingTime: Duration.zero,
    );
  }

  /// Records a successful prescription extraction.

  static Future<ScanCooldownStatus> recordSuccessfulScan() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if cooldown has already expired
    final currentStatus = await getStatus();
    int newCount = currentStatus.usedScans + 1;

    if (newCount >= maxScans) {
      final cooldownUntil = DateTime.now().add(cooldownDuration);
      await prefs.setInt(_keyScanCount, maxScans);
      await prefs.setString(_keyCooldownUntil, cooldownUntil.toIso8601String());
      return ScanCooldownStatus(
        usedScans: maxScans,
        maxScans: maxScans,
        isCoolingDown: true,
        remainingTime: cooldownDuration,
      );
    }

    await prefs.setInt(_keyScanCount, newCount);
    return ScanCooldownStatus(
      usedScans: newCount,
      maxScans: maxScans,
      isCoolingDown: false,
      remainingTime: Duration.zero,
    );
  }

  /// Manually reset cooldown
  static Future<void> resetCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyScanCount);
    await prefs.remove(_keyCooldownUntil);
  }
}
