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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Top stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statCard("Approved Submission", vm.stats.approved, Colors.green, Icons.thumb_up),
                _statCard("Denied Submission", vm.stats.denied, Colors.red, Icons.block),
                _statCard("Read Submission", vm.stats.read, Colors.blue, Icons.mail),
                _statCard("Flagged Submission", vm.stats.flagged, Colors.orange, Icons.flag),
              ],
            ),
            const SizedBox(height: 24),

            // 🔹 Graphs + Pie chart
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 250,
                    padding: const EdgeInsets.all(16),
                    decoration: _boxDecoration(),
                    child: const Center(
                      child: Text("📈 Contributions Over Time (Graph Placeholder)"),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 250,
                    padding: const EdgeInsets.all(16),
                    decoration: _boxDecoration(),
                    child: const Center(
                      child: Text("🥧 Pie Chart Placeholder"),
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
                        const Text("Most Commonly Used / Searched Words",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...vm.commonWords.map((word) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: word.count / 100, // 🔧 scale placeholder
                                    backgroundColor: Colors.grey.shade200,
                                    color: Colors.teal,
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
                        const Text("#Top Contributors 👑",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...vm.contributors.map((c) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 20),
                                    const SizedBox(width: 6),
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

  Widget _statCard(String label, int value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text("$value", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

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
