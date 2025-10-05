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

          // 🔹 Edit / Cancel button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: vm.selectionMode ? Colors.red.shade700 : Colors.blue.shade700,
              ),
              onPressed: vm.toggleSelectionMode,
              child: Text(vm.selectionMode ? "Cancel" : "Edit"),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Word list with optional selection checkboxes
          SizedBox(
            height: 500,
            child: ListView.separated(
              itemCount: vm.words.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final word = vm.words[index];
                final isSelected = vm.selectedWords.contains(word.word);

                return ListTile(
                  onTap: vm.selectionMode
                      ? () => vm.toggleWordSelection(word.word)
                      : null,
                  leading: vm.selectionMode
                      ? Checkbox(
                    value: isSelected,
                    onChanged: (_) => vm.toggleWordSelection(word.word),
                  )
                      : null,
                  title: Text(word.word),
                );
              },
            ),
          ),

          // 🔹 Delete selected button (only in selection mode)
          if (vm.selectionMode && vm.selectedWords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: vm.deleteSelectedWords,
                  child: const Text(
                    "Delete Selected",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dialectButton(BuildContext context, WordVM vm, String dialect) {
    final isSelected = vm.selectedDialect == dialect;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue.shade900 : Colors.grey.shade400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => vm.setDialect(dialect),
      child: Text(dialect),
    );
  }
}
