import 'dart:async';
import 'package:flutter/material.dart';

class FocusTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback onCompleted;

  const FocusTimer({required this.duration, required this.onCompleted});

  @override
  _FocusTimerState createState() => _FocusTimerState();
}

class _FocusTimerState extends State<FocusTimer> {
  late int remainingSeconds;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.duration.inSeconds;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds == 0) {
        widget.onCompleted();
        timer?.cancel();
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

    return Text(
      '$minutes:$seconds',
      style: const TextStyle(fontSize: 48, color: Colors.white),
    );
  }
}
