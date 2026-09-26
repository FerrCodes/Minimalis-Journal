import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Color bgColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);
  final Color textPrimary = const Color(0xFFF2F2F7);
  final Color textSecondary = const Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
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
          'Settings',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // === SECTION 1: DATA ===
          _buildSectionTitle('Data'),
          const SizedBox(height: 12),
          _buildSettingItem(
            icon: Icons.file_download_outlined,
            title: 'Export Jurnal',
            subtitle: 'Simpan semua jurnal ke file teks',
            onTap: _exportJournals,
          ),
          const SizedBox(height: 8),
          _buildSettingItem(
            icon: Icons.delete_outline,
            title: 'Hapus Semua Jurnal',
            subtitle: 'Hapus permanen semua data jurnal',
            onTap: _confirmDeleteAll,
            isDestructive: true,
          ),

          const SizedBox(height: 32),

          // === SECTION 2: TENTANG ===
          _buildSectionTitle('Tentang'),
          const SizedBox(height: 12),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            subtitle: 'Versi 1.0.0',
            onTap: _showAboutDialog,
          ),
          const SizedBox(height: 8),
          _buildSettingItem(
            icon: Icons.mail_outline,
            title: 'Kirim Feedback',
            subtitle: 'Saran atau laporan bug',
            onTap: () {
              HapticFeedback.selectionClick();
              // Nanti bisa diarahkan ke email
            },
          ),

          const SizedBox(height: 40),

          // Footer
          Center(
            child: Text(
              'Made with ❤️\nMinimal Journal v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: textSecondary.withValues(alpha: 0.5),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === WIDGET BANTUAN ===

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withValues(alpha: 0.15)
                    : textPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  // === FUNGSI EXPORT ===
  void _exportJournals() {
    final box = Hive.box<JournalEntry>('journalBox');

    if (box.isEmpty) {
      _showSnackBar('Belum ada jurnal untuk di-export');
      return;
    }

    // Buat string berisi semua jurnal
    final buffer = StringBuffer();
    buffer.writeln('=== MINIMAL JOURNAL EXPORT ===');
    buffer.writeln(
      'Tanggal Export: ${DateFormat('MMM d, yyyy - HH:mm').format(DateTime.now())}',
    );
    buffer.writeln('Total Jurnal: ${box.length}');
    buffer.writeln('================================\n');

    final entries = box.values.toList().reversed.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.writeln('--- Jurnal #${i + 1} ---');
      buffer.writeln('Tanggal: ${entry.date}');
      buffer.writeln('Mood   : ${entry.mood}');
      buffer.writeln('Judul  : ${entry.title}');
      buffer.writeln('Isi    :');
      buffer.writeln(entry.content);
      buffer.writeln('\n');
    }

    // Salin ke clipboard
    Clipboard.setData(ClipboardData(text: buffer.toString()));

    _showSnackBar('Jurnal disalin ke clipboard! Tempel di Notes/Email.');
  }

  // === FUNGSI HAPUS SEMUA ===
  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Semua Jurnal?',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Semua jurnal akan dihapus permanen dan tidak bisa dikembalikan. Yakin?',
          style: TextStyle(color: textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final box = Hive.box<JournalEntry>('journalBox');
              await box.clear();
              if (mounted) {
                Navigator.pop(context);
                HapticFeedback.heavyImpact();
                _showSnackBar('Semua jurnal berhasil dihapus');
              }
            },
            child: const Text(
              'Hapus Semua',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // === FUNGSI TENTANG ===
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Minimal Journal',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versi 1.0.0',
              style: TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Aplikasi jurnal minimalis untuk mencatat momen harian, refleksi diri, dan melacak mood. Dibuat dengan Flutter dan Hive.',
              style: TextStyle(color: textSecondary, height: 1.5, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2026 - Dibuat dengan ❤️',
              style: TextStyle(
                color: textSecondary.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(color: Color(0xFF0A84FF)),
            ),
          ),
        ],
      ),
    );
  }

  // === SNACKBAR HELPER ===
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: cardColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
