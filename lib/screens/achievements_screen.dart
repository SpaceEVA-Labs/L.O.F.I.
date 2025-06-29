import 'package:flutter/material.dart';
import '../player_state.dart';

class Achievement {
  final String title;
  final String description;
  final int pointsRequired;
  final IconData icon;

  const Achievement({
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.icon,
  });
}

class AchievementsScreen extends StatefulWidget {
  final PlayerState? state;

  const AchievementsScreen({Key? key, this.state}) : super(key: key);

  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late final List<Achievement> achievements;
  late int totalPoints;

  @override
  void initState() {
    super.initState();
    totalPoints = widget.state?.totalPoints ?? 0;

    // Define achievements
    achievements = [
      const Achievement(
        title: 'First Focus',
        description: 'Complete your first focus session',
        pointsRequired: 10,
        icon: Icons.play_circle_filled,
      ),
      const Achievement(
        title: 'Focus Novice',
        description: 'Earn 100 points',
        pointsRequired: 100,
        icon: Icons.star,
      ),
      const Achievement(
        title: 'Focus Apprentice',
        description: 'Earn 500 points',
        pointsRequired: 500,
        icon: Icons.star_half,
      ),
      const Achievement(
        title: 'Focus Master',
        description: 'Earn 1,000 points',
        pointsRequired: 1000,
        icon: Icons.stars,
      ),
      const Achievement(
        title: 'Focus Grandmaster',
        description: 'Earn 5,000 points',
        pointsRequired: 5000,
        icon: Icons.workspace_premium,
      ),
      const Achievement(
        title: 'Focus Legend',
        description: 'Earn 10,000 points',
        pointsRequired: 10000,
        icon: Icons.military_tech,
      ),
      const Achievement(
        title: 'Daily Dedication',
        description: 'Earn 300 points in a single day',
        pointsRequired: 300,
        icon: Icons.calendar_today,
      ),
      const Achievement(
        title: 'Long Session',
        description: 'Complete a 60-minute focus session',
        pointsRequired: 600,
        icon: Icons.hourglass_full,
      ),
    ];
  }

  bool _isAchievementUnlocked(Achievement achievement) {
    return totalPoints >= achievement.pointsRequired;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Your Achievements',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Points: $totalPoints',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: achievements.length,
                        itemBuilder: (context, index) {
                          final achievement = achievements[index];
                          final isUnlocked = _isAchievementUnlocked(
                            achievement,
                          );

                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: isUnlocked
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    achievement.icon,
                                    size: 48,
                                    color: isUnlocked
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    achievement.title,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: isUnlocked
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimaryContainer
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withOpacity(0.7),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    achievement.description,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: isUnlocked
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimaryContainer
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withOpacity(0.7),
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${achievement.pointsRequired} points',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: isUnlocked
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimaryContainer
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withOpacity(0.7),
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Icon(
                                    isUnlocked ? Icons.lock_open : Icons.lock,
                                    size: 16,
                                    color: isUnlocked
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
