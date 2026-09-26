import 'package:flutter/material.dart';
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
  final Color accentYellow = const Color(0xFFFFD60A);

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Calm', 'icon': Icons.wb_sunny_outlined},
    {'label': 'Grateful', 'icon': Icons.favorite_border},
    {'label': 'Peaceful', 'icon': Icons.cloud_outlined},
    {'label': 'Focused', 'icon': Icons.eco_outlined},
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

          // === HITUNG DATA ===
          final totalEntries = entries.length;

          // Mood counts
          final moodCounts = <String, int>{};
          for (var mood in _moods) {
            moodCounts[mood['label']] = entries
                .where((e) => e.mood == mood['label'])
                .length;
          }

          // Top mood
          String topMood = 'Calm';
          int topCount = 0;
          moodCounts.forEach((mood, count) {
            if (count > topCount) {
              topCount = count;
              topMood = mood;
            }
          });

          // Jurnal minggu ini
          final now = DateTime.now();
          final weekAgo = now.subtract(const Duration(days: 7));
          final thisWeekCount = entries.where((e) {
            final d = _parseDate(e.date);
            return d != null && d.isAfter(weekAgo);
          }).length;

          // === HITUNG STREAK ===
          final streak = _calculateStreak(entries);

          // === DATA KALENDER (bulan ini) ===
          final nowMonth = DateTime.now().month;
          final nowYear = DateTime.now().year;
          final entriesThisMonth = entries.where((e) {
            final d = _parseDate(e.date);
            return d != null && d.month == nowMonth && d.year == nowYear;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === STREAK CARD ===
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentYellow.withValues(alpha: 0.2), cardColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: accentYellow.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accentYellow.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🔥', style: TextStyle(fontSize: 32)),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$streak Hari',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            streak == 0
                                ? 'Mulai streak hari ini!'
                                : 'Streak menulis jurnal',
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
                const SizedBox(height: 16),

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

                // === KALENDER MINI ===
                Text(
                  'Kalender Bulan Ini',
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
                  child: _buildMiniCalendar(entriesThisMonth),
                ),
                const SizedBox(height: 32),

                // === GRAFIK MINGGUAN ===
                Text(
                  '7 Hari Terakhir',
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
                  child: SizedBox(
                    height: 160,
                    child: _buildWeeklyChart(entries),
                  ),
                ),
                const SizedBox(height: 32),

                // === GRAFIK MOOD ===
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
                  child: SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY:
                            (moodCounts.values.reduce((a, b) => a > b ? a : b) +
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
                ),
                const SizedBox(height: 32),

                // === MOOD TERBANYAK ===
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
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // === HELPER: PARSE DATE ===
  DateTime? _parseDate(String dateStr) {
    try {
      return DateFormat('MMM d, yyyy').parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  // === HELPER: HITUNG STREAK ===
  int _calculateStreak(List<JournalEntry> entries) {
    if (entries.isEmpty) return 0;

    // Kumpulkan tanggal unik (tanpa jam)
    final Set<DateTime> uniqueDays = {};
    for (var entry in entries) {
      final d = _parseDate(entry.date);
      if (d != null) {
        uniqueDays.add(DateTime(d.year, d.month, d.day));
      }
    }

    if (uniqueDays.isEmpty) return 0;

    // Urutkan dari terbaru
    final sortedDays = uniqueDays.toList()..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    // Kalau jurnal terakhir bukan hari ini atau kemarin, streak = 0
    if (sortedDays.first != todayDate && sortedDays.first != yesterday) {
      return 0;
    }

    // Hitung streak berurutan
    int streak = 1;
    for (int i = 0; i < sortedDays.length - 1; i++) {
      final diff = sortedDays[i].difference(sortedDays[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // === HELPER: KALENDER MINI ===
  Widget _buildMiniCalendar(List<JournalEntry> entriesThisMonth) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday; // 1 = Senin, 7 = Minggu

    // Kumpulkan tanggal yang ada jurnalnya
    final Set<int> daysWithEntries = {};
    for (var entry in entriesThisMonth) {
      final d = _parseDate(entry.date);
      if (d != null) daysWithEntries.add(d.day);
    }

    // Urutan: Senin-Minggu
    final dayLabelsOrdered = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    return Column(
      children: [
        // Label hari
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayLabelsOrdered.map((day) {
            return SizedBox(
              width: 32,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Grid tanggal
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: (startWeekday - 1) + daysInMonth,
          itemBuilder: (context, index) {
            // Hari kosong sebelum tanggal 1
            if (index < startWeekday - 1) {
              return const SizedBox();
            }
            final day = index - (startWeekday - 1) + 1;
            final hasEntry = daysWithEntries.contains(day);
            final isToday = day == now.day;

            return Container(
              decoration: BoxDecoration(
                color: hasEntry ? textPrimary : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday && !hasEntry
                    ? Border.all(
                        color: textPrimary.withValues(alpha: 0.5),
                        width: 1,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: hasEntry || isToday
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: hasEntry
                        ? bgColor
                        : (isToday ? textPrimary : textSecondary),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // === HELPER: GRAFIK MINGGUAN ===
  Widget _buildWeeklyChart(List<JournalEntry> entries) {
    final now = DateTime.now();
    final List<DateTime> last7Days = List.generate(7, (i) {
      return DateTime(now.year, now.month, now.day - (6 - i));
    });

    // Hitung jumlah jurnal per hari
    final List<int> counts = last7Days.map((day) {
      return entries.where((e) {
        final d = _parseDate(e.date);
        if (d == null) return false;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      }).length;
    }).toList();

    final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (counts.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < last7Days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dayNames[last7Days[index].weekday - 1],
                      style: TextStyle(color: textSecondary, fontSize: 10),
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
        barGroups: List.generate(last7Days.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: counts[index].toDouble(),
                color: counts[index] > 0
                    ? textPrimary
                    : textSecondary.withValues(alpha: 0.3),
                width: 20,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }),
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
