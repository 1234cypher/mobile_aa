import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mood_entry.dart';

class MoodProvider with ChangeNotifier {
  List<MoodEntry> _moodEntries = [];
  bool _isLoading = false;

  List<MoodEntry> get moodEntries => _moodEntries;
  bool get isLoading => _isLoading;

  MoodEntry? get todayMood {
    final today = DateTime.now();
    try {
      return _moodEntries.firstWhere((entry) =>
          entry.date.day == today.day &&
          entry.date.month == today.month &&
          entry.date.year == today.year);
    } catch (e) {
      return null;
    }
  }

  double get averageMoodThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEntries = _moodEntries.where((entry) =>
        entry.date.isAfter(weekStart) && entry.date.isBefore(now.add(const Duration(days: 1))));
    
    if (weekEntries.isEmpty) return 0;
    return weekEntries.map((e) => e.moodLevel).reduce((a, b) => a + b) / weekEntries.length;
  }

  MoodProvider() {
    _loadMoodEntriesFromStorage();
  }

  Future<void> _loadMoodEntriesFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList('mood_entries') ?? [];

      _moodEntries = entriesJson.map((entryJson) {
        final entryMap = json.decode(entryJson);
        return MoodEntry.fromJson(entryMap);
      }).toList();

      _moodEntries.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('Error loading mood entries from storage: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMoodEntry(MoodEntry entry) async {
    // Remove existing entry for the same day if exists
    _moodEntries.removeWhere((e) =>
        e.date.day == entry.date.day &&
        e.date.month == entry.date.month &&
        e.date.year == entry.date.year);
    
    _moodEntries.add(entry);
    _moodEntries.sort((a, b) => b.date.compareTo(a.date));
    
    await _saveMoodEntriesToStorage();
    notifyListeners();
  }

  Future<void> updateMoodEntry(MoodEntry updatedEntry) async {
    final index = _moodEntries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      _moodEntries[index] = updatedEntry;
      await _saveMoodEntriesToStorage();
      notifyListeners();
    }
  }

  Future<void> deleteMoodEntry(String entryId) async {
    _moodEntries.removeWhere((e) => e.id == entryId);
    await _saveMoodEntriesToStorage();
    notifyListeners();
  }

  List<MoodEntry> getMoodEntriesForPeriod(DateTime start, DateTime end) {
    return _moodEntries.where((entry) =>
        entry.date.isAfter(start.subtract(const Duration(days: 1))) &&
        entry.date.isBefore(end.add(const Duration(days: 1)))).toList();
  }

  Future<void> _saveMoodEntriesToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = _moodEntries.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('mood_entries', entriesJson);
  }
}