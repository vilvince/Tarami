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
              // 🔹 Filters
              Row(
                children: [
                  FilterChip(
                    label: const Text("Approved"),
                    selected: vm.selectedFilter == "Approved",
                    onSelected: (_) => vm.setFilter("Approved"),
                  ),
                  const SizedBox(width: 12),
                  FilterChip(
                    label: const Text("Denied"),
                    selected: vm.selectedFilter == "Denied",
                    onSelected: (_) => vm.setFilter("Denied"),
                  ),
                  const SizedBox(width: 12),
                  FilterChip(
                    label: const Text("Flagged"),
                    selected: vm.selectedFilter == "Flagged",
                    onSelected: (_) => vm.setFilter("Flagged"),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 🔹 Table
              Container(
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Colors.grey.shade100,
                    ),
                    columnSpacing: 40,
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    columns: const [
                      DataColumn(label: Text("Email")),
                      DataColumn(label: Text("Submitted Words")),
                      DataColumn(label: Text("Dialect")),
                      DataColumn(label: Text("Translation")),
                      DataColumn(label: Text("Date")),
                      DataColumn(label: Text("Part of Speech")),
                      DataColumn(label: Text("More")),
                    ],
                    rows: vm.paginatedItems.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(Text(item.email)),
                          DataCell(Text(item.submittedWord)),
                          DataCell(Text(item.dialect)),
                          DataCell(Text(item.translation)),
                          DataCell(Text(item.date)),
                          DataCell(Text(item.partOfSpeech)),
                          const DataCell(Icon(Icons.more_horiz)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 Pagination
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: vm.currentPage > 1 ? vm.prevPage : null,
                  ),
                  Text("Page ${vm.currentPage} of ${vm.totalPages}"),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                    vm.currentPage < vm.totalPages ? vm.nextPage : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
