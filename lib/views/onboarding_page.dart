import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import untuk simpan preferensi
import '../theme.dart';
import '../controllers/onboarding_controller.dart';
import '../repositories/notification_service.dart'; // Import Notification Service
import 'register_page.dart';
import 'login_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final OnboardingController _controller = OnboardingController();
  final NotificationService _notificationService = NotificationService(); // Instance Service

  int _currentPage = 0;
  bool isReminderOn = true;
  String selectedReminderTime = "Evening"; // Default Evening (20:00)

  // Logic Validasi: Halaman Goals (Index 2) wajib diisi
  bool get isPageValid {
    if (_currentPage == 2) {
      return _controller.isGoalsValid();
    }
    return true;
  }

  // Fungsi Helper: Konversi Pilihan ke Jam (Int)
  int _getHourFromSelection(String selection) {
    switch (selection) {
      case "Morning": return 9;   // 09:00 AM
      case "Afternoon": return 15; // 03:00 PM
      case "Evening": return 20;   // 08:00 PM
      default: return 20;
    }
  }

  // Fungsi Simpan Pengaturan Onboarding
  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Simpan Pilihan Notifikasi ke SharedPreferences agar ProfilePage bisa baca
    await prefs.setBool('moodReminders', isReminderOn);
    
    if (isReminderOn) {
      int hour = _getHourFromSelection(selectedReminderTime);
      
      // Simpan jam & menit agar sinkron dengan ProfilePage
      await prefs.setInt('reminderHour', hour);
      await prefs.setInt('reminderMinute', 0);
      await prefs.setString('reminderType', 'mood'); // Default pesan "Mood Check-in"

      // 2. JADWALKAN NOTIFIKASI LANGSUNG!
      await _notificationService.scheduleDailyReminder(
        hour: hour,
        minute: 0,
        reminderType: 'mood',
      );
    } else {
      // Jika user mematikan switch, batalkan semua notifikasi
      await _notificationService.flutterLocalNotificationsPlugin.cancelAll();
    }

    // 3. Ambil data goals dan lanjut ke Register
    List<String> finalGoals = _controller.getSelectedGoals();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterPage(selectedGoals: finalGoals),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // HEADER (Skip & Dots)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => const LoginPage())
                  ),
                  child: const Text('Skip', style: TextStyle(color: Colors.grey)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) => buildDot(index)),
              ),
              const SizedBox(height: 10),
              Text("Step ${_currentPage + 1} of 4", style: const TextStyle(color: Colors.grey)),

              // PAGE VIEW CONTENT
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    _buildSimplePage(
                      icon: Icons.favorite,
                      color: Colors.tealAccent,
                      title: "Track, Reflect, Grow",
                      desc: "Build emotional awareness through gentle daily check-ins",
                    ),
                    _buildPrivacyPage(),
                    _buildGoalsPage(),
                    _buildReminderPage(), // Halaman Reminder yang sudah terintegrasi
                  ],
                ),
              ),

              // FOOTER NAVIGATION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      if (_currentPage > 0) {
                        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Back", style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    onPressed: isPageValid
                        ? () {
                            if (_currentPage < 3) {
                              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                            } else {
                              // FINAL STEP: Simpan Data & Jadwalkan Notifikasi
                              _finishOnboarding();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      backgroundColor: isPageValid ? AppTheme.primaryColor : Colors.grey[800],
                      foregroundColor: isPageValid ? Colors.black : Colors.grey,
                    ),
                    child: Text(_currentPage == 3 ? "Get Started" : "Continue >"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 16 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppTheme.primaryColor : Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // --- WIDGETS HALAMAN ---

  Widget _buildSimplePage({required IconData icon, required Color color, required String title, required String desc}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 100, color: color),
        const SizedBox(height: 32),
        Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPrivacyPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock, size: 80, color: Colors.orangeAccent),
        const SizedBox(height: 24),
        const Text("Your Privacy Matters", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        const Text("Your data stays private and secure.", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        _buildCheckItem("Your data stays on your device"),
        _buildCheckItem("No selling or sharing with third parties"),
        _buildCheckItem("You can export or delete anytime"),
      ],
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.green))),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    final goals = _controller.goals;
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.track_changes, size: 60, color: Colors.pinkAccent),
        const SizedBox(height: 20),
        const Text("What brings you here?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const Text("Select your wellness goals", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final item = goals[index];
              final bool isSelected = item.isSelected;
              return GestureDetector(
                onTap: () => setState(() => _controller.toggleGoal(index)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.3), width: isSelected ? 2 : 1),
                    borderRadius: BorderRadius.circular(16),
                    color: AppTheme.cardColor,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.white10, child: Icon(item.icon, color: isSelected ? AppTheme.primaryColor : Colors.grey)),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text(item.desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank, color: isSelected ? AppTheme.primaryColor : Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReminderPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.notifications_active, size: 80, color: Colors.yellowAccent),
        const SizedBox(height: 24),
        const Text("Gentle Reminders", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Daily Reminders", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("Gentle check-in notifications", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Switch(
                value: isReminderOn,
                onChanged: (val) => setState(() => isReminderOn = val),
                activeThumbColor: AppTheme.primaryColor,
                activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Opacity(
          opacity: isReminderOn ? 1.0 : 0.5,
          child: Column(
            children: [
              _buildTimeOption("Morning", "9:00 AM"),
              _buildTimeOption("Afternoon", "3:00 PM"),
              _buildTimeOption("Evening", "8:00 PM"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeOption(String title, String time) {
    bool isSelected = selectedReminderTime == title;
    return GestureDetector(
      onTap: isReminderOn ? () => setState(() => selectedReminderTime = title) : null,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.transparent, width: 2),
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Text(time, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}