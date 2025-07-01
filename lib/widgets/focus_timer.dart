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

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');

    return Column(
      children: [
        Text(
          '$minutes:$seconds',
          style: TextStyle(
            fontSize: 48,
            color: isPause ? Colors.orange : Colors.white,
          ),
        ),
        if (widget.settings.type == TimerType.pomodoro) ...[
          const SizedBox(height: 8),
          Text(
            isPause ? 'PAUSE' : 'FOCUS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPause ? Colors.orange : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Interval $currentInterval of ${widget.settings.repetitions}',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ],
    );
  }
}
