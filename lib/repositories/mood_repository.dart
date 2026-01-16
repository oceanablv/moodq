import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_model.dart';
import '../controllers/auth_controller.dart';

class MoodRepository {
  // --- KONFIGURASI URL ---
  static String get baseUrl {
    return AuthController.baseUrl;
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }

  Future<Map<String, dynamic>> addMoodRaw(String label, double intensity, String note) async {
    try {
      String? userId = await _getUserId();
      if (userId == null) return {'success': false, 'message': 'User ID kosong'};

      final uri = Uri.parse('$baseUrl/add_mood.php');
      debugPrint('POST AddMood: ${uri.toString()}');
      debugPrint('AddMood Payload: user_id=$userId, label=$label, intensity=$intensity');

      final response = await http.post(
        uri,
        body: {
          'user_id': userId,
          'mood_label': label,
          'mood_intensity': intensity.toString(),
          'note': note,
        },
      );

      debugPrint('AddMood Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        try {
          var data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) return data;
          return {'success': false, 'message': 'Unexpected response format'};
        } catch (e) {
          return {'success': false, 'message': 'Invalid JSON response'};
        }
      }

      return {'success': false, 'message': 'HTTP ${response.statusCode}'};
    } catch (e) {
      debugPrint("Error Add Mood Raw (repo): $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<MoodModel?> getHomeStats() async {
    try {
      String? userId = await _getUserId();
      if (userId == null) return null;
      final uri = Uri.parse('$baseUrl/get_home_stats.php?user_id=$userId');
      final response = await http.get(uri);

      debugPrint('GET HomeStats: ${uri.toString()}');
      debugPrint('HomeStats Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // Cache raw response for faster subsequent loads
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_home_stats', response.body);
        } catch (_) {}
        if (data == null) return null;
        if (data is List) {
          if (data.isEmpty) return null;
          return MoodModel.fromJson(data.first as Map<String, dynamic>);
        }
        if (data is Map<String, dynamic>) {
          return MoodModel.fromJson(data);
        }
        return null;
      }
      return null;
    } catch (e) {
      debugPrint("Error Home Stats (repo): $e");
      return null;
    }
  }

  Future<List<MoodModel>> getMoodInsights(String period) async {
    try {
      String? userId = await _getUserId();
      if (userId == null) return [];

      final uri = Uri.parse('$baseUrl/get_mood_insights.php?user_id=$userId&period=$period');
      final response = await http.get(uri);

      debugPrint('GET MoodInsights: ${uri.toString()}');
      debugPrint('MoodInsights Response [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // Cache raw response per period
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cached_mood_insights_$period', response.body);
        } catch (_) {}
        if (data == null) return [];
        if (data is List) {
          return data.map((item) => MoodModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        if (data is Map<String, dynamic>) {
          final moodKeys = {'id', 'mood_label', 'mood_intensity', 'created_at', 'date', 'label', 'intensity'};
          if (data.containsKey('data') && data['data'] is List) {
            return (data['data'] as List)
                .map((item) => MoodModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          if (data.keys.toSet().intersection(moodKeys).isNotEmpty) {
            return [MoodModel.fromJson(data)];
          }
          return [];
        }
        return [];
      }
      return [];
    } catch (e) {
      debugPrint("Error Insights (repo): $e");
      return [];
    }
  }

  // --- CACHED READERS ---
  Future<MoodModel?> getCachedHomeStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cached_home_stats');
      if (raw == null) return null;
      var data = jsonDecode(raw);
      if (data == null) return null;
      if (data is List) {
        if (data.isEmpty) return null;
        return MoodModel.fromJson(data.first as Map<String, dynamic>);
      }
      if (data is Map<String, dynamic>) return MoodModel.fromJson(data);
      return null;
    } catch (e) {
      debugPrint('Error getCachedHomeStats: $e');
      return null;
    }
  }

  Future<List<MoodModel>> getCachedMoodInsights(String period) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cached_mood_insights_$period');
      if (raw == null) return [];
      var data = jsonDecode(raw);
      if (data == null) return [];
      if (data is List) {
        return data.map((item) => MoodModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      if (data is Map<String, dynamic>) {
        if (data.containsKey('data') && data['data'] is List) {
          return (data['data'] as List).map((item) => MoodModel.fromJson(item as Map<String, dynamic>)).toList();
        }
        return [MoodModel.fromJson(data)];
      }
      return [];
    } catch (e) {
      debugPrint('Error getCachedMoodInsights: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> deleteMoodRaw(String moodId) async {
    try {
      String? userId = await _getUserId();
      if (userId == null) return {'success': false, 'message': 'User ID kosong'};

      final uri = Uri.parse('$baseUrl/delete_mood.php');
      final response = await http.post(uri, body: {'user_id': userId, 'mood_id': moodId});
      if (response.statusCode == 200) {
        try {
          var data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) return data;
          return {'success': false, 'message': 'Unexpected response format'};
        } catch (e) {
          return {'success': false, 'message': 'Invalid JSON response'};
        }
      }
      return {'success': false, 'message': 'HTTP ${response.statusCode}'};
    } catch (e) {
      debugPrint('Error deleteMoodRaw: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateMoodRaw(String moodId, String label, double intensity, String note) async {
    try {
      String? userId = await _getUserId();
      if (userId == null) return {'success': false, 'message': 'User ID kosong'};

      final uri = Uri.parse('$baseUrl/update_mood.php');
      final response = await http.post(uri, body: {
        'user_id': userId,
        'mood_id': moodId,
        'mood_label': label,
        'mood_intensity': intensity.toString(),
        'note': note,
      });

      if (response.statusCode == 200) {
        try {
          var data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) return data;
          return {'success': false, 'message': 'Unexpected response format'};
        } catch (e) {
          return {'success': false, 'message': 'Invalid JSON response'};
        }
      }
      return {'success': false, 'message': 'HTTP ${response.statusCode}'};
    } catch (e) {
      debugPrint('Error updateMoodRaw: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
