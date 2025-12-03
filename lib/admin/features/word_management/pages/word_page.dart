import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/word_vm.dart';
import '../../../layout/admin_scaffold.dart';
import '../data/word_model.dart';

// 🔹 Tarami Theme Colors
const brandNavyBlue = Color(0xFF0A1F44); // Solid Tarami brand navy blue

class WordPage extends StatelessWidget {
  const WordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WordVM>();

    return AdminScaffold(
      title: "Word Management",
      child: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
          ? Center(child: Text(vm.error!))
          : Column(
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

          // 🔹 Word list
          SizedBox(
            height: 450,
            child: ListView.separated(
              itemCount: vm.filteredWords.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final word = vm.filteredWords[index];
                final isSelected = vm.selectedUniqueIds.contains(word.uniqueId);

                return ListTile(
                  onTap: vm.selectionMode
                      ? () => vm.toggleWordSelection(word.uniqueId)
                      : () => _showWordDetails(context, word),
                  leading: vm.selectionMode
                      ? Checkbox(
                    value: isSelected,
                    onChanged: (_) => vm.toggleWordSelection(word.uniqueId),
                  )
                      : null,
                  title: Text(word.word),
                );
              },
            ),
          ),

          // 🔹 Delete selected button (bottom right)
          if (vm.selectionMode && vm.selectedUniqueIds.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _confirmDelete(context, vm),
                  child: Text(
                    "Delete ${vm.selectedUniqueIds.length} ${vm.selectedUniqueIds.length == 1 ? 'Word' : 'Words'}",
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
  void _showWordDetails(BuildContext context, WordModel word) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: brandNavyBlue,
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
                  _detailRow("Translation:", word.translation ?? 'N/A'),
                  _detailRow("Phonetic:", word.phonetic ?? 'N/A'),
                  _detailRow("Tagalog:", word.tagalog ?? 'N/A'),
                  _detailRow("Part of Speech:", word.partOfSpeech ?? 'N/A'),
                  _detailRow("Definition:", word.definition ?? 'N/A'),
                  _detailRow("Example (Dialect):", word.exampleDialect ?? 'N/A'),
                  _detailRow("Example (English):", word.exampleEnglish ?? 'N/A'),
                  _detailRow("Synonyms:", word.synonyms ?? 'N/A'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 🔹 Seamless deletion with loading inside confirmation dialog and snackbar
  Future<void> _confirmDelete(BuildContext context, WordVM vm) async {
    final int countToDelete = vm.selectedUniqueIds.length;
    if (countToDelete == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A2A44),

        title: const Text(
          "Confirm Deletion",
          style: TextStyle(color: Colors.white),
        ),
        content: Text("Are you sure you want to delete ${vm.selectedUniqueIds.length} ${vm.selectedUniqueIds.length == 1 ? 'Word' : 'Words'}? This action cannot be undone.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel",  style: TextStyle(color: Colors.white),),),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // The ViewModel will now set isLoading=true, and the UI will show a spinner.
        await vm.deleteSelectedWords();

        // After success, show the SnackBar.
        if (context.mounted) {
          final String wordOrWords = countToDelete == 1 ? 'word' : 'words';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully deleted $countToDelete $wordOrWords'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // If the VM throws an error, show it in a SnackBar.
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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

