import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/inbox_vm.dart';
import '../data/inbox_model.dart';
import '../../../layout/admin_scaffold.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InboxVM>();

    return AdminScaffold(
      title: "Inbox",
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Top row: filter chips + entries/filters
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildFilterTab(context, vm, "All", radius: 12),
                  const SizedBox(width: 10),
                  _buildFilterTab(context, vm, "Pending", radius: 12),
                  const SizedBox(width: 10),
                  _buildFilterTab(context, vm, "Reviewed", radius: 12),
                  const Spacer(),
                  Row(
                    children: [
                      const Text("Show"),
                      const SizedBox(width: 6),
                      DropdownButton<int>(
                        value: vm.rowsPerPage,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 5, child: Text("5")),
                          DropdownMenuItem(value: 10, child: Text("10")),
                          DropdownMenuItem(value: 20, child: Text("20")),
                        ],
                        onChanged: (v) {
                          if (v != null) vm.updateRowsPerPage(v);
                        },
                      ),
                      const SizedBox(width: 6),
                      const Text("entries"),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_list, size: 18),
                        label: const Text("Filters"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A2A44),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Table container
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
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    headingRowColor:
                    MaterialStateProperty.all(Colors.grey.shade100),
                    columnSpacing: 10,
                    dataRowHeight: 64,
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    columns: const [
                      DataColumn(
                          label: Expanded(
                              child: Center(child: Text("Email")))),
                      DataColumn(
                          label: Expanded(
                              child: Center(child: Text("Submitted Words")))),
                      DataColumn(
                          label: Expanded(
                              child: Center(child: Text("Dialect")))),
                      DataColumn(
                          label: Expanded(
                              child: Center(child: Text("Translation")))),
                      DataColumn(
                          label: Expanded(
                              child: Center(child: Text("Date")))),
                      DataColumn(
                          label: Expanded(
                              child: Center(child: Text("Part of Speech")))),
                      DataColumn(
                          label: Expanded(
                              child: Center(child: Text("Status")))),
                      DataColumn(
                          label: Expanded(
                              child: Center(child: Text("Action")))),
                    ],
                    rows: vm.paginatedItems.map<DataRow>((InboxItem item) {
                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                                (states) {
                              if (states.contains(MaterialState.hovered)) {
                                return Colors.grey.shade50;
                              }
                              return null;
                            }),
                        cells: [
                          _flexCell(Text(item.email,
                              style: const TextStyle(fontSize: 13))),
                          _flexCell(Text(item.submittedWord)),
                          _flexCell(Text(item.dialect)),
                          _flexCell(Text(item.translation)),
                          _flexCell(Text(item.date)),
                          _flexCell(Text(item.partOfSpeech)),
                          _flexCell(StatusBadge(status: item.status)),
                          _flexCell(
                            IconButton(
                              icon: const Icon(Icons.more_horiz, size: 20),
                              padding: EdgeInsets.zero,
                              constraints:
                              const BoxConstraints(minWidth: 40),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Pagination
              Builder(builder: (ctx) {
                final total = vm.totalPages;
                int start = 1;
                int end = math.min(total, 5);
                if (vm.currentPage > 3 && total > 5) {
                  start = vm.currentPage - 2;
                  end = math.min(vm.currentPage + 2, total);
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: vm.currentPage > 1 ? vm.prevPage : null,
                      child: const Text("Previous"),
                    ),
                    const SizedBox(width: 8),
                    for (int p = start; p <= end; p++) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: p == vm.currentPage
                                ? const Color(0xFF6A4CFF)
                                : Colors.white,
                            foregroundColor: p == vm.currentPage
                                ? Colors.white
                                : Colors.black87,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () => vm.goToPage(p),
                          child: Text("$p"),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed:
                      vm.currentPage < vm.totalPages ? vm.nextPage : null,
                      child: const Text("Next"),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(BuildContext context, InboxVM vm, String label,
      {double radius = 20}) {
    final selected = vm.selectedFilter == label;
    return GestureDetector(
      onTap: () => vm.setFilter(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0A2A44) : Colors.white,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.black12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// --------------------
// Helpers
// --------------------
DataCell _flexCell(Widget child) {
  return DataCell(
    Expanded(child: Center(child: child)),
  );
}

// --------------------
// Pill-Style Status Badge
// --------------------
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isReviewed = status == "Reviewed";

    // Colors for different statuses
    final bgColor = isReviewed ? Colors.green.shade50 : Colors.orange.shade50;
    final textColor =
    isReviewed ? Colors.green.shade700 : Colors.orange.shade700;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14, // lapad para pill effect
          vertical: 6, // taas para balanced height
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30), // pill shape
        ),
        child: Text(
          status,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
