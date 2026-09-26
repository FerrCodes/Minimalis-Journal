import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/detail_screen.dart';
import 'screens/write_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/journal_entry.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Hive
  await Hive.initFlutter();

  // Daftarkan adapter
  Hive.registerAdapter(JournalEntryAdapter());

  // Buka "box" untuk menyimpan data
  await Hive.openBox<JournalEntry>('journalBox');
  await Hive.openBox('settingsBox'); // <-- TAMBAHKAN INI
  // Set status bar untuk dark mode (ikon putih)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark, // Set ke dark mode
        scaffoldBackgroundColor: const Color(0xFF121212), // Hitam soft
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class ReflectScreen extends StatefulWidget {
  const ReflectScreen({super.key});

  @override
  State<ReflectScreen> createState() => _ReflectScreenState();
}

class _ReflectScreenState extends State<ReflectScreen> {
  // State untuk pencarian & filter
  String _searchQuery = '';
  String? _selectedMoodFilter; // null = tampilkan semua

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Warna untuk dark mode
  final Color bgColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);
  final Color textPrimary = const Color(0xFFF2F2F7);
  final Color textSecondary = const Color(0xFF8E8E93);
  final Color accentColor = const Color(0xFFF2F2F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Reflect',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // === KOLOM PENCARIAN ===
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: textSecondary, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Cari jurnal...',
                                hintStyle: TextStyle(
                                  color: textSecondary.withValues(alpha: 0.5),
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: textSecondary,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // === FILTER MOOD ===
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Semua', null),
                          const SizedBox(width: 8),
                          _buildFilterChip('Favorit', 'FAVORITE'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Calm', 'Calm'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Grateful', 'Grateful'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Peaceful', 'Peaceful'),
                          const SizedBox(width: 8),
                          _buildFilterChip('Focused', 'Focused'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Quote
                    Text(
                      '"Small shifts in perspective can open the door to profound inner stillness."',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: textPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Journal Card
                    Text(
                      'Today\'s Entry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildJournalList(),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
          // === 2. FLOATING NAVIGATION BAR ===
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cardColor.withValues(
                    alpha: 0.95,
                  ), // Card color transparan
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.push(
                          context,
                          _slideRoute(const StatsScreen()),
                        );
                      },
                      icon: Icon(
                        Icons.bar_chart_outlined,
                        color: textSecondary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Tombol Plus (Besar di tengah)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          _slideRoute(const WriteScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: bgColor,
                          size: 26,
                        ), // Ikon hitam di tombol putih
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.push(
                          context,
                          _slideRoute(const SettingsScreen()),
                        );
                      },
                      icon: Icon(
                        Icons.settings_outlined,
                        color: textSecondary,
                        size: 26,
                      ),
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

  // Fungsi bantuan untuk animasi transisi
  Route _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildJournalList() {
    final box = Hive.box<JournalEntry>('journalBox');

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<JournalEntry> box, _) {
        if (box.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                'Belum ada jurnal. Buat baru sekarang.  ',
                style: TextStyle(color: textSecondary),
              ),
            ),
          );
        }

        // Ambil semua data, lalu filter
        final allEntries = box.values.toList().reversed.toList();

        final filteredEntries = allEntries.where((entry) {
          // Filter berdasarkan mood atau favorit
          if (_selectedMoodFilter != null) {
            if (_selectedMoodFilter == 'FAVORITE') {
              // Filter favorit
              if (!entry.isFavorite) return false;
            } else {
              // Filter mood biasa
              if (entry.mood != _selectedMoodFilter) return false;
            }
          }
          // Filter berdasarkan kata kunci
          if (_searchQuery.isNotEmpty) {
            final titleMatch = entry.title.toLowerCase().contains(_searchQuery);
            final contentMatch = entry.content.toLowerCase().contains(
              _searchQuery,
            );
            if (!titleMatch && !contentMatch) return false;
          }
          return true;
        }).toList();

        // Kalau hasil filter kosong, tampilkan pesan
        // Kalau hasil filter kosong, tampilkan pesan
        if (filteredEntries.isEmpty) {
          // Pesan khusus untuk filter favorit
          final isEmptyFavorite = _selectedMoodFilter == 'FAVORITE';
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(
                  isEmptyFavorite ? Icons.bookmark_border : Icons.search_off,
                  size: 48,
                  color: textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  isEmptyFavorite ? 'Belum ada favorit' : 'Tidak ada hasil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEmptyFavorite
                      ? 'Tap ikon bookmark di jurnal\nuntuk menandainya sebagai favorit.'
                      : 'Coba kata kunci lain atau ubah filter mood.',
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

        return Column(
          children: filteredEntries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Dismissible(
                key: Key(entry.key.toString()), // Key unik per entry
                direction:
                    DismissDirection.endToStart, // Swipe dari kanan ke kiri
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                confirmDismiss: (direction) async {
                  // Konfirmasi sebelum hapus
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                        'Hapus Jurnal?',
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: Text(
                        'Jurnal ini akan dihapus permanen dan tidak bisa dikembalikan.',
                        style: TextStyle(color: textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Batal',
                            style: TextStyle(color: textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  // Hapus dari Hive
                  entry.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Jurnal berhasil dihapus'),
                      backgroundColor: cardColor,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.only(
                        bottom: 120,
                        left: 20,
                        right: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                },
                child: _buildJournalCard(context, entry),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildJournalCard(BuildContext context, JournalEntry entry) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, _slideRoute(DetailScreen(entry: entry)));
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Image.network(
                entry.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 160,
                    color: cardColor,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            entry.date,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: textSecondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              entry.mood,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            entry.isFavorite = !entry.isFavorite;
                            entry.save();
                          });
                        },
                        child: Icon(
                          entry.isFavorite
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          size: 20,
                          color: entry.isFavorite
                              ? const Color(0xFFFFD60A) // Kuning keemasan
                              : textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.content.length > 80
                        ? '${entry.content.substring(0, 80)}...'
                        : entry.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: textPrimary.withValues(alpha: 0.6),
                      height: 1.4,
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

  // === TAMBAHKAN METHOD INI ===
  Widget _buildFilterChip(String label, String? moodValue) {
    final isSelected = _selectedMoodFilter == moodValue;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick(); // Getaran halus saat filter
        setState(() {
          _selectedMoodFilter = moodValue;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? textPrimary : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? textPrimary
                : textSecondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? bgColor : textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
