import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/project.dart';
import '../models/task.dart';

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [];
  bool _isLoading = false;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;

  List<Project> get activeProjects => 
      _projects.where((p) => p.status == ProjectStatus.active).toList();

  ProjectProvider() {
    _loadProjectsFromStorage();
  }

  Future<void> _loadProjectsFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = prefs.getStringList('projects') ?? [];

      _projects = projectsJson.map((projectJson) {
        final projectMap = json.decode(projectJson);
        return Project.fromJson(projectMap);
      }).toList();

      if (_projects.isEmpty) {
        _addDemoProjects();
      }
    } catch (e) {
      debugPrint('Error loading projects from storage: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _addDemoProjects() {
    final demoProjects = [
      Project(
        title: 'Lancement nouveau produit',
        description: 'Coordonner le lancement du nouveau produit sur le marché',
        deadline: DateTime.now().add(const Duration(days: 30)),
        tasks: [
          Task(
            title: 'Étude de marché',
            description: 'Analyser la concurrence et les besoins clients',
            priority: TaskPriority.high,
            category: TaskCategory.professional,
            estimatedMinutes: 240,
          ),
          Task(
            title: 'Stratégie marketing',
            description: 'Définir la stratégie de communication',
            priority: TaskPriority.medium,
            category: TaskCategory.professional,
            estimatedMinutes: 180,
          ),
        ],
        progress: 25,
      ),
      Project(
        title: 'Développement personnel',
        description: 'Plan de développement de mes compétences leadership',
        deadline: DateTime.now().add(const Duration(days: 90)),
        tasks: [
          Task(
            title: 'Formation leadership',
            description: 'Suivre une formation en ligne sur le leadership',
            priority: TaskPriority.medium,
            category: TaskCategory.personal,
            estimatedMinutes: 300,
          ),
        ],
        progress: 10,
      ),
    ];

    _projects.addAll(demoProjects);
    _saveProjectsToStorage();
  }

  Future<void> addProject(Project project) async {
    _projects.add(project);
    await _saveProjectsToStorage();
    notifyListeners();
  }

  Future<void> updateProject(Project updatedProject) async {
    final index = _projects.indexWhere((p) => p.id == updatedProject.id);
    if (index != -1) {
      _projects[index] = updatedProject;
      await _saveProjectsToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    _projects.removeWhere((p) => p.id == projectId);
    await _saveProjectsToStorage();
    notifyListeners();
  }

  Future<void> addTaskToProject(String projectId, Task task) async {
    final projectIndex = _projects.indexWhere((p) => p.id == projectId);
    if (projectIndex != -1) {
      final project = _projects[projectIndex];
      final updatedTasks = List<Task>.from(project.tasks)..add(task);
      _projects[projectIndex] = project.copyWith(tasks: updatedTasks);
      await _saveProjectsToStorage();
      notifyListeners();
    }
  }

  List<Task> getProjectTasks(String projectId) {
    final project = _projects.firstWhere((p) => p.id == projectId);
    return project.tasks;
  }

  Future<void> _saveProjectsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = _projects.map((p) => json.encode(p.toJson())).toList();
    await prefs.setStringList('projects', projectsJson);
  }
}