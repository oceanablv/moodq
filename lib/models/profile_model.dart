class ProfileSettingsModel {
  bool highContrast;
  bool reduceMotion;
  bool appLock;
  bool autoBackup;
  bool moodReminders;
  bool practiceSuggestions;
  bool soundEffects;
  
  // Data untuk Notifikasi
  String reminderType; // "mood", "gratitude", atau "reflection"
  int reminderHour;
  int reminderMinute;

  ProfileSettingsModel({
    this.highContrast = false,
    this.reduceMotion = false,
    this.appLock = false,
    this.autoBackup = true,
    this.moodReminders = true, // Default ON
    this.practiceSuggestions = true,
    this.soundEffects = true,
    this.reminderType = "mood",
    this.reminderHour = 20, // Default Jam 20:00 (Evening)
    this.reminderMinute = 0,
  });
}

class CrisisResource {
  final String title;
  final String contact;
  final String desc;
  final bool isChat;

  CrisisResource({
    required this.title,
    required this.contact,
    required this.desc,
    this.isChat = false,
  });
}