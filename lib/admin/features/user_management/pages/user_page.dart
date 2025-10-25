import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/user_model.dart';
import '../viewmodel/user_vm.dart';
import '../../../layout/admin_scaffold.dart';
import 'dart:math';

// Convert to a StatefulWidget to manage ScrollControllers
class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // We need two separate controllers: one for the main vertical scroll
  // and one for the horizontal scroll of the table.
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserVM>();

    return AdminScaffold(
      title: "User Management",
      child: (vm.isLoading && vm.paginatedUsers.isEmpty)
          ? const Center(child: CircularProgressIndicator())
      // This is the main layout for the entire page.
      // The Scrollbar is at the top level to be on the far right.
          : Scrollbar(
        controller: _verticalScrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _verticalScrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              if (vm.error != null) _buildErrorWidget(context, vm),
              _buildUserTable(context, vm),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the error message widget.
  Widget _buildErrorWidget(BuildContext context, UserVM vm) {
    // ... (This method is correct and does not need to change)
    return Container(/* ... */);
  }

  /// Builds the main container with the dropdown, DataTable, and pagination controls.
  Widget _buildUserTable(BuildContext context, UserVM vm) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Makes children fill width
        children: [
          // "Show entries" Dropdown
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 24),
            child: Row(
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
          ),
          const SizedBox(height: 16),
          // This combination makes the DataTable scroll horizontally if needed.
          Scrollbar(
            controller: _horizontalScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                dataRowHeight: 56,
                columnSpacing: 100, // Increased spacing for a wider look
                horizontalMargin: 24,
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
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
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: "Delete User",
                          onPressed: () => _confirmDelete(context, vm, user),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (vm.totalPages > 1) _buildPagination(vm),
          const SizedBox(height: 24),
        ],
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
                backgroundColor: p == vm.currentPage ? Colors.blue.shade900 : Colors.white,
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
  Future<void> _confirmDelete(BuildContext context, UserVM vm, UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: const Color(0xFF0A2A44),
        title: const Text("Confirm Delete", style: TextStyle(color: Colors.white)),
        content: Text(
          "Are you sure you want to delete ${user.fullName}?",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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