import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_vm.dart';
import '../../../layout/admin_scaffold.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserVM>();

    return AdminScaffold(
      title: "User Management",
      child: Center(
        child: SizedBox(
          width: 1200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                child: DataTable(
                  headingRowHeight: 48,
                  dataRowHeight: 56,
                  columnSpacing: 60,
                  horizontalMargin: 16,
                  headingRowColor: MaterialStateProperty.all(
                    Colors.grey.shade100,
                  ),
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  columns: const [
                    DataColumn(label: Expanded(child: Text("Name"))),
                    DataColumn(label: Expanded(child: Text("Email"))),
                    DataColumn(label: Expanded(child: Text("Contact Number"))),
                    DataColumn(label: Expanded(child: Text("Submitted Words"))),
                    DataColumn(label: Expanded(child: Text("Actions"))),
                  ],
                  rows: vm.users.map((user) {
                    return DataRow(
                      cells: [
                        DataCell(Text(user.name)),
                        DataCell(Text(user.email)),
                        DataCell(Text(user.contactNumber ?? "-")),
                        DataCell(Text(user.submittedWords.toString())),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: "Delete User",
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    backgroundColor: const Color(0xFF0A2A44), // Tarami blue
                                    title: const Text(
                                      "Confirm Delete",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      "Are you sure you want to delete ${user.name}?",
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {
                                vm.deleteUser(user);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
