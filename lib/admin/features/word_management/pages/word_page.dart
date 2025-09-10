import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/word_vm.dart';
import '../../../layout/admin_scaffold.dart';

class WordPage extends StatelessWidget {
  const WordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WordVM>();

    return AdminScaffold(
      title: "Word Management",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Dialect buttons
          Row(
            children: [
              _dialectButton(context, vm, "Central Bikol"),
              const SizedBox(width: 12),
              _dialectButton(context, vm, "West Miraya"),
              const SizedBox(width: 12),
              _dialectButton(context, vm, "East Miraya"),
              const SizedBox(width: 12),
              _dialectButton(context, vm, "Libon Bikol"),
            ],
          ),
          const SizedBox(height: 24),

          // 🔹 Word list (safe: no Expanded)
          SizedBox(
            height: 500, // ✅ fixed safe height
            child: ListView.separated(
              itemCount: vm.words.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final word = vm.words[index];
                return ListTile(
                  title: Text(word.word),
                  trailing: TextButton(
                    onPressed: () {
                      // TODO: open edit modal
                    },
                    child: const Text("Edit"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Dialect button widget
  Widget _dialectButton(BuildContext context, WordVM vm, String dialect) {
    final isSelected = vm.selectedDialect == dialect;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue.shade900 : Colors.grey.shade400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () => vm.setDialect(dialect),
      child: Text(dialect),
    );
  }
}
