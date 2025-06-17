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

    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final value = entry.value.toDouble();

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              width: 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );

      // For weekly: weekday label, yearly: month label, monthly: only every 5th day starting from 5
      if (_selectedView == TimeView.weekly) {
        final weekday = DateFormat.E('en_US').format(entry.key);
        labels.add(weekday.substring(0, 2)); // Mo, Tu, etc.
      } else if (_selectedView == TimeView.yearly) {
        labels.add(DateFormat.MMM('en_US').format(entry.key)); // Jan, Feb, ...
      } else if (_selectedView == TimeView.monthly) {
        // Only label days that are divisible by 5 and >= 5
        if (entry.key.day % 5 == 0 && entry.key.day >= 5) {
          labels.add('${entry.key.day}');
        } else {
          labels.add(''); // Empty label for non-5-multiple days
        }
      }
    }

    final maxY = barGroups
        .map((g) => g.barRods[0].toY)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final double chartMaxY = maxY > 300 ? maxY + 50 : 350;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                Row(
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
                const SizedBox(height: 8),
                Text(
                  _formatPeriod(_anchorDate, _selectedView),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: BarChart(
                BarChartData(
                  maxY: chartMaxY,
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index < 0 || index >= labels.length)
                            return const SizedBox.shrink();
                          // Only show labels that are not empty (monthly: only every 5th day)
                          if (labels[index].isEmpty)
                            return const SizedBox.shrink();
                          return Text(
                            labels[index],
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 50,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    drawVerticalLine: true,
                    horizontalInterval: 50,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                        dashArray: null,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                        dashArray: null,
                      );
                    },
                  ),
                  extraLinesData: _selectedView == TimeView.yearly
                      ? ExtraLinesData(horizontalLines: [])
                      : ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: 300,
                              color: Colors.red,
                              strokeWidth: 2,
                              dashArray: null,
                              label: HorizontalLineLabel(
                                show: true,
                                alignment: Alignment.centerRight,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                labelResolver: (_) => 'Goal: 300',
                              ),
                            ),
                          ],
                        ),
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

  String _formatPeriod(DateTime anchor, TimeView view) {
    final formatter = DateFormat('MMM dd, yyyy');
    switch (view) {
      case TimeView.weekly:
        final end = _getPeriodEnd(anchor, view);
        return '${formatter.format(anchor)} - ${formatter.format(end)}';
      case TimeView.monthly:
        return DateFormat('MMMM yyyy').format(anchor);
      case TimeView.yearly:
        return DateFormat('yyyy').format(anchor);
    }
  }

  List<MapEntry<DateTime, int>> _getFilteredEntries() {
    // final originalMap = widget.state.dailyPoints.map((k, v) => MapEntry(DateTime.parse(k), v));

    final rawMap = {
      '2025-06-10': 200,
      '2025-06-11': 500,
      '2025-06-13': 250,
      '2025-06-15': 400,
      '2025-07-15': 300,
    };

    final raw = rawMap.map((k, v) {
      final dt = DateTime.parse(k);
      return MapEntry(DateTime(dt.year, dt.month, dt.day), v);
    });

    final Map<DateTime, int> grouped = {};

    switch (_selectedView) {
      case TimeView.weekly:
        DateTime start = _getPeriodStart(_anchorDate, _selectedView);
        for (int i = 0; i < 7; i++) {
          final date = start.add(Duration(days: i));
          grouped[date] = raw[date] ?? 0;
        }
        break;

      case TimeView.monthly:
        DateTime start = _getPeriodStart(_anchorDate, _selectedView);
        DateTime end = _getPeriodEnd(start, _selectedView);
        for (
          DateTime day = start;
          !day.isAfter(end);
          day = day.add(const Duration(days: 1))
        ) {
          grouped[day] = raw[day] ?? 0;
        }
        break;

      case TimeView.yearly:
        for (int month = 1; month <= 12; month++) {
          final monthKey = DateTime(_anchorDate.year, month);
          final monthSum = raw.entries
              .where(
                (e) => e.key.year == _anchorDate.year && e.key.month == month,
              )
              .fold(0, (sum, e) => sum + e.value);
          grouped[monthKey] = monthSum;
        }
        break;
    }

    return grouped.entries.toList();
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
