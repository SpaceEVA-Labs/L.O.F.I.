import 'package:flutter/material.dart';

class AchievementsScreen extends StatefulWidget {
  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Achievements')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Home'),
        ),
      ),
    );
  }
}
