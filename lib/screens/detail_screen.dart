import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import 'write_screen.dart';

class DetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const DetailScreen({super.key, required this.entry});

  final Color bgColor = const Color(0xFF121212);
  final Color textPrimary = const Color(0xFFF2F2F7);
  final Color textSecondary = const Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    child: Image.network(
                      entry.imageUrl,
                      height: 400,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.date,
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          entry.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          entry.content,
                          style: TextStyle(
                            fontSize: 16,
                            color: textPrimary.withValues(alpha: 0.8),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                    MaterialPageRoute(
                      builder: (context) => WriteScreen(entry: entry),
                    ),
                  );
                  // Setelah edit, refresh halaman detail
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
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFFF2F2F7), size: 20),
      ),
    );
  }
}
