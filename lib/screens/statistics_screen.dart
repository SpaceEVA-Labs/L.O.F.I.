import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../player_state.dart'; // access PlayerState

class StatisticsScreen extends StatelessWidget {
  final PlayerState state;

  const StatisticsScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    //final entries = state.dailyPoints.entries.toList()
    //  ..sort((a, b) => a.key.compareTo(b.key)); // sort by date

    // 🧪 Hardcoded daily points (date → points)
    final entries = [
      MapEntry('2025-06-10', 200),
      MapEntry('2025-06-11', 10),
      MapEntry('2025-06-12', 30),
      MapEntry('2025-06-13', 25),
      MapEntry('2025-06-14', 15),
      MapEntry('2025-06-15', 40),
    ];

    final spots = <FlSpot>[];
    final labels = <String>[];

    for (int i = 0; i < entries.length; i++) {
      final date = entries[i].key.substring(5); // e.g., MM-DD
      final points = entries[i].value.toDouble();

      spots.add(FlSpot(i.toDouble(), points));
      labels.add(date);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= labels.length)
                      return const SizedBox.shrink();
                    return Text(
                      labels[index],
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                  reservedSize: 32,
                  interval: 1,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10,
                  reservedSize: 40,
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            minY: 0,
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                spots: spots,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
