import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/learning_content.dart';

class LearningProvider with ChangeNotifier {
  List<LearningContent> _contents = [];
  bool _isLoading = false;

  List<LearningContent> get contents => _contents;
  bool get isLoading => _isLoading;

  List<LearningContent> get completedContents => 
      _contents.where((c) => c.isCompleted).toList();

  List<LearningContent> getContentsByCategory(ContentCategory category) {
    return _contents.where((c) => c.category == category).toList();
  }

  List<LearningContent> getContentsByType(ContentType type) {
    return _contents.where((c) => c.type == type).toList();
  }

  LearningProvider() {
    _loadContentsFromStorage();
  }

  Future<void> _loadContentsFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final contentsJson = prefs.getStringList('learning_contents') ?? [];

      _contents = contentsJson.map((contentJson) {
        final contentMap = json.decode(contentJson);
        return LearningContent.fromJson(contentMap);
      }).toList();

      if (_contents.isEmpty) {
        _addDemoContents();
      }
    } catch (e) {
      debugPrint('Error loading contents from storage: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _addDemoContents() {
    final demoContents = [
      LearningContent(
        title: 'Les 7 habitudes des femmes leaders efficaces',
        description: 'Découvrez les habitudes qui distinguent les femmes leaders performantes',
        type: ContentType.article,
        duration: 15,
        category: ContentCategory.leadership,
        tags: ['leadership', 'habitudes', 'efficacité'],
        rating: 5,
      ),
      LearningContent(
        title: 'Négocier son salaire avec confiance',
        description: 'Webinaire sur les techniques de négociation salariale pour les femmes',
        type: ContentType.webinar,
        duration: 60,
        category: ContentCategory.negotiation,
        tags: ['négociation', 'salaire', 'confiance'],
        rating: 4,
      ),
      LearningContent(
        title: 'Podcast : Surmonter le syndrome de l\'imposteur',
        description: 'Interview avec une psychologue spécialisée dans le syndrome de l\'imposteur',
        type: ContentType.podcast,
        duration: 45,
        category: ContentCategory.confidence,
        tags: ['imposteur', 'psychologie', 'confiance'],
        rating: 5,
      ),
      LearningContent(
        title: 'Guide : Préparer un entretien d\'embauche',
        description: 'Guide complet pour réussir ses entretiens d\'embauche',
        type: ContentType.ebook,
        duration: 30,
        category: ContentCategory.interview,
        tags: ['entretien', 'emploi', 'préparation'],
        rating: 4,
      ),
      LearningContent(
        title: 'Exercice : Visualisation du succès',
        description: 'Exercice guidé de visualisation pour renforcer la confiance en soi',
        type: ContentType.exercise,
        duration: 20,
        category: ContentCategory.confidence,
        tags: ['visualisation', 'méditation', 'succès'],
        rating: 5,
      ),
    ];

    _contents.addAll(demoContents);
    _saveContentsToStorage();
  }

  Future<void> markAsCompleted(String contentId) async {
    final index = _contents.indexWhere((c) => c.id == contentId);
    if (index != -1) {
      _contents[index] = _contents[index].copyWith(isCompleted: true);
      await _saveContentsToStorage();
      notifyListeners();
    }
  }

  Future<void> rateContent(String contentId, int rating) async {
    final index = _contents.indexWhere((c) => c.id == contentId);
    if (index != -1) {
      _contents[index] = _contents[index].copyWith(rating: rating);
      await _saveContentsToStorage();
      notifyListeners();
    }
  }

  List<LearningContent> searchContents(String query) {
    return _contents.where((content) =>
        content.title.toLowerCase().contains(query.toLowerCase()) ||
        content.description.toLowerCase().contains(query.toLowerCase()) ||
        content.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))).toList();
  }

  Future<void> _saveContentsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final contentsJson = _contents.map((c) => json.encode(c.toJson())).toList();
    await prefs.setStringList('learning_contents', contentsJson);
  }
}