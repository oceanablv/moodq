class MoodModel {
  final String? id;
  final String? userId;
  final String? moodLabel;
  final dynamic moodIntensity;
  final String? note;
  final String? createdAt;

  // Statistik
  final int? totalEntries;
  final int? streak;

  MoodModel({
    this.id,
    this.userId,
    this.moodLabel,
    this.moodIntensity,
    this.note,
    this.createdAt,
    this.totalEntries,
    this.streak,
  });

  // ============================
  // DATE PARSING (INSIGHT-SAFE)
  // ============================
  // Tidak pernah fallback ke DateTime.now()
  // Mencegah bias grafik & statistik
  DateTime get date {
    if (createdAt == null || createdAt!.isEmpty) {
      // Epoch → aman, tidak mencemari grafik periode aktif
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    try {
      // Handle: "YYYY-MM-DD HH:mm:ss" → ISO
      return DateTime.parse(createdAt!.replaceFirst(' ', 'T'));
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      moodLabel: json['mood_label'] ?? json['label'],
      // Accept several possible keys for intensity (backend may vary)
      moodIntensity: json['mood_intensity'] ?? json['intensity'] ?? json['value'] ?? json['score'],
      note: json['note'],
      createdAt: json['created_at'] ?? json['date'],

      // Parsing aman (string / int). Support multiple key formats returned by API
      totalEntries: int.tryParse((json['total_entries'] ?? json['totalEntries'] ?? json['total'])?.toString() ?? '0'),
      streak: int.tryParse(json['streak']?.toString() ?? '0'),
    );
  }

  // Robust intensity parser: handles int, double, numeric strings, and nulls
  double get intensity {
    if (moodIntensity == null) return 0.0;
    if (moodIntensity is num) return (moodIntensity as num).toDouble();
    try {
      final s = moodIntensity.toString();
      // Guard against literal 'null' or empty
      if (s.isEmpty || s.toLowerCase() == 'null') return 0.0;
      return double.tryParse(s) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }
}
