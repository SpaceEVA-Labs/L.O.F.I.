import 'package:flutter/material.dart';

// Existing violet lofi theme
final ThemeData violetLofiTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF1C1B33),
  primaryColor: Colors.deepPurpleAccent,
  cardColor: const Color(0xFF2A2747),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurpleAccent,
    brightness: Brightness.dark,
    primary: Colors.deepPurpleAccent,
    secondary: const Color(0xFFB39DDB),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white70),
    headlineMedium: TextStyle(color: Colors.white, fontSize: 32),
  ),
);

// Existing matcha green lofi theme
final ThemeData matchaGreenLofiTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF162315), // Deep matcha-dark base
  primaryColor: const Color(0xFF6DBE45), // Vivid spring green
  cardColor: const Color(0xFF21371E), // Rich forest green
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6DBE45),
    brightness: Brightness.dark,
    primary: const Color(0xFF6DBE45),
    secondary: const Color(0xFF9FDA63),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFFBCE7A1)), // Bright herbaceous green
    headlineMedium: TextStyle(
      color: Color(0xFF9FDA63), // Leafy green with energy
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
  ),
);

// New coffee lofi theme
final ThemeData coffeeLofiTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF1A1310), // Deep coffee bean brown
  primaryColor: const Color(0xFFAF7E57), // Warm caramel
  cardColor: const Color(0xFF2C211B), // Rich espresso
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFAF7E57),
    brightness: Brightness.dark,
    primary: const Color(0xFFAF7E57),
    secondary: const Color(0xFFD4B59E),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Color(0xFFE6D2C7)), // Creamy latte
    headlineMedium: TextStyle(
      color: Color(0xFFD4B59E), // Cappuccino foam
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
  ),
);

// Theme data class to store theme information
class ThemeOption {
  final String name;
  final ThemeData theme;
  final List<List<Color>> waveGradients;
  final Color waveBackground;

  const ThemeOption({
    required this.name,
    required this.theme,
    required this.waveGradients,
    required this.waveBackground,
  });
}

// Theme options
final List<ThemeOption> themeOptions = [
  ThemeOption(
    name: 'Violet Dream',
    theme: violetLofiTheme,
    waveGradients: [
      [
        const Color(0xFF4527A0), // Deep purple
        const Color(0xFF311B92), // Indigo
      ],
    ],
    waveBackground: const Color(0xFF1C1B33), // Dark violet base
  ),
  ThemeOption(
    name: 'Matcha Green',
    theme: matchaGreenLofiTheme,
    waveGradients: [
      [
        const Color(0xFF274C1B), // Deep leafy green
        const Color(0xFF1E3B15), // Earthy dark green
      ],
    ],
    waveBackground: const Color(0xFF162315), // Matcha dark base
  ),
  ThemeOption(
    name: 'Coffee Lofi',
    theme: coffeeLofiTheme,
    waveGradients: [
      [
        const Color(0xFF5D4037), // Deep coffee
        const Color(0xFF3E2723), // Dark espresso
      ],
    ],
    waveBackground: const Color(0xFF1A1310), // Coffee bean brown
  ),
];
