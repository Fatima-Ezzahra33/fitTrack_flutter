import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/weight_entry_model.dart';

/// Mini weight trend chart for the Home Dashboard.
/// Renders a small curve from real SQLite weight entries (last 7 days).
class WeightMiniChart extends StatelessWidget {
  final List<WeightEntry> entries;

  const WeightMiniChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'Aucune donnée de poids',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Take last 7 entries sorted by date ascending
    final sorted = List<WeightEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    final display = sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted;

    final spots = <FlSpot>[];
    for (int i = 0; i < display.length; i++) {
      spots.add(FlSpot(i.toDouble(), display[i].weight));
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;

    return SizedBox(
      height: 80,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: display.length == 1 ? 1.0 : (display.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: display.length > 1,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: display.length > 1,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }
}
