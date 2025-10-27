import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_vm.dart';
import '../data/user_model.dart';
import '../../../layout/admin_scaffold.dart';
import '../../../shared/theme.dart'; // for brandNavy
import 'dart:math';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserVM>();

    return AdminScaffold(
      title: "User Management",
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Center(
            child: SizedBox(
              width: 1200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with "Show entries" dropdown on the right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(), // Empty space on the left
                      Row(
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
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Error message (if any)
                  if (vm.error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              vm.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: vm.clearError,
                            color: Colors.red.shade700,
                          ),
                        ],
                      ),
                    ),

                  // Data Table Container
                  Container(
                    width: double.infinity,
                    //padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: vm.isLoading
                        ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                        : vm.paginatedUsers.isEmpty
                        ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text(
                          'No users found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                        : DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                      columnSpacing: 10,
                      dataRowHeight: 64,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      columns: const [
                        DataColumn(label: Text("Name")),
                        DataColumn(label: Text("Email")),
                        DataColumn(label: Text("Contact Number")),
                        DataColumn(label: Text("Submitted Words")),
                        DataColumn(label: Text("Actions")),
                      ],
                      rows: vm.paginatedUsers.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(Text(user.fullName)),
                            DataCell(Text(user.email)),
                            DataCell(Text(user.contactNumber ?? "-")),
                            DataCell(Text(user.submittedWords.toString())),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                tooltip: "Delete User",
                                onPressed: () =>
                                    _confirmDelete(context, vm, user),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pagination
                  if (vm.totalPages > 1) _buildPagination(vm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the numbered pagination controls.
  Widget _buildPagination(UserVM vm) {
    final total = vm.totalPages;
    int start = 1;
    int end = min(total, 5);
    if (vm.currentPage > 3 && total > 5) {
      start = vm.currentPage - 2;
      end = min(vm.currentPage + 2, total);
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

  /// Shows a confirmation dialog before deleting a user.
  Future<void> _confirmDelete(
      BuildContext context, UserVM vm, UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: const Color(0xFF0A2A44),
        title: const Text("Confirm Delete",
            style: TextStyle(color: Colors.white)),
        content: Text(
          "Are you sure you want to delete ${user.fullName}?",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
            const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await vm.deleteUser(user);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}