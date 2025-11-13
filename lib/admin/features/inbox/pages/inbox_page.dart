import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/inbox_vm.dart';
import '../data/inbox_model.dart';
import '../../../layout/admin_scaffold.dart';
import '../../../shared/theme.dart'; // brandNavy
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InboxVM>();

    return AdminScaffold(
      title: "Inbox",
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildFilters(vm),
                  const SizedBox(height: 20),
                  _buildTable(vm),
                  const SizedBox(height: 20),
                  _buildPagination(vm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(InboxVM vm) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildFilterTab(vm, "All", radius: 12),
        const SizedBox(width: 10),
        _buildFilterTab(vm, "Pending", radius: 12),
        const SizedBox(width: 10),
        _buildFilterTab(vm, "Reviewed", radius: 12),
        const Spacer(),
        PopupMenuButton<String>(
          onSelected: (value) {
            vm.setDateRangeFilter(value);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: "Week", child: Text("Week")),
            PopupMenuItem(value: "Month", child: Text("Month")),
            PopupMenuItem(value: "Year", child: Text("Year")),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: brandNavy,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.filter_list_alt, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text("Filters", style: TextStyle(color: Colors.white)),
                SizedBox(width: 6),
                Icon(Icons.arrow_drop_down, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(InboxVM vm, String label, {double radius = 20}) {
    final selected = vm.selectedFilter == label;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => vm.setFilter(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? brandNavy : Colors.white,
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
      ),
    );
  }

  Widget _buildTable(InboxVM vm) {
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
            DataColumn(label: Expanded(child: Center(child: Text("Action")))),
          ],
          rows: vm.paginatedItems.map<DataRow>((item) {
            return DataRow(
              cells: [
                _flexCell(Text(item['submitted_by_email'] ?? '', style: const TextStyle(fontSize: 13))),
                _flexCell(Text(item['word'] ?? '')),
                _flexCell(Text(item['dialect'] ?? '')),
                _flexCell(Text(item['translation'] ?? '')),
                _flexCell(Text(_formatDate(item['date_submitted']))),
                _flexCell(Text(item['part_of_speech'] ?? '')),
                _flexCell(StatusBadge(status: item['status'] ?? 'pending')),
                _flexCell(
                  IconButton(
                    icon: const Icon(Icons.more_horiz, size: 20),
                    onPressed: () => _showActionModal(context, item),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<String?> _showDenyReasonDialog(BuildContext context) async {
    // Predefined reasons for quick selection
    final List<String> reasons = [
      "Duplicate Submission",
      "Incorrect Information",
      "Inappropriate Content",
      "Not a valid word for the dialect",
      "Other (please specify)",
    ];
    String? selectedReason;
    final TextEditingController otherReasonController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        // Use StatefulBuilder to manage the state of the dialog internally
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Reason for Denial"),
              content: SizedBox(
                width: 400, // Give the dialog a fixed width
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...reasons.map((reason) => RadioListTile<String>(
                        title: Text(reason),
                        value: reason,
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setState(() => selectedReason = value);
                        },
                      )),
                      // If "Other" is selected, show a text field
                      if (selectedReason == "Other (please specify)")
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
                          child: TextField(
                            controller: otherReasonController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: "Specify reason for denial...",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, null), // Return null on cancel
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  // Disable the button until a reason is selected
                  onPressed: selectedReason == null
                      ? null
                      : () {
                    if (selectedReason == "Other (please specify)") {
                      // If "Other" is chosen, return the text from the controller
                      Navigator.pop(dialogContext, otherReasonController.text.trim());
                    } else {
                      // Otherwise, return the selected radio button value
                      Navigator.pop(dialogContext, selectedReason);
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _showFlagReasonDialog(BuildContext context) async {
    // Predefined reasons for flagging a submission
    final List<String> reasons = [
      "Suspicious Content",
      "Repeated Offense",
      "Inappropriate Language",
      "Incorrect Information",
      "Other (please specify)",
    ];

    String? selectedReason;
    final TextEditingController otherReasonController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Reason for Flagging"),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...reasons.map((reason) => RadioListTile<String>(
                        title: Text(reason),
                        value: reason,
                        groupValue: selectedReason,
                        onChanged: (value) {
                          setState(() => selectedReason = value);
                        },
                      )),
                      if (selectedReason == "Other (please specify)")
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 16, right: 16),
                          child: TextField(
                            controller: otherReasonController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: "Specify reason for flagging...",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, null), // Cancel
                  child: const Text("Cancel"),
                ),
                FilledButton(
                  onPressed: selectedReason == null
                      ? null
                      : () {
                    if (selectedReason == "Other (please specify)") {
                      Navigator.pop(dialogContext, otherReasonController.text.trim());
                    } else {
                      Navigator.pop(dialogContext, selectedReason);
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _showActionModal(BuildContext context, Map<String, dynamic> item) {
    // --- Improvement: Split the combined example sentence field ---
    // Get the combined sentence string from Firestore (e.g., "Sentence in dialect|Sentence in English")
    final String combinedExample = item['example_sentence'] ?? '|';
    final List<String> exampleParts = combinedExample.split('|');
    final String dialectExample = exampleParts.isNotEmpty ? exampleParts[0] : 'N/A';
    final String englishExample = exampleParts.length > 1 ? exampleParts[1] : 'N/A';

    final String status = (item['status'] ?? '').toLowerCase();

    // 2. Find the correct reason based on the status
    String? reason = '';
    if (status == 'denied') {
      reason = item['rejection_reason'] as String?;
    } else if (status == 'flagged') {
      reason = item['review_notes'] as String?; // Look in 'review_notes' for flagged items
    }
    final bool hasReason = reason?.isNotEmpty ?? false;

    showDialog(
      context: context,
      builder: (modalContext) => Dialog(
        backgroundColor: brandNavy, // 🔹 Solid Tarami blue
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              width: 450,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Details for ${item['word']}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    buildDetailRow("Dialect", item['dialect'] ?? ''),
                    buildDetailRow("Word", item['word'] ?? ''),
                    buildDetailRow("Translation", item['translation'] ?? ''),
                    buildDetailRow("Phonetic", item['phonetics'] ?? ''), // FIX: was 'phonetic'
                    buildDetailRow("Tagalog", item['tagalog_translation'] ?? ''), // FIX: was 'tagalog'
                    buildDetailRow("Part of Speech", item['part_of_speech'] ?? ''), // FIX: was 'partOfSpeech'
                    buildDetailRow("Definition", item['definition'] ?? ''),
                    buildDetailRow("Example (Dialect)", dialectExample), // FIX: Display split sentence
                    buildDetailRow("Example (English)", englishExample), // FIX: Display split sentence
                    buildDetailRow("Synonyms", item['synonyms'] ?? ''),
                    if (hasReason) ...[
                      const Divider(color: Colors.white24, height: 24),
                      buildDetailRow(
                        "Reason:",
                        reason!,
                      ),
                      const Divider(color: Colors.white24, height: 24),
                    ] else
                      const SizedBox(height: 20),
                    if ((item['status'] ?? '').toLowerCase() == 'pending')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              final result = await context.read<InboxVM>().approveSubmission(item['id']);
                              Navigator.pop(modalContext);
                              if (mounted) { // Check if the widget is still in the tree
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message']),
                                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text("Approve", style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            onPressed: () async {
                              Navigator.pop(modalContext);
                              final reason = await _showDenyReasonDialog(context);

                              // 3. If the admin submitted a reason (didn't cancel)
                              if (reason != null && reason.isNotEmpty) {
                                await context.read<InboxVM>().denySubmission(item['id'], reason: reason);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Submission Denied with reason.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text("Deny", style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              Navigator.pop(modalContext);
                              final reason = await _showFlagReasonDialog(context);

                              if (reason != null && reason.isNotEmpty) {
                                await context.read<InboxVM>().flagSubmission(item['id'], reason: reason);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Submission Flagged'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text("Flag", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessModal(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: brandNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 60),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$label:",
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

  Widget _buildPagination(InboxVM vm) {
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
        for (int p = start; p <= end; p++)
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
}

// Helpers
DataCell _flexCell(Widget child) => DataCell(Center(child: child));

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  // Helper method to get the correct colors based on status
  Map<String, Color> _getColors(String status) {
    switch (status.toLowerCase()) { // Use toLowerCase() for safety
      case "pending":
      // The orange shade you already have
        return {"bg": Colors.orange.shade50, "text": Colors.orange.shade700};
      case "approved":
      // Your new "Approved" colors
        return {"bg": const Color(0xFFE8F5E9), "text": const Color(0xFF2E7D32)};
      case "denied":
      // Your new "Denied" colors
        return {"bg": const Color(0xFFFFEBEE), "text": const Color(0xFFC62828)};
      case "flagged":
      // Your new "Flagged" colors
        return {"bg": const Color(0xFFFFFDE7), "text": const Color(0xFFF9A825)};
      default:
      // Your default fallback colors
        return {"bg": Colors.grey.shade200, "text": Colors.black54};
    }
  }


  // Helper to capitalize the first letter for display (e.g., "pending" -> "Pending")
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }


  @override
  Widget build(BuildContext context) {
    final colors = _getColors(status);
    final bgColor = colors['bg']!;
    final textColor = colors['text']!;
    final displayText = _capitalize(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        displayText,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
String _formatDate(dynamic ts) {
  if (ts == null) return '-';

  // When using Firestore Timestamp
  if (ts is Timestamp) {
    return DateFormat('yyyy-MM-dd HH:mm').format(ts.toDate());
  }

  // When it's already a String (fallback)
  return ts.toString();
}