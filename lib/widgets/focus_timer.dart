import 'dart:async';
import 'package:flutter/material.dart';
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

class _FocusTimerState extends State<FocusTimer> {
  late int remainingSeconds;
  Timer? timer;
  bool isPause = false;
  int currentInterval = 1;
  late Duration totalFocusDuration;

  @override
  void initState() {
    super.initState();
    totalFocusDuration = Duration.zero;

    if (widget.settings.type == TimerType.standard) {
      remainingSeconds = widget.settings.focusDuration.inSeconds;
    } else {
      // Start with focus interval
      remainingSeconds = widget.settings.focusDuration.inSeconds;
      isPause = false;
      currentInterval = 1;
    }

    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds == 0) {
        // Handle interval completion
        if (widget.settings.type == TimerType.tanimoto) {
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
            });
          } else {
            // Focus interval completed
            // Add to total focus duration
            totalFocusDuration += widget.settings.focusDuration;

            // Start pause interval
            setState(() {
              isPause = true;
              remainingSeconds = widget.settings.pauseDuration.inSeconds;
            });
          }
        } else {
          // Standard timer completed
          timer?.cancel();
          widget.onCompleted(widget.settings.focusDuration);
        }
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
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
        if (widget.settings.type == TimerType.tanimoto) ...[
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
