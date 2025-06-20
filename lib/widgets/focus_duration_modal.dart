import 'package:flutter/material.dart';

enum TimerType { standard, tanimoto }

class TimerSettings {
  final TimerType type;
  final Duration focusDuration;
  final Duration pauseDuration;
  final int repetitions;

  const TimerSettings({
    required this.type,
    required this.focusDuration,
    this.pauseDuration = Duration.zero,
    this.repetitions = 1,
  });

  Duration get totalDuration {
    if (type == TimerType.standard) {
      return focusDuration;
    } else {
      return Duration(
        seconds:
            (focusDuration.inSeconds + pauseDuration.inSeconds) * repetitions,
      );
    }
  }

  Duration get totalFocusDuration {
    if (type == TimerType.standard) {
      return focusDuration;
    } else {
      return Duration(seconds: focusDuration.inSeconds * repetitions);
    }
  }
}

Future<void> showFocusDurationModal({
  required BuildContext context,
  required Duration currentDuration,
  required Function(TimerSettings) onTimerSettingsSelected,
}) async {
  TimerType selectedType = TimerType.standard;
  Duration focusDuration = const Duration(minutes: 30); // Default 30 min
  Duration pauseDuration = const Duration(minutes: 5); // Default 5 min pause
  int repetitions = 4; // Default 4 repetitions

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allow the modal to be larger
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24.0),
            // Use at least 80% of screen height to accommodate all content
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Focus Timer Settings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Timer Type Selection
                const Text(
                  'Timer Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildSelectionCard(
                        context: context,
                        title: 'Standard',
                        description: 'Single focus session',
                        icon: Icons.timer,
                        isSelected: selectedType == TimerType.standard,
                        onTap: () {
                          setModalState(() {
                            selectedType = TimerType.standard;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSelectionCard(
                        context: context,
                        title: 'Tanimoto',
                        description: 'Alternating focus and pause intervals',
                        icon: Icons.repeat,
                        isSelected: selectedType == TimerType.tanimoto,
                        onTap: () {
                          setModalState(() {
                            selectedType = TimerType.tanimoto;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Make the settings section scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Standard Timer Settings
                        if (selectedType == TimerType.standard) ...[
                          const Text(
                            'Focus Duration',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Focus Duration Slider
                          Row(
                            children: [
                              const Text('1m'),
                              Expanded(
                                child: Slider(
                                  value: focusDuration.inMinutes.toDouble(),
                                  min: 1,
                                  max: 180, // 3 hours
                                  divisions: 179,
                                  label: '${focusDuration.inMinutes} min',
                                  onChanged: (value) {
                                    setModalState(() {
                                      focusDuration = Duration(
                                        minutes: value.round(),
                                      );
                                    });
                                  },
                                ),
                              ),
                              const Text('3h'),
                            ],
                          ),

                          Center(
                            child: Text(
                              '${focusDuration.inMinutes} minutes',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ]
                        // Tanimoto Timer Settings
                        else if (selectedType == TimerType.tanimoto) ...[
                          // Focus Interval
                          const Text(
                            'Focus Interval',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Text('5m'),
                              Expanded(
                                child: Slider(
                                  value: focusDuration.inMinutes.toDouble(),
                                  min: 5,
                                  max: 60, // 1 hour
                                  divisions: 55,
                                  label: '${focusDuration.inMinutes} min',
                                  onChanged: (value) {
                                    setModalState(() {
                                      focusDuration = Duration(
                                        minutes: value.round(),
                                      );
                                    });
                                  },
                                ),
                              ),
                              const Text('60m'),
                            ],
                          ),

                          Center(
                            child: Text(
                              'Focus: ${focusDuration.inMinutes} minutes',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Pause Interval
                          const Text(
                            'Pause Interval',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Text('1m'),
                              Expanded(
                                child: Slider(
                                  value: pauseDuration.inMinutes.toDouble(),
                                  min: 1,
                                  max: 30, // 30 minutes
                                  divisions: 29,
                                  label: '${pauseDuration.inMinutes} min',
                                  onChanged: (value) {
                                    setModalState(() {
                                      pauseDuration = Duration(
                                        minutes: value.round(),
                                      );
                                    });
                                  },
                                ),
                              ),
                              const Text('30m'),
                            ],
                          ),

                          Center(
                            child: Text(
                              'Pause: ${pauseDuration.inMinutes} minutes',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Repetitions
                          const Text(
                            'Repetitions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Text('1'),
                              Expanded(
                                child: Slider(
                                  value: repetitions.toDouble(),
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  label: '$repetitions',
                                  onChanged: (value) {
                                    setModalState(() {
                                      repetitions = value.round();
                                    });
                                  },
                                ),
                              ),
                              const Text('10'),
                            ],
                          ),

                          Center(
                            child: Text(
                              '$repetitions repetitions',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Total time calculation
                          Center(
                            child: Text(
                              'Total time: ${(focusDuration.inMinutes + pauseDuration.inMinutes) * repetitions} minutes',
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Focus time: ${focusDuration.inMinutes * repetitions} minutes',
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                          // Add extra space at the bottom for scrolling
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),

                // Add padding before the button
                const SizedBox(height: 16),

                // Start Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final settings = TimerSettings(
                        type: selectedType,
                        focusDuration: focusDuration,
                        pauseDuration: pauseDuration,
                        repetitions: repetitions,
                      );
                      onTimerSettingsSelected(settings);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Start Focus Session',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildSelectionCard({
  required BuildContext context,
  required String title,
  required String description,
  required IconData icon,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Theme.of(context).primaryColor : null,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
