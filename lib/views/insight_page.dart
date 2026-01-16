import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/mood_controller.dart';
import '../controllers/insight_controller.dart';

class InsightPage extends StatefulWidget {
  const InsightPage({super.key});

  @override
  State<InsightPage> createState() => _InsightPageState();
}

class _InsightPageState extends State<InsightPage> {
  // Controller
  final MoodController _moodController = MoodController();
  final InsightController _insightController = InsightController();

  @override
  void initState() {
    super.initState();
    // 1. Setup Listener
    _insightController.addListener(_onControllerUpdate);
    
    // 2. Load data awal
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load cache dulu (cepat)
    _insightController.loadCachedData();
    // Lalu fetch data baru setelah frame render selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _insightController.loadAllData();
    });
  }

  // Fungsi refresh manual (Tarik layar ke bawah)
  Future<void> _handleRefresh() async {
    await _insightController.loadAllData();
  }

  // Callback saat data berubah
  void _onControllerUpdate() {
    // Cek mounted agar tidak error jika widget sudah ditutup
    if (mounted) {
      setState(() {});
    }
  }

  void _onFilterChanged(String period) {
    _insightController.setPeriod(period);
  }

  @override
  void dispose() {
    // Hapus listener DULUAN sebelum dispose controller
    _insightController.removeListener(_onControllerUpdate);
    _insightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Insights', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      // --- PERBAIKAN: RefreshIndicator agar bisa tarik-untuk-refresh ---
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.cyanAccent,
        backgroundColor: const Color(0xFF1E293B),
        child: Builder(builder: (context) {
          // Tambahan padding bawah agar scroll tidak tertutup nav bar
          final bottomSpace = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;
          
          return SingleChildScrollView(
            // AlwaysScrollableScrollPhysics PENTING agar bisa refresh walau konten sedikit
            physics: const AlwaysScrollableScrollPhysics(), 
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Top Cards ---
                Row(
                  children: [
                    _buildTopCard(
                      title: 'Avg Intensity',
                      value: _insightController.avgIntensity.toStringAsFixed(1),
                      iconOrEmoji: null,
                      color: Colors.cyanAccent,
                    ),
                    const SizedBox(width: 12),
                    _buildTopCard(
                      title: 'Dominant',
                      value: _insightController.dominantMood,
                      iconOrEmoji: _moodController.getMoodEmoji(_insightController.dominantMood),
                      color: Colors.orangeAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Mood Trend Header ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mood Trend', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: _insightController.periods.map((p) => _buildFilterBtn(p)).toList(),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // --- Line Chart ---
                Container(
                  height: 240,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 20, 20, 6),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
                  child: _insightController.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _insightController.chartSpots.isEmpty
                          ? const Center(child: Text('No data for this period', style: TextStyle(color: Colors.grey)))
                          : _buildLineChart(),
                ),

                const SizedBox(height: 12),
                
                // --- PERBAIKAN OVERFLOW: Daily Indicators ---
                if (!_insightController.isLoading && _insightController.chartSpots.isNotEmpty)
                  SizedBox(
                    // NAIKKAN TINGGI DARI 56 KE 70 AGAR TIDAK OVERFLOW
                    height: 70, 
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _insightController.chartSpots.length,
                      itemBuilder: (context, idx) {
                        final label = idx < _insightController.chartLabels.length ? _insightController.chartLabels[idx] : '';
                        final delta = idx < _insightController.dailyDeltas.length ? _insightController.dailyDeltas[idx] : 0.0;
                        final isUp = delta > 0.0;
                        final arrow = isUp ? '▲' : (delta < 0 ? '▼' : '-');
                        final color = delta > 0 ? Colors.greenAccent : (delta < 0 ? Colors.redAccent : Colors.grey);
                        final display = delta == 0 ? '-' : delta.toStringAsFixed(1);
                        
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFF0B1220), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(arrow, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 6),
                                  Text(display, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 6),
                                  const Text('avg', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 24),
                
                // --- Pie Chart ---
                _insightController.isLoading
                    ? const SizedBox()
                    : _insightController.moodCounts.isEmpty
                        ? const SizedBox()
                        : _buildDistributionChart(),

                const SizedBox(height: 16),
                const Text('Mood Summary Log', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _insightController.isLoading 
                    ? const Center(child: CircularProgressIndicator()) 
                    : _buildSummaryGrid(),
              ],
            ),
          );
        }),
      ),
    );
  }

  // --- Widgets (Sama seperti sebelumnya) ---

  Widget _buildFilterBtn(String text) {
    bool isSelected = _insightController.selectedPeriod == text;
    return GestureDetector(
      onTap: () => _onFilterChanged(text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyanAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, style: TextStyle(color: isSelected ? const Color(0xFF0F172A) : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  Widget _buildTopCard({required String title, required String value, String? iconOrEmoji, required Color color}) {
    return Expanded(
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
            Row(
              children: [
                if (iconOrEmoji != null) ...[
                  Text(iconOrEmoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (iconOrEmoji == null) Icon(Icons.show_chart, color: color.withOpacity(0.5), size: 20)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        clipData: FlClipData.all(),
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1, getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1)),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 14,
              interval: 1,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < _insightController.chartLabels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(_insightController.chartLabels[index], style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (_insightController.chartSpots.length - 1).toDouble(),
        minY: 0,
        maxY: 10.5,
        lineBarsData: [
          LineChartBarData(
            spots: _insightController.chartSpots,
            isCurved: true,
            curveSmoothness: 0.35,
            preventCurveOverShooting: true,
            color: Colors.cyanAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.cyanAccent.withOpacity(0.3), Colors.cyanAccent.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: const Color(0xFF0F172A), strokeWidth: 2, strokeColor: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    var summaryWidgets = _insightController.moodCounts.entries.map((entry) {
      String label = entry.key;
      int count = entry.value;
      int total = _insightController.moodCounts.values.fold<int>(0, (a, b) => a + b);

      String percentage = total > 0 ? ((count / total) * 100).toStringAsFixed(0) : '0';
      String emoji = _moodController.getMoodEmoji(label);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                  Text('$percentage% • $count entries', style: const TextStyle(color: Colors.cyanAccent, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      );
    }).toList();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: summaryWidgets,
    );
  }

  Widget _buildDistributionChart() {
    final counts = _insightController.moodCounts;
    final total = counts.values.fold<int>(0, (a, b) => a + b);

    if (total == 0) return const SizedBox();

    final sections = <PieChartSectionData>[];
    final colors = [Colors.greenAccent, Colors.cyanAccent, Colors.orangeAccent, Colors.redAccent, Colors.purpleAccent];
    int i = 0;
    counts.forEach((label, count) {
      final value = count.toDouble();
      final percentage = (value / total) * 100;
      sections.add(PieChartSectionData(
        value: value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: colors[i % colors.length],
        radius: 48,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
      i++;
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: PieChart(
              PieChartData(sections: sections, centerSpaceRadius: 24, sectionsSpace: 4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: counts.entries.map((e) {
                final emoji = _moodController.getMoodEmoji(e.key);
                final percent = ((e.value / total) * 100).toStringAsFixed(0);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e.key, style: const TextStyle(color: Colors.white))),
                      Text('${e.value} • $percent%', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}