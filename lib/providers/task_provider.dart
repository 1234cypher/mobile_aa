import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  List<Task> get todayTasks {
    final today = DateTime.now();
    return _tasks.where((task) {
      return task.dueDate != null &&
          task.dueDate!.day == today.day &&
          task.dueDate!.month == today.month &&
          task.dueDate!.year == today.year;
    }).toList();
  }

  List<Task> get completedTasks =>
      _tasks.where((task) => task.status == TaskStatus.completed).toList();
  List<Task> get pendingTasks =>
      _tasks.where((task) => task.status != TaskStatus.completed).toList();

  TaskProvider() {
    _loadTasksFromStorage();
  }

  Future<void> _loadTasksFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList('tasks') ?? [];

      _tasks = tasksJson.map((taskJson) {
        final taskMap = json.decode(taskJson);
        return Task.fromJson(taskMap);
      }).toList();

      // Add some demo tasks if empty
      if (_tasks.isEmpty) {
        _addDemoTasks();
      }
    } catch (e) {
      debugPrint('Error loading tasks from storage: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _addDemoTasks() {
    final demoTasks = [
      Task(
        title: 'Préparer la présentation client',
        description: 'Finaliser les slides pour la réunion de demain',
        priority: TaskPriority.high,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        estimatedMinutes: 120,
        category: TaskCategory.professional,
      ),
      Task(
        title: 'Séance de sport',
        description: 'Course de 30 minutes au parc',
        priority: TaskPriority.medium,
        dueDate: DateTime.now(),
        estimatedMinutes: 30,
        category: TaskCategory.wellbeing,
      ),
      Task(
        title: 'Appeler maman',
        description: 'Prendre des nouvelles de la famille',
        priority: TaskPriority.low,
        dueDate: DateTime.now(),
        estimatedMinutes: 15,
        category: TaskCategory.personal,
      ),
    ];

    _tasks.addAll(demoTasks);
    _saveTasksToStorage();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveTasksToStorage();
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _saveTasksToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _saveTasksToStorage();
    notifyListeners();
  }

  Future<void> toggleTaskStatus(String taskId) async {
    final task = _tasks.firstWhere((task) => task.id == taskId);
    final newStatus = task.status == TaskStatus.completed
        ? TaskStatus.pending
        : TaskStatus.completed;

    await updateTask(task.copyWith(status: newStatus));
  }

  Future<void> _saveTasksToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) => json.encode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
  }
}
