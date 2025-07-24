import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/success_entry.dart';

class SuccessProvider with ChangeNotifier {
  List<SuccessEntry> _successes = [];
  bool _isLoading = false;

  List<SuccessEntry> get successes => _successes;
  bool get isLoading => _isLoading;

  List<SuccessEntry> get recentSuccesses {
    final sorted = List<SuccessEntry>.from(_successes)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  SuccessProvider() {
    _loadSuccessesFromStorage();
  }

  Future<void> _loadSuccessesFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final successesJson = prefs.getStringList('successes') ?? [];

      _successes = successesJson.map((successJson) {
        final successMap = json.decode(successJson);
        return SuccessEntry.fromJson(successMap);
      }).toList();

      // Add demo successes if empty
      if (_successes.isEmpty) {
        _addDemoSuccesses();
      }
    } catch (e) {
      debugPrint('Error loading successes from storage: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _addDemoSuccesses() {
    final demoSuccesses = [
      SuccessEntry(
        title: 'Présentation réussie',
        description:
            'J\'ai présenté mon projet devant 20 personnes avec confiance',
        category: SuccessCategory.professional,
        date: DateTime.now().subtract(const Duration(days: 1)),
        confidenceImpact: 5,
        tags: ['présentation', 'confiance', 'travail'],
      ),
      SuccessEntry(
        title: 'Nouvelle compétence',
        description: 'J\'ai terminé un cours en ligne sur le leadership',
        category: SuccessCategory.learning,
        date: DateTime.now().subtract(const Duration(days: 3)),
        confidenceImpact: 4,
        tags: ['formation', 'leadership', 'développement'],
      ),
      SuccessEntry(
        title: 'Objectif fitness atteint',
        description: 'J\'ai couru 5km sans m\'arrêter pour la première fois',
        category: SuccessCategory.wellness,
        date: DateTime.now().subtract(const Duration(days: 5)),
        confidenceImpact: 4,
        tags: ['sport', 'objectif', 'persévérance'],
      ),
    ];

    _successes.addAll(demoSuccesses);
    _saveSuccessesToStorage();
  }

  Future<void> addSuccess(SuccessEntry success) async {
    _successes.add(success);
    await _saveSuccessesToStorage();
    notifyListeners();
  }

  Future<void> updateSuccess(SuccessEntry updatedSuccess) async {
    final index =
        _successes.indexWhere((success) => success.id == updatedSuccess.id);
    if (index != -1) {
      _successes[index] = updatedSuccess;
      await _saveSuccessesToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteSuccess(String successId) async {
    _successes.removeWhere((success) => success.id == successId);
    await _saveSuccessesToStorage();
    notifyListeners();
  }

  Future<void> _saveSuccessesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final successesJson =
        _successes.map((success) => json.encode(success.toJson())).toList();
    await prefs.setStringList('successes', successesJson);
  }

  List<SuccessEntry> filterSuccesses({
    SuccessCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
  }) {
    return _successes.where((success) {
      final matchesCategory = category == null || success.category == category;
      final matchesStartDate = startDate == null ||
          success.date.isAfter(startDate) ||
          success.date.isAtSameMomentAs(startDate);
      final matchesEndDate = endDate == null ||
          success.date.isBefore(endDate) ||
          success.date.isAtSameMomentAs(endDate);
      final matchesTags = tags == null ||
          tags.isEmpty ||
          tags.any((tag) => success.tags.contains(tag));
      return matchesCategory &&
          matchesStartDate &&
          matchesEndDate &&
          matchesTags;
    }).toList();
  }
}
