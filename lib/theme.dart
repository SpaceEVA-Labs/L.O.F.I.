import 'package:flutter/material.dart';

final ThemeData violetLofiTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF1C1B33),
  primaryColor: Colors.deepPurpleAccent,
  cardColor: const Color(0xFF2A2747),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white70),
    headlineMedium: TextStyle(color: Colors.white, fontSize: 32),
  ),
);
