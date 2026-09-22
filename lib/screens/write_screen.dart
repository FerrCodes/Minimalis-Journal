import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';

class WriteScreen extends StatefulWidget {
  final JournalEntry? entry; // Null = tulis baru, ada isi = edit

  const WriteScreen({super.key, this.entry});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  final Color bgColor = const Color(0xFF121212);
  final Color textPrimary = const Color(0xFFF2F2F7);
  final Color textSecondary = const Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    // Kalau edit, isi controller dengan data lama. Kalau baru, kosongkan.
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(
      text: widget.entry?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Entry' : 'New Entry',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              if (_titleController.text.isEmpty &&
                  _contentController.text.isEmpty) {
                Navigator.pop(context);
                return;
              }

              final box = Hive.box<JournalEntry>('journalBox');

              if (isEditing) {
                // Update entry yang sudah ada
                widget.entry!.title = _titleController.text.isEmpty
                    ? 'Untitled'
                    : _titleController.text;
                widget.entry!.content = _contentController.text;
                await widget.entry!.save(); // Simpan perubahan
              } else {
                // Buat entry baru
                final newEntry = JournalEntry(
                  title: _titleController.text.isEmpty
                      ? 'Untitled'
                      : _titleController.text,
                  content: _contentController.text,
                  date: 'Oct 25, 2023',
                  imageUrl:
                      'https://images.unsplash.com/photo-1518173946687-a4c8892bbd9f?q=80&w=800&auto=format&fit=crop',
                );
                await box.add(newEntry);
              }

              if (mounted) Navigator.pop(context);
            },
            child: Text(
              isEditing ? 'Update' : 'Save',
              style: const TextStyle(
                color: Color(0xFF0A84FF),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textSecondary.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  fontSize: 16,
                  color: textPrimary.withValues(alpha: 0.8),
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: 'Start writing your thoughts...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: textSecondary.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
