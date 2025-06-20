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
    final prefs = await SharedPreferences.getInstance();

    final total = prefs.getInt(_totalKey);
    final dailyJson = prefs.getString(_dailyKey); // Fixed key name here

    Map<String, int> daily = {};
    if (dailyJson != null) {
      try {
        final decoded = json.decode(dailyJson);
        daily = Map<String, int>.from(decoded);
      } catch (e) {
        print("Error decoding daily points: $e");
        // Continue with empty map if there's an error
      }
    }

    return PlayerState(totalPoints: total ?? 0, dailyPoints: daily);
  }

  /// Save current state to shared preferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalKey, totalPoints);
    await prefs.setString(_dailyKey, json.encode(dailyPoints));

    print("✅ Saved: $totalPoints - $dailyPoints"); // for debug
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
