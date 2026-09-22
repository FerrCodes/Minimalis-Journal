import 'package:hive/hive.dart';

part 'journal_entry.g.dart'; // Akan di-generate otomatis

@HiveType(typeId: 0)
class JournalEntry extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String content;

  @HiveField(2)
  String date;

  @HiveField(3)
  String imageUrl;

  JournalEntry({
    required this.title,
    required this.content,
    required this.date,
    required this.imageUrl,
  });
}
