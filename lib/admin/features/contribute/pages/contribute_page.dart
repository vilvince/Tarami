import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/admin/layout/admin_scaffold.dart';
import 'package:tarami_application/admin/features/contribute/viewmodel/contribute_vm.dart';

class ContributePage extends StatelessWidget {
  const ContributePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: "Contribute",
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
                child: ChangeNotifierProvider(
                  create: (_) => AdminContributeViewModel(),
                  child: Consumer<AdminContributeViewModel>(
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

                          // Example in dialect
                          _buildTextField(
                              vm.exampleSentenceInDialectController,
                              "Use the word in a sentence to show how it’s used in dialect",
                              "*Provide at least one example sentence",
                              vm,
                              maxLines: 2),
                          const SizedBox(height: 16),

                          // Example in English
                          _buildTextField(
                              vm.exampleSentenceInEnglishController,
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
        ),
      ),
    );
  }

  // ------- Helpers --------

  Widget _buildDialectDropdown(AdminContributeViewModel vm) {
    return DropdownButtonFormField<String>(
      value: vm.selectedDialect,
      decoration: _inputDecoration("Please select a dialect"),
      items: vm.dialects
          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
          .toList(),
      onChanged: vm.selectDialect,
    );
  }

  Widget _buildPartOfSpeechDropdown(AdminContributeViewModel vm) {
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
      String errorText, AdminContributeViewModel vm,
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
      AdminContributeViewModel vm) {
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
  void showSummaryModal(BuildContext context, AdminContributeViewModel vm) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF0A2A44), // 🔹 Dark blue background
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
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
                    buildSummaryRow(
                        "Translation:", vm.translationController.text),
                    buildSummaryRow("Phonetic:", vm.phoneticController.text),
                    buildSummaryRow(
                        "Tagalog:", vm.tagalogTranslationController.text),
                    buildSummaryRow(
                        "Part of Speech:", vm.selectedPartOfSpeech ?? ""),
                    buildSummaryRow(
                        "Definition:", vm.definitionController.text),
                    buildSummaryRow("Example in Dialect:",
                        vm.exampleSentenceInDialectController.text),
                    buildSummaryRow("Example (English):",
                        vm.exampleSentenceInEnglishController.text),
                    buildSummaryRow("Synonyms:", vm.synonymsController.text),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (vm.isSubmitting)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        if (!vm.isSubmitting) ...[
                          ElevatedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
                            child: const Text("Edit"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            // ✅ THIS IS THE UPDATED ONPRESSED LOGIC
                            onPressed: () async {
                              try {
                                await vm.submitContribution();
                                // On success, close the summary dialog and show the success modal.
                                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                                if (context.mounted) showSuccessModal(context);
                              } catch (e) {
                                // On failure, close the summary dialog and show the new error modal.
                                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                                if (context.mounted) {
                                  _showErrorModal(context, e.toString());
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC107)),
                            child: const Text("Submit"),
                          ),
                        ]
                      ],
                    )
                  ],
                );
              },
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

  void _showErrorModal(BuildContext context, String message) {
    // Clean up the error message (removes "Exception: " prefix)
    final displayMessage = message.startsWith('Exception: ') ? message.substring(11) : message;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFF0A2A44), // Dark blue background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
              const SizedBox(height: 16),
              Text(
                'Submission Failed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                displayMessage, // Use the cleaned-up message
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}