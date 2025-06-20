import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

import 'statistics_screen.dart';
import 'achievements_screen.dart';
import 'theme_customization_screen.dart';
import '../player_state.dart';
import '../widgets/focus_timer.dart';
import '../widgets/focus_duration_modal.dart';
import '../theme.dart';
import 'about_screen.dart';

class FocusScreen extends StatefulWidget {
  final PlayerState state;
  final ThemeOption themeOption;
  final Function(ThemeOption) onThemeChanged;

  const FocusScreen({
    super.key,
    required this.state,
    required this.themeOption,
    required this.onThemeChanged,
  });

  @override
  _FocusScreenState createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  late PlayerState _playerState;
  late ThemeOption _currentTheme;
  int points = 0;
  int dailyPoints = 0;
  int lastPoints = 0;
  bool isSessionActive = false;
  TimerSettings? currentTimerSettings;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _playerState = widget.state;
    _currentTheme = widget.themeOption;
    points = widget.state.totalPoints;
    _updateDailyPoints();
  }

  void _updateDailyPoints() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    dailyPoints = _playerState.dailyPoints[today] ?? 0;
  }

  Future<void> _onFocusCompleted(Duration focusDuration) async {
    final earnedPoints = 10 * focusDuration.inMinutes;

    // Update points locally first
    setState(() {
      lastPoints = earnedPoints;
      points += earnedPoints;
      dailyPoints += earnedPoints;
      isSessionActive = false;
      currentTimerSettings = null;
    });

    // Show the dialog BEFORE the await
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Great job!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You earned $earnedPoints points.'),
            const SizedBox(height: 10),
            Text('You focused for ${focusDuration.inMinutes} minutes!'),
          ],
        ),
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
      _updateDailyPoints();
    });
  }

  void _showTimePickerModal() {
    showFocusDurationModal(
      context: context,
      currentDuration: const Duration(minutes: 30), // Default 30 min
      onTimerSettingsSelected: (TimerSettings settings) {
        setState(() {
          currentTimerSettings = settings;
          isSessionActive = true;
        });
      },
    );
  }

  void _openThemeCustomization() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThemeCustomizationScreen(
          currentTheme: _currentTheme,
          onThemeSelected: (selectedTheme) {
            setState(() {
              _currentTheme = selectedTheme;
            });
            widget.onThemeChanged(selectedTheme);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('L.O.F.I'),
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
              MaterialPageRoute(
                builder: (context) => AchievementsScreen(state: _playerState),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _openThemeCustomization,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            ),
          ),
        ],
      ),
      body: Focus(
        focusNode: _focusNode,
        onFocusChange: (hasFocus) {},
        child: Stack(
          children: [
            // Wave animation background
            RepaintBoundary(
              child: Positioned.fill(
                child: WaveWidget(
                  config: CustomConfig(
                    gradients: _currentTheme.waveGradients,
                    durations: const [30000],
                    heightPercentages: const [0.5],
                    blur: const MaskFilter.blur(BlurStyle.solid, 1),
                    gradientBegin: Alignment.bottomLeft,
                    gradientEnd: Alignment.topRight,
                  ),
                  backgroundColor: _currentTheme.waveBackground,
                  waveAmplitude: 10,
                  size: screenSize,
                ),
              ),
            ),

            // Main focus UI
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Points display
                      SizedBox(
                        width: min(screenSize.width * 0.8, 400),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  'Total Points',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  '$points',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Today\'s Points',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  '$dailyPoints',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontSize: 24),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Focus timer or start button
                      if (isSessionActive && currentTimerSettings != null)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FocusTimer(
                              settings: currentTimerSettings!,
                              onCompleted: _onFocusCompleted,
                            ),
                            const SizedBox(height: 20),
                            if (currentTimerSettings!.type ==
                                TimerType.standard)
                              Text(
                                'Stay focused for ${currentTimerSettings!.focusDuration.inMinutes} minutes',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              )
                            else
                              Text(
                                'Tanimoto: ${currentTimerSettings!.focusDuration.inMinutes}m focus / ${currentTimerSettings!.pauseDuration.inMinutes}m pause × ${currentTimerSettings!.repetitions}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                          ],
                        )
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ready to focus?',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _showTimePickerModal,
                              icon: const Icon(Icons.timer),
                              label: const Text('Start Focus Session'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                      const Spacer(),

                      // Last session info
                      if (lastPoints > 0 && !isSessionActive)
                        SizedBox(
                          width: min(screenSize.width * 0.8, 400),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Last session: +$lastPoints points',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
