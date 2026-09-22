import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk status bar
import 'screens/detail_screen.dart';
import 'screens/write_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/journal_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Hive
  await Hive.initFlutter();

  // Daftarkan adapter
  Hive.registerAdapter(JournalEntryAdapter());

  // Buka "box" untuk menyimpan data
  await Hive.openBox<JournalEntry>('journalBox');
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
      home: const ReflectScreen(),
    );
  }
}

class ReflectScreen extends StatelessWidget {
  const ReflectScreen({super.key});

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

                    // Recent Moods
                    Text(
                      'Recent moods',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMoodItem(Icons.wb_sunny_outlined, 'Calm'),
                        _buildMoodItem(Icons.favorite_border, 'Grateful'),
                        _buildMoodItem(Icons.cloud_outlined, 'Peaceful'),
                        _buildMoodItem(Icons.eco_outlined, 'Focused'),
                      ],
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
                      onPressed: () {},
                      icon: Icon(
                        Icons.home_outlined,
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
                          MaterialPageRoute(
                            builder: (context) => const WriteScreen(),
                          ),
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
                      onPressed: () {},
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
                'Belum ada jurnal. Tekan + untuk mulai menulis.',
                style: TextStyle(color: textSecondary),
              ),
            ),
          );
        }

        // Tampilkan jurnal terbaru dulu (dibalik)
        final entries = box.values.toList().reversed.toList();

        return Column(
          children: entries.map((entry) {
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(entry: entry)),
        );
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
                      Text(
                        entry.date,
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                      Icon(
                        Icons.bookmark_border,
                        size: 20,
                        color: textSecondary,
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

  Widget _buildMoodItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: textPrimary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: textSecondary)),
      ],
    );
  }
}
