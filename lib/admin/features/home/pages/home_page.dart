import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/home_vm.dart';
import '../../../layout/admin_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeVM>();

    return AdminScaffold(
      title: "Dashboard",
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Top stat cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statCard("Approved Submission", vm.stats.approved, const Color(0xFF52B587), Icons.thumb_up_alt_outlined),
                _statCard("Denied Submission", vm.stats.denied, const Color(0xFF8E3131), Icons.block),
                _statCard("Read Submission", vm.stats.read, const Color(0xFF4384B3), Icons.mail_outline),
                _statCard("Flagged Submission", vm.stats.flagged, const Color(0xFFF3A463), Icons.outlined_flag),
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
                    child: const Center(
                      child: Text(
                        "📈 Contributions Over Time (Line Chart Placeholder)",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: _boxDecoration(),
                    child: const Center(
                      child: Text(
                        "🥧 Submission Breakdown (Pie Chart Placeholder)",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ...vm.commonWords.map((word) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(width: 80, child: Text(word.word)),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: word.count / 100, // 🔧 scaling placeholder
                                    backgroundColor: Colors.grey.shade200,
                                    color: Colors.teal,
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
