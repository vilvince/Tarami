import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/contribute_vm.dart';

class ContributePage extends StatelessWidget {
  const ContributePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContributeVM(),
      child: Consumer<ContributeVM>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Contribute"),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Dialect Dropdown
                  DropdownButtonFormField<String>(
                    value: vm.selectedDialect,
                    hint: const Text("Select Dialect"),
                    items: vm.dialects
                        .map((dialect) => DropdownMenuItem(
                      value: dialect,
                      child: Text(dialect),
                    ))
                        .toList(),
                    onChanged: (val) {
                      vm.selectedDialect = val;
                      vm.notifyListeners();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Word
                  TextField(
                    controller: vm.wordController,
                    decoration: const InputDecoration(labelText: "Word"),
                  ),
                  const SizedBox(height: 12),

                  // Translation
                  TextField(
                    controller: vm.translationController,
                    decoration: const InputDecoration(labelText: "Translation"),
                  ),
                  const SizedBox(height: 12),

                  // Pronunciation
                  TextField(
                    controller: vm.pronunciationController,
                    decoration: const InputDecoration(labelText: "Pronunciation"),
                  ),
                  const SizedBox(height: 12),

                  // Part of Speech Dropdown
                  DropdownButtonFormField<String>(
                    value: vm.selectedPartOfSpeech,
                    hint: const Text("Select Part of Speech"),
                    items: vm.partsOfSpeech
                        .map((pos) => DropdownMenuItem(
                      value: pos,
                      child: Text(pos),
                    ))
                        .toList(),
                    onChanged: (val) {
                      vm.selectedPartOfSpeech = val;
                      vm.notifyListeners();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Meaning
                  TextField(
                    controller: vm.meaningController,
                    decoration: const InputDecoration(labelText: "Meaning"),
                  ),
                  const SizedBox(height: 12),

                  // Sentence
                  TextField(
                    controller: vm.sentenceController,
                    decoration: const InputDecoration(labelText: "Sentence Example"),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () {
                      vm.submitContribution();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Contribution submitted!")),
                      );
                    },
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
