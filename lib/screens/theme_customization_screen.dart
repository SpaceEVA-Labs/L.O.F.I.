import 'package:flutter/material.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';
import '../theme.dart';

class ThemeCustomizationScreen extends StatefulWidget {
  final Function(ThemeOption) onThemeSelected;
  final ThemeOption currentTheme;

  const ThemeCustomizationScreen({
    super.key,
    required this.onThemeSelected,
    required this.currentTheme,
  });

  @override
  State<ThemeCustomizationScreen> createState() =>
      _ThemeCustomizationScreenState();
}

class _ThemeCustomizationScreenState extends State<ThemeCustomizationScreen> {
  late ThemeOption _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _selectedTheme.theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customize Theme'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            // Background wave animation
            Positioned.fill(
              child: WaveWidget(
                config: CustomConfig(
                  gradients: _selectedTheme.waveGradients,
                  durations: const [30000],
                  heightPercentages: const [0.5],
                  blur: const MaskFilter.blur(BlurStyle.solid, 1),
                  gradientBegin: Alignment.bottomLeft,
                  gradientEnd: Alignment.topRight,
                ),
                backgroundColor: _selectedTheme.waveBackground,
                waveAmplitude: 10,
                size: Size.infinite,
              ),
            ),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme selection title
                    Text(
                      'Select Your Theme',
                      style: _selectedTheme.theme.textTheme.headlineMedium
                          ?.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a theme that helps you focus and relax',
                      style: _selectedTheme.theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Theme options
                    Expanded(
                      child: ListView.builder(
                        itemCount: themeOptions.length,
                        itemBuilder: (context, index) {
                          final theme = themeOptions[index];
                          final isSelected = theme.name == _selectedTheme.name;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildThemeCard(theme, isSelected),
                          );
                        },
                      ),
                    ),

                    // Apply button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onThemeSelected(_selectedTheme);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedTheme.theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply Theme',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(ThemeOption theme, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTheme = theme;
        });
      },
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: theme.theme.cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.theme.primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Theme preview wave
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Opacity(
                  opacity: 0.5,
                  child: WaveWidget(
                    config: CustomConfig(
                      gradients: theme.waveGradients,
                      durations: const [20000],
                      heightPercentages: const [0.5],
                      blur: const MaskFilter.blur(BlurStyle.solid, 1),
                      gradientBegin: Alignment.bottomLeft,
                      gradientEnd: Alignment.topRight,
                    ),
                    backgroundColor: theme.waveBackground,
                    waveAmplitude: 10,
                    size: Size.infinite,
                  ),
                ),
              ),
            ),

            // Theme info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Theme color preview
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.theme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.color_lens,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Theme name and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          theme.name,
                          style: TextStyle(
                            color: theme.theme.textTheme.headlineMedium?.color,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getThemeDescription(theme.name),
                          style: TextStyle(
                            color: theme.theme.textTheme.bodyMedium?.color,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Selection indicator
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme.theme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeDescription(String themeName) {
    switch (themeName) {
      case 'Matcha Green':
        return 'Calm, natural tones inspired by Japanese matcha';
      case 'Violet Dream':
        return 'Relaxing purple hues for late night focus sessions';
      case 'Coffee Lofi':
        return 'Warm, cozy tones inspired by your favorite coffee shop';
      default:
        return '';
    }
  }
}
