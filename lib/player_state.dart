import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerState {
  final int totalPoints;
  final Map<String, int> dailyPoints;

  PlayerState({required this.totalPoints, required this.dailyPoints});

  // Use a named factory constructor instead of a default one
  factory PlayerState.empty() {
    return PlayerState(totalPoints: 0, dailyPoints: {});
  }

  factory PlayerState.initial() => PlayerState(totalPoints: 0, dailyPoints: {});

  static const _totalKey = 'total_points';
  static const _dailyKey = 'daily_points';

  /// Load state from shared preferences
  static Future<PlayerState> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final total = prefs.getInt(_totalKey);
      final dailyJson = prefs.getString(_dailyKey);

      Map<String, int> daily = {};
      if (dailyJson != null) {
        try {
          final decoded = json.decode(dailyJson);
          // Convert the decoded map to the correct type
          daily = Map<String, int>.from(
            decoded.map((key, value) => MapEntry(key, value as int)),
          );
        } catch (e) {
          print("Error decoding daily points: $e");
          // Try to recover from backup if available
          final backupJson = prefs.getString('${_dailyKey}_backup');
          if (backupJson != null) {
            try {
              final decoded = json.decode(backupJson);
              daily = Map<String, int>.from(
                decoded.map((key, value) => MapEntry(key, value as int)),
              );
              print("Recovered daily points from backup");
            } catch (e) {
              print("Error recovering from backup: $e");
            }
          }
        }
      }

      return PlayerState(totalPoints: total ?? 0, dailyPoints: daily);
    } catch (e) {
      print("Critical error loading player state: $e");
      return PlayerState.empty();
    }
  }

  /// Save current state to shared preferences
  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_totalKey, totalPoints);

      // Ensure we're encoding a valid Map<String, int>
      final encodedDaily = json.encode(dailyPoints);
      await prefs.setString(_dailyKey, encodedDaily);

      // Create a backup of the daily points
      await prefs.setString('${_dailyKey}_backup', encodedDaily);

      print("✅ Saved: $totalPoints - $dailyPoints");
    } catch (e) {
      print("Error saving player state: $e");
    }
  }

  /// Add points and return a new PlayerState
  Future<PlayerState> addPoints(int amount) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final updatedDaily = Map<String, int>.from(dailyPoints);
    updatedDaily[today] = (updatedDaily[today] ?? 0) + amount;

    final newState = PlayerState(
      totalPoints: totalPoints + amount,
      dailyPoints: updatedDaily,
    );
    await newState.save();
    return newState;
  }
}
