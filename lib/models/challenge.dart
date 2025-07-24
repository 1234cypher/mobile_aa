import 'package:uuid/uuid.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final int points;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final List<String> steps;

  Challenge({
    String? id,
    required this.title,
    required this.description,
    required this.type,
    this.difficulty = ChallengeDifficulty.easy,
    this.points = 10,
    DateTime? createdAt,
    this.completedAt,
    this.isCompleted = false,
    this.steps = const [],
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    ChallengeType? type,
    ChallengeDifficulty? difficulty,
    int? points,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isCompleted,
    List<String>? steps,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      steps: steps ?? this.steps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'difficulty': difficulty.index,
      'points': points,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'steps': steps,
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ChallengeType.values[json['type']],
      difficulty: ChallengeDifficulty.values[json['difficulty']],
      points: json['points'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      isCompleted: json['isCompleted'],
      steps: List<String>.from(json['steps'] ?? []),
    );
  }
}

enum ChallengeType { confidence, productivity, wellness, social, professional }
enum ChallengeDifficulty { easy, medium, hard }