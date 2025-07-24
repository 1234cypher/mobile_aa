import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/challenge.dart';

class ChallengeProvider with ChangeNotifier {
  List<Challenge> _challenges = [];
  bool _isLoading = false;

  List<Challenge> get challenges => _challenges;
  bool get isLoading => _isLoading;

  List<Challenge> get activeChallenges => 
      _challenges.where((c) => !c.isCompleted).toList();

  List<Challenge> get completedChallenges => 
      _challenges.where((c) => c.isCompleted).toList();

  Challenge? get todayChallenge {
    final today = DateTime.now();
    final todayChallenges = _challenges.where((c) =>
        !c.isCompleted &&
        c.createdAt.day == today.day &&
        c.createdAt.month == today.month &&
        c.createdAt.year == today.year).toList();
    
    return todayChallenges.isNotEmpty ? todayChallenges.first : null;
  }

  int get totalPoints => _challenges
      .where((c) => c.isCompleted)
      .map((c) => c.points)
      .fold(0, (sum, points) => sum + points);

  ChallengeProvider() {
    _loadChallengesFromStorage();
  }

  Future<void> _loadChallengesFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final challengesJson = prefs.getStringList('challenges') ?? [];

      _challenges = challengesJson.map((challengeJson) {
        final challengeMap = json.decode(challengeJson);
        return Challenge.fromJson(challengeMap);
      }).toList();

      if (_challenges.isEmpty) {
        _addDemoChallenges();
      }
    } catch (e) {
      debugPrint('Error loading challenges from storage: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _addDemoChallenges() {
    final demoChallenges = [
      Challenge(
        title: 'Prendre la parole en réunion',
        description: 'Intervenir au moins une fois lors de votre prochaine réunion',
        type: ChallengeType.confidence,
        difficulty: ChallengeDifficulty.medium,
        points: 20,
        steps: [
          'Préparer une question ou un commentaire à l\'avance',
          'Lever la main ou demander la parole',
          'Exprimer votre point de vue clairement',
          'Célébrer cette victoire !'
        ],
      ),
      Challenge(
        title: 'Technique Pomodoro',
        description: 'Utiliser la technique Pomodoro pendant 2 heures aujourd\'hui',
        type: ChallengeType.productivity,
        difficulty: ChallengeDifficulty.easy,
        points: 15,
        steps: [
          'Choisir une tâche importante',
          'Régler le timer sur 25 minutes',
          'Travailler sans interruption',
          'Prendre une pause de 5 minutes',
          'Répéter 4 fois'
        ],
      ),
      Challenge(
        title: 'Moment bien-être',
        description: 'Prendre 15 minutes pour une activité relaxante',
        type: ChallengeType.wellness,
        difficulty: ChallengeDifficulty.easy,
        points: 10,
        steps: [
          'Choisir une activité qui vous détend',
          'Éteindre les notifications',
          'Se concentrer sur le moment présent',
          'Apprécier ce moment pour vous'
        ],
      ),
    ];

    _challenges.addAll(demoChallenges);
    _saveChallenges();
  }

  Future<void> addChallenge(Challenge challenge) async {
    _challenges.add(challenge);
    await _saveChallenges();
    notifyListeners();
  }

  Future<void> completeChallenge(String challengeId) async {
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index != -1) {
      _challenges[index] = _challenges[index].copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      await _saveChallenges();
      notifyListeners();
    }
  }

  Future<void> generateDailyChallenge() async {
    final today = DateTime.now();
    final hasToday = _challenges.any((c) =>
        c.createdAt.day == today.day &&
        c.createdAt.month == today.month &&
        c.createdAt.year == today.year);

    if (!hasToday) {
      final dailyChallenges = _getDailyChallenges();
      final randomChallenge = dailyChallenges[today.day % dailyChallenges.length];
      await addChallenge(randomChallenge);
    }
  }

  List<Challenge> _getDailyChallenges() {
    return [
      Challenge(
        title: 'Compliment sincère',
        description: 'Faire un compliment sincère à un collègue',
        type: ChallengeType.social,
        difficulty: ChallengeDifficulty.easy,
        points: 15,
      ),
      Challenge(
        title: 'Nouvelle compétence',
        description: 'Apprendre quelque chose de nouveau pendant 30 minutes',
        type: ChallengeType.professional,
        difficulty: ChallengeDifficulty.medium,
        points: 25,
      ),
      Challenge(
        title: 'Gratitude quotidienne',
        description: 'Noter 3 choses pour lesquelles vous êtes reconnaissante',
        type: ChallengeType.wellness,
        difficulty: ChallengeDifficulty.easy,
        points: 10,
      ),
    ];
  }

  Future<void> _saveChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final challengesJson = _challenges.map((c) => json.encode(c.toJson())).toList();
    await prefs.setStringList('challenges', challengesJson);
  }
}