import 'package:uuid/uuid.dart';
import 'task.dart';

class Project {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? deadline;
  final List<Task> tasks;
  final ProjectStatus status;
  final int progress; // 0-100

  Project({
    String? id,
    required this.title,
    required this.description,
    DateTime? createdAt,
    this.deadline,
    this.tasks = const [],
    this.status = ProjectStatus.active,
    this.progress = 0,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Project copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? deadline,
    List<Task>? tasks,
    ProjectStatus? status,
    int? progress,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      tasks: tasks ?? this.tasks,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'status': status.index,
      'progress': progress,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      tasks: (json['tasks'] as List).map((taskJson) => Task.fromJson(taskJson)).toList(),
      status: ProjectStatus.values[json['status']],
      progress: json['progress'] ?? 0,
    );
  }
}

enum ProjectStatus { active, completed, paused, cancelled }