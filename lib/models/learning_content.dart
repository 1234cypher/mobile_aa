import 'package:uuid/uuid.dart';

class LearningContent {
  final String id;
  final String title;
  final String description;
  final ContentType type;
  final String? thumbnailUrl;
  final String? contentUrl;
  final int duration; // in minutes
  final ContentCategory category;
  final List<String> tags;
  final int rating; // 1-5
  final bool isCompleted;
  final DateTime createdAt;

  LearningContent({
    String? id,
    required this.title,
    required this.description,
    required this.type,
    this.thumbnailUrl,
    this.contentUrl,
    this.duration = 0,
    required this.category,
    this.tags = const [],
    this.rating = 0,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  LearningContent copyWith({
    String? id,
    String? title,
    String? description,
    ContentType? type,
    String? thumbnailUrl,
    String? contentUrl,
    int? duration,
    ContentCategory? category,
    List<String>? tags,
    int? rating,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return LearningContent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      contentUrl: contentUrl ?? this.contentUrl,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'thumbnailUrl': thumbnailUrl,
      'contentUrl': contentUrl,
      'duration': duration,
      'category': category.index,
      'tags': tags,
      'rating': rating,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LearningContent.fromJson(Map<String, dynamic> json) {
    return LearningContent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ContentType.values[json['type']],
      thumbnailUrl: json['thumbnailUrl'],
      contentUrl: json['contentUrl'],
      duration: json['duration'] ?? 0,
      category: ContentCategory.values[json['category']],
      tags: List<String>.from(json['tags'] ?? []),
      rating: json['rating'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum ContentType { article, video, podcast, webinar, ebook, exercise }
enum ContentCategory { 
  leadership, 
  confidence, 
  productivity, 
  networking, 
  negotiation, 
  interview, 
  career, 
  wellness 
}