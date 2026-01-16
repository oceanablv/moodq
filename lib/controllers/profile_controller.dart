import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/session_service.dart';
import 'package:http/http.dart' as http;
import '../models/profile_model.dart';
import '../views/login_page.dart'; 
import 'auth_controller.dart';
import '../repositories/notification_service.dart';

class ProfileController {
  ProfileSettingsModel settings = ProfileSettingsModel();
  final NotificationService notificationService = NotificationService();

  static String get baseUrl {
    return AuthController.baseUrl;
  }

  // Konstruktor untuk langsung memuat data saat controller dibuat
  ProfileController() {
    _loadSettings();
  }

  // --- LOGIKA SETTINGS (SAVE & LOAD) ---

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    settings.highContrast = prefs.getBool('highContrast') ?? false;
    settings.reduceMotion = prefs.getBool('reduceMotion') ?? false;
    settings.autoBackup = prefs.getBool('autoBackup') ?? true;
    settings.moodReminders = prefs.getBool('moodReminders') ?? true;
    
    // Load data notifikasi kustom
    settings.reminderType = prefs.getString('reminderType') ?? 'mood';
    settings.reminderHour = prefs.getInt('reminderHour') ?? 20;
    settings.reminderMinute = prefs.getInt('reminderMinute') ?? 0;
  }

  Future<Map<String, String>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name') ?? 'Zale', 
      'email': prefs.getString('email') ?? 'zale@gmail.com',
    };
  }

  // Fungsi untuk memperbarui jam pengingat
  Future<void> updateReminderTime(int hour, int minute, VoidCallback refreshUI) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    settings.reminderHour = hour;
    settings.reminderMinute = minute;
    
    await prefs.setInt('reminderHour', hour);
    await prefs.setInt('reminderMinute', minute);
    
    refreshUI();
  }

  // Modifikasi fungsi toggle agar mendukung String (untuk reminderType) dan Bool
  Future<void> toggleSetting(String key, dynamic value, VoidCallback refreshUI) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    switch (key) {
      case 'highContrast': 
        settings.highContrast = value; 
        await prefs.setBool(key, value);
        break;
      case 'reduceMotion': 
        settings.reduceMotion = value; 
        await prefs.setBool(key, value);
        break;
      case 'autoBackup': 
        settings.autoBackup = value; 
        await prefs.setBool(key, value);
        break;
      case 'moodReminders': 
        settings.moodReminders = value; 
        await prefs.setBool(key, value);
        break;
      case 'reminderType':
        settings.reminderType = value;
        await prefs.setString(key, value);
        break;
    }
    
    refreshUI(); 
  }

  // --- LOGIKA TELEPON, LOGOUT, DELETE (Tetap Sama) ---

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[^\d+]'), ''),
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint("Error launching call: $e");
    }
  }

  Future<void> logout(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        title: const Text("Logout", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to log out?", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      final session = SessionService();
      await session.clear();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
      }
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B263B),
        title: const Text("Delete Account", style: TextStyle(color: Colors.white)),
        content: const Text("This will delete your account and all stored data. Proceed?", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm != true) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id');
    if (userId == null) return;

    try {
      await http.post(Uri.parse('$baseUrl/delete_account.php'), body: {'user_id': userId});
    } catch (e) {
      debugPrint('Error deleteAccount request: $e');
    }

    final session = SessionService();
    await session.clear();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
    }
  }
}