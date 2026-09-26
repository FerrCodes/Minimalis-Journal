import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/journal_entry.dart';
import 'write_screen.dart';

class DetailScreen extends StatefulWidget {
  final JournalEntry entry;

  const DetailScreen({super.key, required this.entry});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final Color bgColor = const Color(0xFF121212);
  final Color textPrimary = const Color(0xFFF2F2F7);
  final Color textSecondary = const Color(0xFF8E8E93);
  final Color cardColor = const Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // === LAPISAN 1: KONTEN ===
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === 1. JUDUL & TANGGAL DI ATAS ===
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tanggal + Badge Mood
                        Row(
                          children: [
                            Text(
                              entry.date,
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: textSecondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                entry.mood,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Judul
                        Text(
                          entry.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // === 2. GAMBAR DI TENGAH ===
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        entry.imageUrl,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // === 3. ISI JURNAL DI BAWAH GAMBAR ===
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 50),
                    child: Text(
                      entry.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: textPrimary.withValues(alpha: 0.8),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // === LAPISAN 2: TOMBOL MELAYANG ===
            Positioned(
              top: 20,
              left: 20,
              child: _buildCircleButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: _buildCircleButton(
                icon: Icons.edit_outlined,
                onTap: () async {
                  // Buka halaman edit
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          WriteScreen(entry: entry),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOutCubic;
                            var tween = Tween(
                              begin: begin,
                              end: end,
                            ).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 350),
                    ),
                  );
                  // Setelah edit selesai, refresh halaman detail
                  if (mounted) {
                    setState(() {}); // <-- INI YANG BIKIN AUTO-REFRESH
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: textPrimary, size: 20),
      ),
    );
  }
}
