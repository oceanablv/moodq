import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/practice_model.dart';
import 'auth_controller.dart';

class PracticeController {
  static String get baseUrl {
    return AuthController.baseUrl;
  }

  Future<String?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }

  // Simpan Hasil DASS-21 ke database
  Future<bool> saveDASSResult(int score, String category) async {
    try {
      String? userId = await _getUserId();
      if (userId == null) return false;
      final uri = Uri.parse('$baseUrl/save_dass.php');
      final response = await http.post(uri, body: {
        'user_id': userId,
        'score': score.toString(),
        'category': category,
      }).timeout(const Duration(seconds: 10));
      debugPrint('saveDASSResult POST: ${uri.toString()} -> ${response.statusCode}');
      return jsonDecode(response.body)['success'] ?? false;
    } catch (e) {
      debugPrint("Error saveDASS: $e");
      return false;
    }
  }

  // Provide practice items (moved from the view to the controller)
  List<Practice> getPractices() {
    return [
      Practice(
        title: "Box Breathing",
        desc: "4-4-4-4 pattern to reduce stress and anxiety",
        category: "Breathing",
        duration: "5 min",
        icon: Icons.air,
        color: Colors.cyanAccent,
        tag: "4-4-4-4",
      ),
      Practice(
        title: "4-7-8 Breathing",
        desc: "Calming technique for better sleep",
        category: "Breathing",
        duration: "4 min",
        icon: Icons.nightlight_round,
        color: Colors.purpleAccent,
        tag: "4-7-8",
      ),
      Practice(
        title: "Gratitude Practice",
        desc: "3-minute reflection on positive moments",
        category: "Mindfulness",
        duration: "3 min",
        icon: Icons.favorite,
        color: Colors.pinkAccent,
        tag: "Daily",
      ),
      Practice(
        title: "5-Senses Grounding",
        desc: "Connect with your surroundings instantly",
        category: "Grounding",
        duration: "5 min",
        icon: Icons.touch_app,
        color: Colors.orangeAccent,
        tag: "Anxiety",
      ),
      Practice(
        title: "Body Scan",
        desc: "Relax your body from head to toe",
        category: "Sleep",
        duration: "10 min",
        icon: Icons.accessibility,
        color: Colors.blueAccent,
        tag: "Relaxation",
      ),
    ];
  }

  // DASS-21 questions moved to controller
  List<String> getDASSQuestions() {
    return [
      "I found it hard to wind down.",
      "I was aware of dryness of my mouth.",
      "I couldn't seem to experience any positive feeling at all.",
      "I experienced breathing difficulty (e.g. excessively rapid breathing, breathlessness in the absence of physical exertion).",
      "I found it difficult to work up the initiative to do things.",
      "I tended to over-react to situations.",
      "I experienced trembling (e.g. in the hands).",
      "I felt that I was using a lot of nervous energy.",
      "I was worried about situations in which I might panic and make a fool of myself.",
      "I felt that I had nothing to look forward to.",
      "I found myself getting agitated.",
      "I found it difficult to relax.",
      "I felt down-hearted and blue.",
      "I was intolerant of anything that kept me from getting on with what I was doing.",
      "I felt I was close to panic.",
      "I was unable to become enthusiastic about anything.",
      "I felt I wasn't worth much as a person.",
      "I felt that I was rather touchy.",
      "I was aware of the action of my heart in the absence of physical exertion.",
      "I felt scared without any good reason.",
      "I felt that life was meaningless."
    ];
  }

  // Process answers, save result and return a summary map
  Future<Map<String, dynamic>> processDASSAnswers(Map<int, int> answers) async {
    int totalScore = answers.values.fold(0, (sum, val) => sum + val);
    String category = "";
    bool suggestBoxBreath = false;

    if (totalScore <= 14) {
      category = "Normal";
    } else if (totalScore <= 25) {
      category = "Moderate Stress";
      suggestBoxBreath = true;
    } else {
      category = "Severe Stress";
      suggestBoxBreath = true;
    }

    await saveDASSResult(totalScore, category);

    return {
      'score': totalScore,
      'category': category,
      'suggest': suggestBoxBreath,
    };
  }

  // Simpan Log Waktu Latihan Box Breathing
  Future<bool> logPracticeTime(int seconds, String status) async {
    try {
      String? userId = await _getUserId();
      if (userId == null) return false;
      final uri = Uri.parse('$baseUrl/log_practice.php');
      final response = await http.post(uri, body: {
        'user_id': userId,
        'practice_name': 'Box Breathing',
        'duration_seconds': seconds.toString(),
        'status': status,
      }).timeout(const Duration(seconds: 10));
      debugPrint('logPracticeTime POST: ${uri.toString()} -> ${response.statusCode}');
      return jsonDecode(response.body)['success'] ?? false;
    } catch (e) {
      debugPrint("Error logPractice: $e");
      return false;
    }
  }
}