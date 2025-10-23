// lib/features/home/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/home_vm.dart';
import '../../../layout/admin_scaffold.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedOnce) {
      final vm = context.read<HomeVM>();
      vm.loadDashboardData();
      _loadedOnce = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeVM>();

    return AdminScaffold(
      title: "Dashboard",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: vm.isLoading
            ? const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()))
            : vm.errorMessage != null
            ? Center(child: Text(vm.errorMessage!))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Top stat cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statCard("Approved Submission", vm.stats.approved,
                    const Color(0xFF52B587), Icons.thumb_up_alt_outlined),
                _statCard("Denied Submission", vm.stats.denied,
                    const Color(0xFF8E3131), Icons.block),
                _statCard("Read Submission", vm.stats.read,
                    const Color(0xFF4384B3), Icons.mail_outline),
                _statCard("Flagged Submission", vm.stats.flagged,
                    const Color(0xFFF3A463), Icons.outlined_flag),
              ],
            ),
            const SizedBox(height: 24),

            // 🔹 Graphs + Pie Chart
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: _boxDecoration(),
                    child: _buildLineChart(vm),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: _boxDecoration(),
                    child: _buildPieChart(vm),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🔹 Common Words + Top Contributors
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _boxDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Most Commonly Used / Searched Words",
                          style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ...vm.commonWords.map((word) {
                          // guard for progress bar scaling
                          final double pct = (word.count / (vm.commonWords.isNotEmpty ? vm.commonWords.first.count : 1)).clamp(0.05, 1.0);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(width: 80, child: Text(word.word)),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: Colors.grey.shade200,
                                    // color left default
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text("${word.count}"),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _boxDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text("#Top Contributors",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(width: 6),
                            Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...vm.contributors.map((c) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 20),
                                    const SizedBox(width: 8),
                                    Text(c.name),
                                  ],
                                ),
                                Text("${c.words}"),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ADD THIS HELPER METHOD FOR THE LINE CHART
  Widget _buildLineChart(HomeVM vm) {
    // Prepare data points for the last 7 days
    final spots = <FlSpot>[];
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final day = DateTime(date.year, date.month, date.day);
      final count = vm.weeklyContributions[day] ?? 0;
      spots.add(FlSpot(6 - i.toDouble(), count.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final dayIndex = 6 - value.toInt();
                final date = DateTime.now().subtract(Duration(days: dayIndex));
                return Text(DateFormat('d MMM').format(date), style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blueAccent,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [Colors.blueAccent.withOpacity(0.3), Colors.blueAccent.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ADD THIS HELPER METHOD FOR THE PIE CHART
  Widget _buildPieChart(HomeVM vm) {
    return Column(
      children: [
        const Text("Submission Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  value: vm.stats.approved.toDouble(),
                  title: '${vm.stats.approved}',
                  color: const Color(0xFF52B587),
                  radius: 50,
                ),
                PieChartSectionData(
                  value: vm.stats.denied.toDouble(),
                  title: '${vm.stats.denied}',
                  color: const Color(0xFF8E3131),
                  radius: 50,
                ),
                PieChartSectionData(
                  value: vm.stats.flagged.toDouble(),
                  title: '${vm.stats.flagged}',
                  color: const Color(0xFFF3A463),
                  radius: 50,
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem("Approved", const Color(0xFF52B587)),
            _buildLegendItem("Denied", const Color(0xFF8E3131)),
            _buildLegendItem("Flagged", const Color(0xFFF3A463)),
          ],
        )
      ],
    );
  }

  // ✅ ADD THIS HELPER FOR THE PIE CHART LEGEND
  Widget _buildLegendItem(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, color: color),
          const SizedBox(width: 4),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // 🔹 Stat Card
  Widget _statCard(String label, int value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // 🔹 Top row (label left, icon right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: Colors.white, size: 20),
              ],
            ),
            const SizedBox(height: 12),

            // 🔹 Big number centered
            Center(
              child: Text(
                "$value",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Card decoration for content boxes
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
