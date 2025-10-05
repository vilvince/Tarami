import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/submission_vm.dart';
import '../../../layout/admin_scaffold.dart';

class SubmissionPage extends StatelessWidget {
  const SubmissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SubmissionVM>();

    return AdminScaffold(
      title: "View Submissions",
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Filter buttons
              Row(
                children: [
                  _buildFilterButton(
                    label: "Approved",
                    selected: vm.selectedFilter == "Approved",
                    onTap: () => vm.setFilter("Approved"),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    label: "Denied",
                    selected: vm.selectedFilter == "Denied",
                    onTap: () => vm.setFilter("Denied"),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    label: "Flagged",
                    selected: vm.selectedFilter == "Flagged",
                    onTap: () => vm.setFilter("Flagged"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 🔹 Show entries dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Show ", style: TextStyle(fontSize: 14)),
                  DropdownButton<int>(
                    value: vm.rowsPerPage,
                    items: const [
                      DropdownMenuItem(value: 5, child: Text("5")),
                      DropdownMenuItem(value: 10, child: Text("10")),
                      DropdownMenuItem(value: 25, child: Text("25")),
                    ],
                    onChanged: (value) {
                      if (value != null) vm.setRowsPerPage(value);
                    },
                    underline: const SizedBox(),
                  ),
                  const Text(" entries", style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),

              // 🔹 Table
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: DataTable(
                  headingRowHeight: 50,
                  dataRowHeight: 60,
                  horizontalMargin: 20,
                  columnSpacing: 30,
                  headingRowColor:
                  MaterialStateProperty.all(Colors.grey.shade100),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  dataTextStyle: const TextStyle(fontSize: 13),
                  columns: const [
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Submitted Words")),
                    DataColumn(label: Text("Dialect")),
                    DataColumn(label: Text("Translation")),
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("Part of Speech")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Action")),
                  ],
                  rows: vm.paginatedItems.map((item) {
                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color?>(
                            (states) => Colors.grey.shade50,
                      ),
                      cells: [
                        DataCell(Text(item.email)),
                        DataCell(Text(item.submittedWord)),
                        DataCell(Text(item.dialect)),
                        DataCell(Text(item.translation)),
                        DataCell(Text(item.date)),
                        DataCell(Text(item.partOfSpeech)),
                        // 🔹 Pastel Style Status Badge
                        DataCell(buildStatusBadge(item.status)),
                        DataCell(Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.more_horiz,
                              size: 20, color: Colors.grey.shade700),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Pagination
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: vm.currentPage > 1 ? vm.prevPage : null,
                    child: const Text("Previous"),
                  ),
                  ...List.generate(vm.totalPages, (index) {
                    final pageNumber = index + 1;
                    final isActive = vm.currentPage == pageNumber;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive
                              ? Colors.deepPurple
                              : Colors.grey.shade200,
                          foregroundColor:
                          isActive ? Colors.white : Colors.black,
                          minimumSize: const Size(36, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => vm.goToPage(pageNumber),
                        child: Text("$pageNumber",
                            style: const TextStyle(fontSize: 14)),
                      ),
                    );
                  }),
                  TextButton(
                    onPressed:
                    vm.currentPage < vm.totalPages ? vm.nextPage : null,
                    child: const Text("Next"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0A2940) : Colors.white,
          border: Border.all(
              color: selected ? Colors.transparent : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // 🔹 Pastel Style Status Badge
  Widget buildStatusBadge(String status) {
    final colors = getStatusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: colors['text'],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // 🔹 Status Color Helper (Pastel)
  Map<String, Color> getStatusStyle(String status) {
    switch (status) {
      case "Reviewed":
        return {
          "bg": const Color(0xFFE8F5E9), // light green bg
          "text": const Color(0xFF2E7D32), // dark green text
        };
      case "Pending":
        return {
          "bg": const Color(0xFFFFF3E0), // light orange bg
          "text": const Color(0xFFEF6C00), // orange text
        };
      case "Denied":
        return {
          "bg": const Color(0xFFFFEBEE), // light red bg
          "text": const Color(0xFFC62828), // red text
        };
      case "Approved":
        return {
          "bg": const Color(0xFFE8F5E9), // light green bg
          "text": const Color(0xFF2E7D32), // dark green text // blue text
        };
      case "Flagged":
        return {
          "bg": const Color(0xFFFFFDE7), // light yellow bg
          "text": const Color(0xFFF9A825), // dark yellow text
        };
      default:
        return {
          "bg": Colors.grey.shade200,
          "text": Colors.black54,
        };
    }
  }
}
