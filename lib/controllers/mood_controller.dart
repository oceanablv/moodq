import 'package:flutter/foundation.dart';
import '../models/mood_model.dart';
import '../repositories/mood_repository.dart';

class MoodController {
  final MoodRepository _repo = MoodRepository();

  String getMoodEmoji(String? label) {
    if (label == null) return '🤔';
    switch (label.toLowerCase()) {
      case 'excellent':
        return '🤩';
      case 'happy':
      case 'good':
        return '😊';
      case 'neutral':
        return '😐';
      case 'bad':
      case 'sad':
        return '🙁';
      case 'terrible':
      case 'awful':
        return '😭';
      default:
        return '🤔';
    }
  }

  // --- 1. ADD MOOD (Untuk Tombol Check-In) ---
  Future<bool> addMood(String label, double intensity, String note) async {
    try {
      final res = await addMoodRaw(label, intensity, note);
      return res['success'] == true;
    } catch (e) {
      debugPrint("Error Add Mood (wrapper): $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> addMoodRaw(String label, double intensity, String note) async {
    return _repo.addMoodRaw(label, intensity, note);
  }

  // --- 2. GET HOME STATS (Untuk Home Page) ---
  Future<MoodModel?> getHomeStats() async {
    return _repo.getHomeStats();
  }

  Future<MoodModel?> getCachedHomeStats() async {
    return _repo.getCachedHomeStats();
  }

  // --- 3. GET INSIGHTS (Untuk Grafik Chart) ---
  Future<List<MoodModel>> getMoodInsights(String period) async {
    return _repo.getMoodInsights(period);
  }

  Future<List<MoodModel>> getCachedMoodInsights(String period) async {
    return _repo.getCachedMoodInsights(period);
  }

  // --- DELETE MOOD (wrapper) ---
  Future<bool> deleteMood(String moodId) async {
    try {
      final res = await _repo.deleteMoodRaw(moodId);
      return res['success'] == true;
    } catch (e) {
      debugPrint('Error deleteMood (wrapper): $e');
      return false;
    }
  }

  // --- UPDATE MOOD (wrapper) ---
  Future<bool> updateMood(String moodId, String label, double intensity, String note) async {
    try {
      final res = await _repo.updateMoodRaw(moodId, label, intensity, note);
      return res['success'] == true;
    } catch (e) {
      debugPrint('Error updateMood (wrapper): $e');
      return false;
    }
  }
}