import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/mood_model.dart';
import '../repositories/mood_repository.dart';

class InsightController extends ChangeNotifier {
  final MoodRepository _repo;

  InsightController({MoodRepository? repository}) : _repo = repository ?? MoodRepository();

  // Raw data
  List<MoodModel> allMoodData = [];

  // Presentation data
  List<FlSpot> chartSpots = [];
  List<String> chartLabels = [];
  // day-over-day deltas for chartSpots (same length as chartSpots)
  List<double> dailyDeltas = [];

  // Stats
  Map<String, int> moodCounts = {};
  double avgIntensity = 0.0;
  String dominantMood = "-";

  // Loading & filter
  bool isLoading = true;
  String selectedPeriod = 'All';
  final List<String> periods = ['All', 'Week', 'Month', 'Year'];

  Future<void> loadAllData() async {
    isLoading = true;
    notifyListeners();

    // Ambil semua data (client-side filtering)
    List<MoodModel> data = await _repo.getMoodInsights('all');

    // Sort by date asc
    data.sort((a, b) => a.date.compareTo(b.date));

    allMoodData = data;

    _applyFilter();
  }

  void setPeriod(String period) {
    selectedPeriod = period;
    _applyFilter();
  }

  void _applyFilter() {
    DateTime now = DateTime.now();
    List<MoodModel> filteredList = [];
    if (selectedPeriod == 'All') {
      filteredList = List<MoodModel>.from(allMoodData);
    } else if (selectedPeriod == 'Week') {
      filteredList = allMoodData.where((m) => m.date.isAfter(now.subtract(const Duration(days: 7)))).toList();
    } else if (selectedPeriod == 'Month') {
      filteredList = allMoodData.where((m) => m.date.isAfter(now.subtract(const Duration(days: 30)))).toList();
    } else {
      // Year
      filteredList = allMoodData.where((m) => m.date.isAfter(now.subtract(const Duration(days: 365)))).toList();
    }

    _calculateGeneralStats(filteredList);
    _processChartData(filteredList);
    isLoading = false;
    notifyListeners();
  }

  // Load cached data (if available) to show UI immediately
  Future<void> loadCachedData() async {
    try {
      final cached = await _repo.getCachedMoodInsights('all');
      if (cached.isNotEmpty) {
        allMoodData = cached..sort((a, b) => a.date.compareTo(b.date));
        _applyFilter();
      }
      final cachedStats = await _repo.getCachedHomeStats();
      if (cachedStats != null) {
        // If there's cached stats but no moods, use stats values
        if (allMoodData.isEmpty) {
          allMoodData = [cachedStats];
          _applyFilter();
        }
      }
    } catch (e) {
      debugPrint('Error loadCachedData: $e');
    }
  }

  void _processChartData(List<MoodModel> data) {
    if (data.isEmpty) {
      chartSpots = [];
      chartLabels = [];
      return;
    }

    // For Week/Month views prefer plotting each entry as its own point
    // so users see trend per input. For Year view, aggregate by month.
    List<FlSpot> tempSpots = [];
    List<String> tempLabels = [];

    if (selectedPeriod == 'Year') {
      Map<String, List<double>> groupedData = {};
      for (var item in data) {
        String key = DateFormat('yyyy-MM').format(item.date);
        groupedData.putIfAbsent(key, () => []);
        double intensity = double.tryParse(item.moodIntensity?.toString() ?? '0') ?? 0.0;
        groupedData[key]!.add(intensity);
      }

      var sortedKeys = groupedData.keys.toList()..sort();
      int index = 0;
      for (var key in sortedKeys) {
        List<double> values = groupedData[key]!;
        double sum = values.reduce((a, b) => a + b);
        double avg = sum / values.length;
        tempSpots.add(FlSpot(index.toDouble(), avg));
        DateTime date = DateTime.parse("$key-01");
        tempLabels.add(DateFormat('MMM').format(date));
        index++;
      }
    } else {
      // Per-entry plotting (most recent entries shown in chronological order)
      for (int i = 0; i < data.length; i++) {
        final item = data[i];
        double intensity = double.tryParse(item.moodIntensity?.toString() ?? '0') ?? 0.0;
        tempSpots.add(FlSpot(i.toDouble(), intensity));
        // Label as day or time to keep it compact — show day number if same month
        tempLabels.add(DateFormat('dd').format(item.date));
      }
    }

    chartSpots = tempSpots;
    chartLabels = tempLabels;
    // compute deltas (current - previous)
    dailyDeltas = List<double>.generate(chartSpots.length, (i) {
      if (i == 0) return 0.0;
      return chartSpots[i].y - chartSpots[i - 1].y;
    });
  }

  void _calculateGeneralStats(List<MoodModel> data) {
    if (data.isEmpty) {
      avgIntensity = 0;
      dominantMood = "-";
      moodCounts = {};
      return;
    }

    double totalIntensity = 0;
    Map<String, int> counts = {};

    for (var item in data) {
      double intensity = double.tryParse(item.moodIntensity?.toString() ?? '0') ?? 0.0;
      totalIntensity += intensity;
      String label = item.moodLabel ?? "Unknown";
      counts[label] = (counts[label] ?? 0) + 1;
    }

    String dominant = "-";
    int maxCount = 0;
    counts.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        dominant = key;
      }
    });

    moodCounts = counts;
    avgIntensity = totalIntensity / data.length;
    dominantMood = dominant;
  }
}
