import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer player = AudioPlayer();
  bool isInitialized = false;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  Future<void> initialize() async {
    if (isInitialized) return;

    try {
      await player.setLoopMode(LoopMode.all);
      final prefs = await SharedPreferences.getInstance();
      final track = prefs.getString('selectedTrack');
      final volume = prefs.getDouble('volume') ?? 0.5;

      if (track != null && track != 'None') {
        // Check if the asset exists
        try {
          final assetPath = 'assets/music/$track';
          print("Trying to load asset: $assetPath");

          // Try to load the asset to verify it exists
          await rootBundle.load(assetPath);

          // If we get here, the asset exists
          await player.setAsset(assetPath);
          await player.setVolume(volume);
          player.play();
        } catch (e) {
          print("Error loading asset: $e");
          // Reset the track preference if the asset doesn't exist
          await prefs.setString('selectedTrack', 'None');
        }
      }

      isInitialized = true;
    } catch (e) {
      print("Error initializing audio service: $e");
    }
  }

  Future<void> playTrack(String track, double volume) async {
    try {
      if (track == 'None') {
        await player.stop();
        return;
      }

      final assetPath = 'assets/music/$track';
      print("Trying to play asset: $assetPath");

      // Try to load the asset to verify it exists
      await rootBundle.load(assetPath);

      await player.setAsset(assetPath);
      await player.setVolume(volume);
      await player.setLoopMode(LoopMode.all);
      player.play();
    } catch (e) {
      print("Error playing track: $e");
    }
  }

  Future<void> setVolume(double volume) async {
    await player.setVolume(volume);
  }

  void dispose() {
    player.dispose();
  }
}
