import 'package:flutter/material.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

import 'statistics_screen.dart';
import 'achievements_screen.dart';
import '../player_state.dart';
import '../widgets/focus_timer.dart';
import '../widgets/focus_duration_modal.dart';

class FocusScreen extends StatefulWidget {
  final PlayerState state;

  const FocusScreen({super.key, required this.state});

  @override
  _FocusScreenState createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  late PlayerState _playerState;
  int points = 0;
  int lastPoints = 0;
  bool isSessionActive = false;
  Duration selectedDuration = const Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    _playerState = widget.state;
    points = widget.state.totalPoints;
  }

  Future<void> _onFocusCompleted(Duration duration) async {
    final earnedPoints = 10 * duration.inMinutes;

    // Update points locally first
    setState(() {
      lastPoints = earnedPoints;
      points += earnedPoints;
      isSessionActive = false;
    });

    // 🧠 Show the dialog BEFORE the await
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Great job!'),
        content: Text('You earned $earnedPoints points.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    final updated = await _playerState.addPoints(earnedPoints);
    if (!mounted) return;
    setState(() {
      _playerState = updated;
      points = updated.totalPoints;
    });
  }

  void _showTimePickerModal() {
    showFocusDurationModal(
      context: context,
      currentDuration: selectedDuration,
      onDurationSelected: (Duration duration) {
        setState(() {
          selectedDuration = duration;
          isSessionActive = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('L.I.B.R.E'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => print("Menu tapped"),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatisticsScreen(state: _playerState),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AchievementsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag),
            onPressed: () => print("Shop tapped"),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => print("Settings tapped"),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🌊 Violet wave animation background
          RepaintBoundary(
            child: Positioned.fill(
              child: WaveWidget(
                config: CustomConfig(
                  gradients: [
                    [
                      const Color.fromARGB(255, 38, 26, 88),
                      const Color.fromARGB(255, 40, 23, 88),
                    ],
                  ],
                  durations: [30000],
                  heightPercentages: [0.5],
                  blur: const MaskFilter.blur(BlurStyle.solid, 1),
                  gradientBegin: Alignment.bottomLeft,
                  gradientEnd: Alignment.topRight,
                ),
                backgroundColor: const Color(0xFF1C1B33),
                waveAmplitude: 10,
                size: screenSize,
              ),
            ),
          ),

          // 🧠 Main focus UI
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Focus Points: $points',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 40),
                if (isSessionActive)
                  FocusTimer(
                    duration: selectedDuration,
                    onCompleted: () => _onFocusCompleted(selectedDuration),
                  )
                else
                  ElevatedButton(
                    onPressed: _showTimePickerModal,
                    child: const Text('Start Focus Session'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
