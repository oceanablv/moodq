import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Wajib import
import 'package:ref2_testing_moodq/views/insight_page.dart';
import 'theme.dart';
import 'views/welcome_page.dart';
import 'views/onboarding_page.dart';
import 'views/home_page.dart'; 
import 'views/login_page.dart';
import 'views/register_page.dart';
import 'views/forgot_password_page.dart';
import 'views/change_password_page.dart';
import 'repositories/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init Notifikasi
  final notificationService = NotificationService();
  await notificationService.init();

  // 2. CEK PREFERENSI USER (Agar settingan Onboarding tidak hilang)
  final prefs = await SharedPreferences.getInstance();
  
  bool moodReminders = prefs.getBool('moodReminders') ?? true;
  int hour = prefs.getInt('reminderHour') ?? 20; // Default 20:00
  int minute = prefs.getInt('reminderMinute') ?? 0;
  String type = prefs.getString('reminderType') ?? 'mood';

  // 3. Jadwalkan ulang HANYA jika fitur aktif
  if (moodReminders) {
    await notificationService.scheduleDailyReminder(
      hour: hour,
      minute: minute,
      reminderType: type
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/change_password': (context) => const ChangePasswordPage(),
        '/home': (context) => const HomeScreen(),
        '/insights': (context) => const InsightPage(),
        '/register': (context) => const RegisterPage(selectedGoals: []),
      },
    );
  }
}