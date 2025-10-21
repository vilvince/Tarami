import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/admin/layout/admin_scaffold.dart';
import 'package:tarami_application/features/contribute/viewmodel/contribute_viewmodel.dart';

class ContributePage extends StatelessWidget {
  const ContributePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: "Contribute",
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          // 🔹 Limit form width
          child: ChangeNotifierProvider(
            create: (_) => ContributeViewModel(),
            child: Consumer<ContributeViewModel>(
              builder: (context, vm, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Let’s keep our language alive — send us a word!",
                      textAlign: TextAlign.center,
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Dialect dropdown
                    _buildDialectDropdown(vm),
                    _buildValidationText(
                        vm.selectedDialect == null,
                        "*Select a dialect from the list",
                        vm),
                    const SizedBox(height: 16),

                    // Word
                    _buildTextField(
                        vm.wordController,
                        "Please enter the word you want to contribute",
                        "*Enter the word you want to contribute",
                        vm),
                    const SizedBox(height: 16),

                    // Translation
                    _buildTextField(
                        vm.translationController,
                        "Provide the translation in the selected dialect",
                        "*Provide the translation",
                        vm),
                    const SizedBox(height: 16),

                    // Phonetic
                    _buildTextField(vm.phoneticController,
                        "Phonetic (e.g., /va·ken·si/)",
                        "*Required", vm),
                    const SizedBox(height: 16),

                    // Tagalog translation
                    _buildTextField(
                        vm.tagalogTranslationController,
                        "Provide the Tagalog translation",
                        "*Provide the Tagalog translation",
                        vm),
                    const SizedBox(height: 16),

                    // Part of Speech
                    _buildPartOfSpeechDropdown(vm),
                    _buildValidationText(vm.selectedPartOfSpeech == null,
                        "*Choose the part of speech", vm),
                    const SizedBox(height: 16),

                    // Definition
                    _buildTextField(
                        vm.definitionController,
                        "Describe the meaning of the word clearly",
                        "*Give a clear definition",
                        vm,
                        maxLines: 2),
                    const SizedBox(height: 16),

                    // Example
                    _buildTextField(
                        vm.exampleController,
                        "Use the word in a sentence to show how it’s used",
                        "*Provide at least one example sentence",
                        vm,
                        maxLines: 2),
                    const SizedBox(height: 16),

                    // Synonyms
                    _buildTextField(
                        vm.synonymsController,
                        "Synonyms (separate with commas)",
                        "*Optional",
                        vm,
                        maxLines: 2),
                    const SizedBox(height: 32),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFDC500),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            if (!vm.validateForm()) return;
                            if (!vm.canSubmit()) {
                              showDialog(
                                context: context,
                                builder: (_) =>
                                const AlertDialog(
                                  title: Text("Limit Reached"),
                                  content: Text(
                                      "You can only submit 5 words per day."),
                                ),
                              );
                              return;
                            }
                            showSummaryModal(context, vm);
                          },
                          child: const Text("Submit",
                              style: TextStyle(color: Colors.black)),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: vm.clearForm,
                          child: const Text("Cancel"),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ------- Helpers --------

  Widget _buildDialectDropdown(ContributeViewModel vm) {
    return DropdownButtonFormField<String>(
      value: vm.selectedDialect,
      decoration: _inputDecoration("Please select a dialect"),
      items: vm.dialects
          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
          .toList(),
      onChanged: vm.selectDialect,
    );
  }

  Widget _buildPartOfSpeechDropdown(ContributeViewModel vm) {
    return DropdownButtonFormField<String>(
      value: vm.selectedPartOfSpeech,
      decoration: _inputDecoration(
          "Select the correct part of speech (e.g., noun, verb)"),
      items: vm.partsOfSpeech
          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
          .toList(),
      onChanged: vm.selectPartOfSpeech,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String errorText, ContributeViewModel vm,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: _inputDecoration(label),
        ),
        if (vm.showValidationErrors && controller.text.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 5),
            child: Text(errorText,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildValidationText(bool condition, String message,
      ContributeViewModel vm) {
    return condition && vm.showValidationErrors
        ? Padding(
      padding: const EdgeInsets.only(top: 6, left: 5),
      child: Text(message,
          style: const TextStyle(color: Colors.red, fontSize: 12)),
    )
        : const SizedBox.shrink();
  }

  // 🔹 Shared input style
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // ------- Modals --------
  void showSummaryModal(BuildContext context, ContributeViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0A2A44), // 🔹 Dark blue background
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Review your submission:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white, // 🔹 White text
                  ),
                ),
                const SizedBox(height: 12),
                buildSummaryRow("Dialect:", vm.selectedDialect ?? ""),
                buildSummaryRow("Word:", vm.wordController.text),
                buildSummaryRow("Translation:", vm.translationController.text),
                buildSummaryRow("Phonetic:", vm.phoneticController.text),
                buildSummaryRow(
                    "Tagalog:", vm.tagalogTranslationController.text),
                buildSummaryRow(
                    "Part of Speech:", vm.selectedPartOfSpeech ?? ""),
                buildSummaryRow("Definition:", vm.definitionController.text),
                if (vm.etymologyController.text.isNotEmpty)
                  buildSummaryRow("Etymology:", vm.etymologyController.text),
                buildSummaryRow("Example:", vm.exampleController.text),
                buildSummaryRow("Synonyms:", vm.synonymsController.text),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        vm.submitForm();
                        Navigator.of(context).pop();
                        showSuccessModal(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        // 🔹 Yellow button
                        foregroundColor: Colors.black,
                        // 🔹 Black text
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                      ),
                      child: const Text("Submit"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300], // 🔹 Grey for Edit
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                      ),
                      child: const Text("Edit"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void showSuccessModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0A2A44), // 🔹 Dark blue background
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Great job! Your word was submitted.\nWant to add more?",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white, // 🔹 White text
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        // 🔹 Yellow button
                        foregroundColor: Colors.black,
                        // 🔹 Black text
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: const Text("Ok"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white, // 🔹 White labels
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white), // 🔹 White values
            ),
          ),
        ],
      ),
    );
  }
}