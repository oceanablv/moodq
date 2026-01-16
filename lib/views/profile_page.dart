import 'package:flutter/material.dart';
import '../theme.dart';
import '../controllers/profile_controller.dart';
import '../controllers/journal_controller.dart';
import '../repositories/notification_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = ProfileController();
  final JournalController _journalController = JournalController();
  final NotificationService _notificationService = NotificationService();

  void _refresh() => setState(() {});

  // --- 1. LOGIKA SET WAKTU PRESET (Pagi/Siang/Malam) ---
  Future<void> _setPresetTime(int hour, String label) async {
    // Simpan ke controller (Memory & SharedPreferences)
    await _controller.updateReminderTime(hour, 0, _refresh);

    // Jadwalkan ulang notifikasi jika fitur aktif
    if (_controller.settings.moodReminders) {
      await _notificationService.scheduleDailyReminder(
        hour: hour,
        minute: 0,
        reminderType: _controller.settings.reminderType,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Reminder set to $label ($hour:00)"))
        );
      }
    }
  }

  // --- 2. DIALOG PILIH PESAN NOTIFIKASI ---
  void _showReminderTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151C2F),
        title: const Text("Select Reminder Message", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypeOption("Mood Check-in", "mood"),
            _buildTypeOption("Gratitude Journal", "gratitude"),
            _buildTypeOption("Self Reflection", "reflection"),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String label, String value) {
    bool isSelected = _controller.settings.reminderType == value;
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primaryColor) : null,
      onTap: () async {
        await _controller.toggleSetting('reminderType', value, _refresh);
        // Reschedule dengan tipe baru
        if (_controller.settings.moodReminders) {
          await _notificationService.scheduleDailyReminder(
            hour: _controller.settings.reminderHour,
            minute: _controller.settings.reminderMinute,
            reminderType: value,
          );
        }
        if (mounted) Navigator.pop(context);
      },
    );
  }

  // --- 3. PRIVACY POLICY DIALOG ---
  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151C2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Privacy Policy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Text(
            "MoodQ berkomitmen melindungi data pribadi Anda. Semua catatan jurnal Anda disimpan dengan aman dan hanya digunakan untuk keperluan personal Anda sendiri.",
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = _controller.settings;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // HEADER PROFILE
              FutureBuilder<Map<String, String>>(
                future: _controller.getUserData(),
                builder: (context, snapshot) {
                  return Column(
                    children: [
                      const Center(child: CircleAvatar(radius: 40, backgroundColor: AppTheme.primaryColor, child: Icon(Icons.person, size: 40, color: Colors.black))),
                      const SizedBox(height: 16),
                      Text(snapshot.data?['name'] ?? "User", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(snapshot.data?['email'] ?? "user@email.com", style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // --- SECTION: GENTLE REMINDERS ---
              _buildSectionContainer(
                title: "Gentle Reminders",
                icon: Icons.notifications_active_outlined,
                children: [
                  // Toggle Utama
                  _buildSwitchRow(
                    "Daily Reminders", 
                    "Gentle check-in notifications", 
                    settings.moodReminders, 
                    (val) async {
                      if (val) {
                        await _notificationService.scheduleDailyReminder(
                          hour: settings.reminderHour,
                          minute: settings.reminderMinute,
                          reminderType: settings.reminderType,
                        );
                      } else {
                        await _notificationService.cancelAllNotifications();
                      }
                      _controller.toggleSetting('moodReminders', val, _refresh);
                    }
                  ),
                  const SizedBox(height: 16),
                  
                  // Opsi Waktu (Morning/Afternoon/Evening)
                  _buildPresetCard("Morning", "9:00 AM", 9, settings.reminderHour == 9),
                  const SizedBox(height: 8),
                  _buildPresetCard("Afternoon", "3:00 PM", 15, settings.reminderHour == 15),
                  const SizedBox(height: 8),
                  _buildPresetCard("Evening", "8:00 PM", 20, settings.reminderHour == 20),

                  const Divider(color: Colors.white10, height: 30),
                  
                  // Opsi Ubah Pesan
                  _buildActionRow(
                    "Message: ${settings.reminderType.toUpperCase()}", 
                    Icons.edit_note, 
                    () => _showReminderTypeDialog()
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- SECTION: APPEARANCE ---
              _buildSectionContainer(
                title: "Appearance",
                icon: Icons.palette_outlined,
                children: [
                  _buildSwitchRow("High Contrast", "Enhance contrast", settings.highContrast, (val) => _controller.toggleSetting('highContrast', val, _refresh)),
                  const Divider(color: Colors.white10),
                  _buildSwitchRow("Reduce Motion", "Minimize animations", settings.reduceMotion, (val) => _controller.toggleSetting('reduceMotion', val, _refresh)),
                ],
              ),
              const SizedBox(height: 20),

              // --- SECTION: SETTINGS ---
              _buildSectionContainer(
                title: "Settings",
                icon: Icons.settings,
                children: [
                  _buildActionRow("Export My Data", Icons.download, () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Memproses file CSV...")));
                    _journalController.exportJournalsToCSV();
                  }),
                  const Divider(color: Colors.white10),
                  _buildActionRow("Privacy Policy", Icons.policy, () => _showPrivacyPolicy(context)),
                  const SizedBox(height: 20),
                  
                  // Tombol Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _controller.logout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text("Log Out"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCF6679),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Tombol Delete Account
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _controller.deleteAccount(context),
                      icon: const Icon(Icons.delete_forever),
                      label: const Text("Delete Account"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  // Widget Kartu Pilihan Waktu (Morning/Afternoon/Evening)
  Widget _buildPresetCard(String label, String time, int hourVal, bool isSelected) {
    return GestureDetector(
      onTap: () => _setPresetTime(hourVal, label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // Logic Highlight: Border Biru jika dipilih
          border: isSelected ? Border.all(color: AppTheme.primaryColor, width: 2) : Border.all(color: Colors.transparent),
          color: const Color(0xFF1F293A), 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(time, style: TextStyle(color: isSelected ? AppTheme.primaryColor : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 20, color: Colors.white), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))]),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12))])),
        Switch(value: value, onChanged: onChanged, activeThumbColor: AppTheme.primaryColor),
      ],
    );
  }

  Widget _buildActionRow(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Icon(icon, color: Colors.grey, size: 20)],
        ),
      ),
    );
  }
}