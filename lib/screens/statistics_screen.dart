import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../player_state.dart';

enum TimeView { weekly, monthly, yearly }

class StatisticsScreen extends StatefulWidget {
  final PlayerState state;

  const StatisticsScreen({super.key, required this.state});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  TimeView _selectedView = TimeView.weekly;
  late DateTime _anchorDate;

  @override
  void initState() {
    super.initState();
    _anchorDate = _getPeriodStart(DateTime.now(), _selectedView);
  }

  @override
  Widget build(BuildContext context) {
    final entries = _getFilteredEntries();

    final spots = <FlSpot>[];
    final labels = <String>[];

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      spots.add(FlSpot(i.toDouble(), entry.value.toDouble()));
      labels.add(DateFormat('MM-dd').format(entry.key));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _previousPeriod,
                  icon: const Icon(Icons.arrow_left),
                ),
                DropdownButton<TimeView>(
                  value: _selectedView,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedView = val;
                        _anchorDate = _getPeriodStart(
                          DateTime.now(),
                          _selectedView,
                        );
                      });
                    }
                  },
                  items: TimeView.values.map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(_viewLabel(e)),
                    );
                  }).toList(),
                ),
                IconButton(
                  onPressed: _nextPeriod,
                  icon: const Icon(Icons.arrow_right),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 32,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index < 0 || index >= labels.length)
                            return const SizedBox.shrink();
                          return Text(
                            labels[index],
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 10),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: false,
                      spots: spots,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previousPeriod() {
    setState(() {
      _anchorDate = _shiftPeriod(_anchorDate, _selectedView, -1);
    });
  }

  void _nextPeriod() {
    setState(() {
      _anchorDate = _shiftPeriod(_anchorDate, _selectedView, 1);
    });
  }

  List<MapEntry<DateTime, int>> _getFilteredEntries() {
    // final originalMap = widget.state.dailyPoints.map((k, v) => MapEntry(DateTime.parse(k), v));

    final rawMap = {
      '2025-06-10': 20,
      '2025-06-11': 10,
      '2025-06-13': 25,
      '2025-06-15': 40,
      '2025-07-15': 70,
    };

    // Normalize raw dates to just year/month/day
    final raw = rawMap.map((k, v) {
      final dt = DateTime.parse(k);
      return MapEntry(DateTime(dt.year, dt.month, dt.day), v);
    });

    final Map<DateTime, int> filled = {};
    DateTime start = _anchorDate;
    DateTime end = _getPeriodEnd(_anchorDate, _selectedView);
    DateTime current = start;

    while (!current.isAfter(end)) {
      filled[current] = raw[current] ?? 0;
      current = current.add(const Duration(days: 1));
    }

    return filled.entries.toList();
  }

  DateTime _getPeriodStart(DateTime from, TimeView view) {
    switch (view) {
      case TimeView.weekly:
        return DateTime(
          from.year,
          from.month,
          from.day,
        ).subtract(Duration(days: from.weekday - 1));
      case TimeView.monthly:
        return DateTime(from.year, from.month, 1);
      case TimeView.yearly:
        return DateTime(from.year, 1, 1);
    }
  }

  DateTime _getPeriodEnd(DateTime start, TimeView view) {
    switch (view) {
      case TimeView.weekly:
        return start.add(const Duration(days: 6));
      case TimeView.monthly:
        return DateTime(start.year, start.month + 1, 0);
      case TimeView.yearly:
        return DateTime(start.year, 12, 31);
    }
  }

  DateTime _shiftPeriod(DateTime anchor, TimeView view, int offset) {
    switch (view) {
      case TimeView.weekly:
        return anchor.add(Duration(days: 7 * offset));
      case TimeView.monthly:
        return DateTime(anchor.year, anchor.month + offset, 1);
      case TimeView.yearly:
        return DateTime(anchor.year + offset, 1, 1);
    }
  }

  String _viewLabel(TimeView view) {
    switch (view) {
      case TimeView.weekly:
        return 'Weekly';
      case TimeView.monthly:
        return 'Monthly';
      case TimeView.yearly:
        return 'Yearly';
    }
  }
}
