import 'package:uuid/uuid.dart';

class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String title;
  final String content;
  final PostCategory category;
  final DateTime createdAt;
  final List<String> tags;
  final int likes;
  final int comments;
  final bool isAnonymous;
  final bool isLikedByUser;

  CommunityPost({
    String? id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.title,
    required this.content,
    required this.category,
    DateTime? createdAt,
    this.tags = const [],
    this.likes = 0,
    this.comments = 0,
    this.isAnonymous = false,
    this.isLikedByUser = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  CommunityPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? title,
    String? content,
    PostCategory? category,
    DateTime? createdAt,
    List<String>? tags,
    int? likes,
    int? comments,
    bool? isAnonymous,
    bool? isLikedByUser,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'title': title,
      'content': content,
      'category': category.index,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
      'likes': likes,
      'comments': comments,
      'isAnonymous': isAnonymous,
      'isLikedByUser': isLikedByUser,
    };
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorAvatar: json['authorAvatar'],
      title: json['title'],
      content: json['content'],
      category: PostCategory.values[json['category']],
      createdAt: DateTime.parse(json['createdAt']),
      tags: List<String>.from(json['tags'] ?? []),
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      isAnonymous: json['isAnonymous'] ?? false,
      isLikedByUser: json['isLikedByUser'] ?? false,
    );
  }
}

enum PostCategory { 
  general, 
  career, 
  leadership, 
  workLifeBalance, 
  confidence, 
  networking, 
  mentorship,
  success,
  challenges
}