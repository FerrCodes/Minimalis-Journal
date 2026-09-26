import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final Color bgColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);
  final Color textPrimary = const Color(0xFFF2F2F7);
  final Color textSecondary = const Color(0xFF8E8E93);

  // Daftar mood dan nilainya (untuk grafik)
  final List<Map<String, dynamic>> _moods = [
    {'label': 'Calm', 'value': 4, 'icon': Icons.wb_sunny_outlined},
    {'label': 'Grateful', 'value': 3, 'icon': Icons.favorite_border},
    {'label': 'Peaceful', 'value': 2, 'icon': Icons.cloud_outlined},
    {'label': 'Focused', 'value': 1, 'icon': Icons.eco_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<JournalEntry>('journalBox');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Statistik',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<JournalEntry> box, _) {
          final entries = box.values.toList();

          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bar_chart_outlined,
                    size: 64,
                    color: textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tulis jurnal pertamamu untuk\nmelihat statistik di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }

          // === HITUNG DATA STATISTIK ===
          final totalEntries = entries.length;

          // Hitung jumlah per mood
          final moodCounts = <String, int>{};
          for (var mood in _moods) {
            moodCounts[mood['label']] = entries
                .where((e) => e.mood == mood['label'])
                .length;
          }

          // Cari mood yang paling sering
          String topMood = 'Calm';
          int topCount = 0;
          moodCounts.forEach((mood, count) {
            if (count > topCount) {
              topCount = count;
              topMood = mood;
            }
          });

          // Hitung jurnal minggu ini
          final now = DateTime.now();
          final weekAgo = now.subtract(const Duration(days: 7));
          final thisWeekCount = entries.where((e) {
            try {
              final entryDate = DateFormat('MMM d, yyyy').parse(e.date);
              return entryDate.isAfter(weekAgo);
            } catch (_) {
              return false;
            }
          }).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === KARTU RINGKASAN ===
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.auto_stories_outlined,
                        value: '$totalEntries',
                        label: 'Total Jurnal',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.calendar_today_outlined,
                        value: '$thisWeekCount',
                        label: 'Minggu Ini',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // === SECTION: GRAFIK MOOD ===
                Text(
                  'Distribusi Mood',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY:
                                (moodCounts.values.reduce(
                                          (a, b) => a > b ? a : b,
                                        ) +
                                        1)
                                    .toDouble(),
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < _moods.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          _moods[index]['label'],
                                          style: TextStyle(
                                            color: textSecondary,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(_moods.length, (index) {
                              final mood = _moods[index]['label'];
                              final count = moodCounts[mood] ?? 0;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: count.toDouble(),
                                    color: textPrimary,
                                    width: 24,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // === SECTION: MOOD TERBANYAK ===
                Text(
                  'Mood Terbanyak',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: textPrimary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _moods.firstWhere(
                            (m) => m['label'] == topMood,
                          )['icon'],
                          color: textPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topMood,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$topCount jurnal dengan mood ini',
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // === SECTION: RINCIAN PER MOOD ===
                Text(
                  'Rincian Mood',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ..._moods.map((mood) {
                  final count = moodCounts[mood['label']] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(mood['icon'], color: textPrimary, size: 20),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              mood['label'],
                              style: TextStyle(
                                fontSize: 14,
                                color: textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textSecondary, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 13, color: textSecondary)),
        ],
      ),
    );
  }
}
