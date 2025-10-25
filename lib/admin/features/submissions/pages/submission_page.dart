import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/submission_vm.dart';
import '../../../layout/admin_scaffold.dart';
import '../../../shared/theme.dart'; // for brandNavy

class SubmissionPage extends StatelessWidget {
  const SubmissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SubmissionVM>();

    return AdminScaffold(
      title: "View Submissions",
      child: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
          ? Center(child: Text(vm.error!))
      // ✅ WRAP YOUR CONTENT IN A SCROLLBAR AND SCROLLVIEW
          : Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(vm),
                  const SizedBox(height: 20),
                  _buildTable(vm, context),
                  const SizedBox(height: 20),
                  if (vm.totalPages > 1) _buildPagination(vm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Filters row
  Widget _buildFilters(SubmissionVM vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Filters
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

        // Right Show entries dropdown
        Row(
          children: [
            const Text("Show ", style: TextStyle(fontSize: 14)),
            DropdownButton<int>(
              value: vm.rowsPerPage,
              items: const [
                DropdownMenuItem(value: 5, child: Text("5")),
                DropdownMenuItem(value: 10, child: Text("10")),
              ],
              onChanged: (value) {
                if (value != null) vm.setRowsPerPage(value);
              },
              underline: const SizedBox(),
            ),
            const Text(" entries", style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  // 🔹 Table
  Widget _buildTable(SubmissionVM vm, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          columnSpacing: 10,
          dataRowHeight: 64,
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
          columns: const [
            DataColumn(label: Expanded(child: Center(child: Text("Email")))),
            DataColumn(label: Expanded(child: Center(child: Text("Submitted Words")))),
            DataColumn(label: Expanded(child: Center(child: Text("Dialect")))),
            DataColumn(label: Expanded(child: Center(child: Text("Translation")))),
            DataColumn(label: Expanded(child: Center(child: Text("Date")))),
            DataColumn(label: Expanded(child: Center(child: Text("Part of Speech")))),
            DataColumn(label: Expanded(child: Center(child: Text("Status")))),
            DataColumn(label: Expanded(child: Center(child: Text("More")))),
          ],
          rows: vm.paginatedItems.map((item) {
            return DataRow(
              cells: [
                _flexCell(Text(item.email, style: const TextStyle(fontSize: 13))),
                _flexCell(Text(item.submittedWord)),
                _flexCell(Text(item.dialect)),
                _flexCell(Text(item.translation)),
                _flexCell(Text(item.date)),
                _flexCell(Text(item.partOfSpeech)),
                _flexCell(StatusBadge(status: item.status)),
                _flexCell(
                  IconButton(
                    icon: const Icon(Icons.more_horiz, size: 20),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: brandNavy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            width: 500,
                            padding: const EdgeInsets.all(20),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with Close button
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Details for ${item.submittedWord}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width:150 ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white),
                                        onPressed: () => Navigator.pop(context),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  _detailRow("Dialect:", item.dialect),
                                  _detailRow("Word:", item.submittedWord),
                                  _detailRow("Translation:", item.translation),
                                  _detailRow("Phonetic:", item.phonetic),
                                  _detailRow("Tagalog:", item.tagalog),
                                  _detailRow("Part of Speech:", item.partOfSpeech),
                                  _detailRow("Definition:", item.definition),
                                  _detailRow("Example Sentence in English:", item.exampleInEnglish),
                                  _detailRow("Example Sentence in Dialect:", item.exampleInDialect),
                                  _detailRow("Synonyms:", item.synonyms),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // 🔹 Pagination
  Widget _buildPagination(SubmissionVM vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: vm.currentPage > 1 ? vm.prevPage : null,
          child: const Text("Previous"),
        ),
        const SizedBox(width: 8),
        for (int p = 1; p <= vm.totalPages; p++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: p == vm.currentPage ? brandNavy : Colors.white,
                foregroundColor: p == vm.currentPage ? Colors.white : Colors.black87,
                elevation: 0,
              ),
              onPressed: () => vm.goToPage(p),
              child: Text("$p"),
            ),
          ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: vm.currentPage < vm.totalPages ? vm.nextPage : null,
          child: const Text("Next"),
        ),
      ],
    );
  }

  // 🔹 Filter Button
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
          color: selected ? brandNavy : Colors.white,
          border: Border.all(
            color: selected ? Colors.transparent : Colors.grey.shade300,
          ),
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
}

// 🔹 Helper for centering cells
DataCell _flexCell(Widget child) => DataCell(Center(child: child));

// 🔹 Status Badge (pastel style)
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(30),
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

  Map<String, Color> _getStatusStyle(String status) {
    switch (status) {
      case "Denied":
        return {"bg": const Color(0xFFFFEBEE), "text": const Color(0xFFC62828)};
      case "Approved":
        return {"bg": const Color(0xFFE8F5E9), "text": const Color(0xFF2E7D32)};
      case "Flagged":
        return {"bg": const Color(0xFFFFFDE7), "text": const Color(0xFFF9A825)};
      default:
        return {"bg": Colors.grey.shade200, "text": Colors.black54};
    }
  }
}

// 🔹 Helper for modal rows
Widget _detailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 220,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
