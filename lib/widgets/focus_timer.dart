import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/focus_duration_modal.dart';

class FocusTimer extends StatefulWidget {
  final TimerSettings settings;
  final Function(Duration) onCompleted;

  const FocusTimer({
    Key? key,
    required this.settings,
    required this.onCompleted,
  }) : super(key: key);

  @override
  _FocusTimerState createState() => _FocusTimerState();
}

class _FocusTimerState extends State<FocusTimer> with WidgetsBindingObserver {
  late int remainingSeconds;
  Timer? timer;
  bool isPause = false;
  int currentInterval = 1;
  late Duration totalFocusDuration;
  DateTime? _endTime; // When timer should end
  int? _pausedTimeRemaining; // Store remaining seconds when paused

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    totalFocusDuration = Duration.zero;

    if (widget.settings.type == TimerType.standard) {
      remainingSeconds = widget.settings.focusDuration.inSeconds;
    } else {
      remainingSeconds = widget.settings.focusDuration.inSeconds;
      isPause = false;
      currentInterval = 1;
    }

    // Set end time based on current time + remaining seconds
    _endTime = DateTime.now().add(Duration(seconds: remainingSeconds));
    startTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground - recalculate remaining time
      if (_endTime != null) {
        final now = DateTime.now();
        if (now.isBefore(_endTime!)) {
          // Timer still running
          setState(() {
            remainingSeconds = _endTime!.difference(now).inSeconds;
          });
        } else {
          // Timer completed while in background
          handleTimerCompletion();
        }
      }
      startTimer(); // Restart the UI update timer
    } else if (state == AppLifecycleState.paused) {
      // App went to background - save state and stop UI timer
      timer?.cancel();
      // Save end time to SharedPreferences if needed for longer background periods
    }
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final now = DateTime.now();
      if (_endTime != null && now.isAfter(_endTime!)) {
        handleTimerCompletion();
      } else {
        setState(() {
          remainingSeconds = _endTime!.difference(now).inSeconds;
        });
      }
    });
  }

  void handleTimerCompletion() {
    // Handle interval completion logic
    if (widget.settings.type == TimerType.pomodoro) {
      if (isPause) {
        // Pause interval completed
        currentInterval++;

        if (currentInterval > widget.settings.repetitions) {
          // All intervals completed
          timer?.cancel();
          widget.onCompleted(totalFocusDuration);
          return;
        }

        // Start next focus interval
        setState(() {
          isPause = false;
          remainingSeconds = widget.settings.focusDuration.inSeconds;
          _endTime = DateTime.now().add(Duration(seconds: remainingSeconds));
        });
      } else {
        // Focus interval completed
        // Add to total focus duration
        totalFocusDuration += widget.settings.focusDuration;

        // Check if this was the last focus interval
        if (currentInterval == widget.settings.repetitions) {
          // Last focus interval completed, end the timer
          timer?.cancel();
          widget.onCompleted(totalFocusDuration);
          return;
        }

        // Start pause interval
        setState(() {
          isPause = true;
          remainingSeconds = widget.settings.pauseDuration.inSeconds;
          _endTime = DateTime.now().add(Duration(seconds: remainingSeconds));
        });
      }
    } else {
      // Standard timer completed
      timer?.cancel();
      widget.onCompleted(widget.settings.focusDuration);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _pauseTimer() {
    if (timer?.isActive == true) {
      timer?.cancel();
      setState(() {
        // Save the current end time for later resuming
        _pausedTimeRemaining = remainingSeconds;
      });
    }
  }

  void _resumeTimer() {
    if (timer?.isActive != true && _pausedTimeRemaining != null) {
      // Recalculate end time based on remaining time
      _endTime = DateTime.now().add(Duration(seconds: _pausedTimeRemaining!));
      startTimer();
    }
  }

  void _breakTimer() {
    // Calculate how much time was spent focusing
    Duration focusedTime;

    if (widget.settings.type == TimerType.standard) {
      // For standard timer: calculate time spent based on original duration minus remaining time
      focusedTime =
          widget.settings.focusDuration - Duration(seconds: remainingSeconds);
    } else {
      // For pomodoro: calculate based on completed intervals and current progress
      int completedFocusIntervals = currentInterval - 1;
      if (!isPause) {
        // Add partial progress from current focus interval
        Duration currentIntervalProgress =
            widget.settings.focusDuration - Duration(seconds: remainingSeconds);
        focusedTime =
            Duration(
              seconds:
                  completedFocusIntervals *
                  widget.settings.focusDuration.inSeconds,
            ) +
            currentIntervalProgress;
      } else {
        // If in pause interval, just count completed focus intervals
        focusedTime = Duration(
          seconds:
              completedFocusIntervals * widget.settings.focusDuration.inSeconds,
        );
      }
    }

    // Only award points if some time was spent focusing
    if (focusedTime.inSeconds > 0) {
      timer?.cancel();
      widget.onCompleted(focusedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          '$minutes:$seconds',
          style: TextStyle(
            fontSize: 48,
            color: isPause
                ? theme.colorScheme.secondary
                : theme.colorScheme.primary,
          ),
        ),
        if (widget.settings.type == TimerType.pomodoro) ...[
          const SizedBox(height: 8),
          Text(
            isPause ? 'PAUSE' : 'FOCUS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPause
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Interval $currentInterval of ${widget.settings.repetitions}',
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: timer?.isActive == true ? _pauseTimer : _resumeTimer,
              icon: Icon(
                timer?.isActive == true ? Icons.pause : Icons.play_arrow,
              ),
              label: Text(timer?.isActive == true ? 'Pause' : 'Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.cardColor,
                foregroundColor: timer?.isActive == true
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _breakTimer,
              icon: const Icon(Icons.stop),
              label: const Text('Break'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.cardColor,
                foregroundColor: theme.colorScheme.error ?? Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
