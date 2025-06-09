import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerState {
  final int level;
  final int score;

  PlayerState({required this.level, required this.score});

  static PlayerState initial() {
    return PlayerState(level: 1, score: 0);
  }

  Map<String, dynamic> toJson() {
    return {'level': level, 'score': score};
  }

  static PlayerState fromJson(Map<String, dynamic> json) {
    return PlayerState(
      level: json['level'] as int,
      score: json['score'] as int,
    );
  }
}

Future<void> savePlayerState(PlayerState state) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = jsonEncode(state.toJson());
  await prefs.setString('player_state', jsonString);
}

Future<PlayerState?> loadPlayerState() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('player_state');
  if (jsonString == null) return null;

  final json = jsonDecode(jsonString);
  return PlayerState.fromJson(json);
}
