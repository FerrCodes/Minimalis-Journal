import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../utils/preset_images.dart';

class WriteScreen extends StatefulWidget {
  final JournalEntry? entry;

  const WriteScreen({super.key, this.entry});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _selectedMood = 'Calm';
  late String _selectedImage;

  final Color bgColor = const Color(0xFF121212);
  final Color cardColor = const Color(0xFF1E1E1E);
  final Color textPrimary = const Color(0xFFF2F2F7);
  final Color textSecondary = const Color(0xFF8E8E93);

  final List<Map<String, dynamic>> _moods = [
    {'icon': Icons.wb_sunny_outlined, 'label': 'Calm'},
    {'icon': Icons.favorite_border, 'label': 'Grateful'},
    {'icon': Icons.cloud_outlined, 'label': 'Peaceful'},
    {'icon': Icons.eco_outlined, 'label': 'Focused'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController = TextEditingController(
      text: widget.entry?.content ?? '',
    );
    _selectedMood = widget.entry?.mood ?? 'Calm';
    _selectedImage = widget.entry?.imageUrl ?? PresetImages.getDefault();
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
              HapticFeedback.mediumImpact();

              if (_titleController.text.isEmpty &&
                  _contentController.text.isEmpty) {
                Navigator.pop(context);
                return;
              }

              final box = Hive.box<JournalEntry>('journalBox');
              final today = DateFormat('MMM d, yyyy').format(DateTime.now());

              if (isEditing) {
                widget.entry!.title = _titleController.text.isEmpty
                    ? 'Untitled'
                    : _titleController.text;
                widget.entry!.content = _contentController.text;
                widget.entry!.mood = _selectedMood;
                widget.entry!.imageUrl = _selectedImage;
                await widget.entry!.save();
              } else {
                final newEntry = JournalEntry(
                  title: _titleController.text.isEmpty
                      ? 'Untitled'
                      : _titleController.text,
                  content: _contentController.text,
                  date: today,
                  mood: _selectedMood,
                  imageUrl: _selectedImage,
                );
                await box.add(newEntry);
              }

              if (mounted) {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              }
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
            const SizedBox(height: 8),

            // === PILIHAN GAMBAR ===
            Text(
              'Pilih gambar',
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: PresetImages.images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final img = PresetImages.images[index];
                  final isSelected = _selectedImage == img['url'];
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedImage = img['url']!;
                      });
                    },
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? textPrimary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              img['url']!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(color: cardColor);
                                  },
                            ),
                            if (isSelected)
                              Container(
                                color: Colors.black.withValues(alpha: 0.3),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // === MOOD SELECTOR ===
            Text(
              'How are you feeling?',
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood['label'];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedMood = mood['label'];
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? textPrimary : cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          mood['icon'],
                          color: isSelected ? bgColor : textPrimary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mood['label'],
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? textPrimary : textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // === JUDUL ===
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

            // === ISI JURNAL ===
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
