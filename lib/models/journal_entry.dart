import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

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

  @HiveField(4)
  String mood;

  JournalEntry({
    required this.title,
    required this.content,
    required this.date,
    required this.imageUrl,
    this.mood = 'Calm', // <-- Default mood
  });
}
