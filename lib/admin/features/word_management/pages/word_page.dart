import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/word_vm.dart';
import '../../../layout/admin_scaffold.dart';

// 🔹 Tarami Theme Colors
const brandNavyBlue = Color(0xFF0A1F44); // Solid Tarami brand navy blue

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
          // 🔹 Dialect buttons (centered)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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

          // 🔹 Edit / Cancel button (right aligned)
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandNavyBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: vm.toggleSelectionMode,
              child: Text(
                vm.selectionMode ? "Cancel" : "Edit",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Word list
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
                      : () => _showWordDetails(context, word),
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

          // 🔹 Delete selected button (bottom right)
          if (vm.selectionMode && vm.selectedWords.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: vm.deleteSelectedWords,
                  child: const Text(
                    "Delete Selected",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 🔹 Dialect Button
  Widget _dialectButton(BuildContext context, WordVM vm, String dialect) {
    final isSelected = vm.selectedDialect == dialect;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? brandNavyBlue : Colors.grey.shade400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => vm.setDialect(dialect),
      child: Text(dialect),
    );
  }

  // 🔹 Modal for showing word details (solid Tarami navy blue)
  void _showWordDetails(BuildContext context, word) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: brandNavyBlue, // ✅ Solid Tarami navy blue modal
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Title + Close button
                  Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'Details for "${word.word}"',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 🔹 Word details
                  _detailRow("Dialect:", word.dialect),
                  _detailRow("Word:", word.word),
                  _detailRow("Translation:", "eu"),
                  _detailRow("Phonetic:", "eu"),
                  _detailRow("Tagalog:", "oo"),
                  _detailRow("Part of Speech:", "Noun"),
                  _detailRow("Definition:", "agreeing to someone"),
                  _detailRow("Example (Dialect):", "eu nani"),
                  _detailRow("Example (English):", "oo nga"),
                  _detailRow("Synonyms:", "oo"),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🔹 Each labeled row in modal
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
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
}
