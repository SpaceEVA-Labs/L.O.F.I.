import 'package:flutter/material.dart';
import '../widgets/focus_timer.dart';

class FocusScreen extends StatefulWidget {
  @override
  _FocusScreenState createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  int points = 0;
  bool isSessionActive = false;

  void _onFocusCompleted() {
    setState(() {
      points += 10;
      isSessionActive = false;
    });
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Great job!'),
        content: const Text('You earned 10 points.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startSession() {
    setState(() {
      isSessionActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('L.I.B.R.E')),
      body: Center(
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
                duration: const Duration(minutes: 1),
                onCompleted: _onFocusCompleted,
              )
            else
              ElevatedButton(
                onPressed: _startSession,
                child: const Text('Start Focus Session'),
              ),
          ],
        ),
      ),
    );
  }
}
