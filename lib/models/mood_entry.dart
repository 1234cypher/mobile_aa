import 'package:uuid/uuid.dart';

class MoodEntry {
  final String id;
  final DateTime date;
  final int moodLevel; // 1-5
  final int motivationLevel; // 1-5
  final int confidenceLevel; // 1-5
  final String? notes;
  final List<String> activities;
  final List<String> emotions;

  MoodEntry({
    String? id,
    DateTime? date,
    required this.moodLevel,
    required this.motivationLevel,
    required this.confidenceLevel,
    this.notes,
    this.activities = const [],
    this.emotions = const [],
  }) : id = id ?? const Uuid().v4(),
       date = date ?? DateTime.now();

  MoodEntry copyWith({
    String? id,
    DateTime? date,
    int? moodLevel,
    int? motivationLevel,
    int? confidenceLevel,
    String? notes,
    List<String>? activities,
    List<String>? emotions,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      moodLevel: moodLevel ?? this.moodLevel,
      motivationLevel: motivationLevel ?? this.motivationLevel,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      notes: notes ?? this.notes,
      activities: activities ?? this.activities,
      emotions: emotions ?? this.emotions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moodLevel': moodLevel,
      'motivationLevel': motivationLevel,
      'confidenceLevel': confidenceLevel,
      'notes': notes,
      'activities': activities,
      'emotions': emotions,
    };
  }

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      moodLevel: json['moodLevel'],
      motivationLevel: json['motivationLevel'],
      confidenceLevel: json['confidenceLevel'],
      notes: json['notes'],
      activities: List<String>.from(json['activities'] ?? []),
      emotions: List<String>.from(json['emotions'] ?? []),
    );
  }
}