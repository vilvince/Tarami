import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/features/contribute/viewmodel/contribute_viewmodel.dart';

class ContributeScreenPage extends StatelessWidget {
  const ContributeScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContributeViewModel(),
      child: Consumer<ContributeViewModel>(
        builder: (context, vm, _) {
          return Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Colors.black,
                selectionColor: Colors.black26,
                selectionHandleColor: Colors.black,
              ),
              inputDecorationTheme: InputDecorationTheme(
                hintStyle: const TextStyle(color: Colors.black54),
                labelStyle: const TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            child: Scaffold(
              backgroundColor: const Color(0xFF0A2A44),
              body: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.78,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              "Let’s keep our language alive — send us a word!",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ScrollConfiguration(
                              behavior: const ScrollBehavior().copyWith(overscroll: false),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildDialectDropdown(vm),
                                    buildValidationText(vm.selectedDialect == null, "*Select a dialect from the list", vm),
                                    buildTextField(vm.wordController, "Please enter the word you want to contribute", "*Enter the word you want to contribute", vm),
                                    buildTextField(vm.translationController, "Provide the translation in the selected dialect", "*Provide the translation", vm),
                                    buildTextField(vm.phoneticController, "Phonetic (e.g., /va·kan·si/)", "*Required", vm),
                                    buildTextField(vm.tagalogTranslationController, "Provide the Tagalog translation",  "*Provide the Tagalog translation", vm),
                                    buildPartOfSpeechDropdown(vm),
                                    buildValidationText(vm.selectedPartOfSpeech == null, "*Choose the part of speech", vm),
                                    buildTextField(vm.definitionController, "Provide the word’s definition", "*Give a clear definition", vm, maxLines: 3),
                                    buildTextField(
                                      vm.etymologyController,
                                      "Etymology (Optional)",
                                      "Enter the origin or history of the word",
                                      vm,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 12.0, top: 4.0, bottom: 12.0),
                                      child: Text(
                                        "Note: Etymology means the origin or history of a word, e.g., from Latin or Spanish.",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                    buildTextField(vm.exampleController, "Example sentences (e.g., I like eating sinapot.)", "*Provide at least one example sentence", vm, maxLines: 2),
                                    buildTextField(vm.synonymsController, "Synonyms (separate with commas)", "*Provide synonyms if available", vm, maxLines: 2),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (!vm.validateForm()) return;
                                      if (!vm.canSubmit()) {
                                        showDialog(
                                          context: context,
                                          builder: (_) => const AlertDialog(
                                            title: Text("Limit Reached"),
                                            content: Text("You can only submit 5 words per day."),
                                          ),
                                        );
                                        return;
                                      }
                                      showSummaryModal(context, vm);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFC107),
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    child: const Text("Submit"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 120,
                                  child: ElevatedButton(
                                    onPressed: vm.clearForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[300],
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    child: const Text("Cancel"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildDialectDropdown(ContributeViewModel vm) {
    return DropdownButtonFormField<String>(
      value: vm.selectedDialect,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: "Select a dialect",
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      menuMaxHeight: 200,
      isExpanded: true,
      items: vm.dialects.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
      onChanged: vm.selectDialect,
    );
  }

  Widget buildPartOfSpeechDropdown(ContributeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: vm.selectedPartOfSpeech,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: "Part of speech",
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight: 200,
          isExpanded: true,
          items: vm.partsOfSpeech.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: vm.selectPartOfSpeech,
        ),
      ],
    );
  }

  Widget buildTextField(TextEditingController controller, String label, String errorText, ContributeViewModel vm, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          ),
        ),
        if (vm.showValidationErrors && controller.text.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 5),
            child: Text(errorText, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  Widget buildValidationText(bool condition, String message, ContributeViewModel vm) {
    return condition && vm.showValidationErrors
        ? Padding(
      padding: const EdgeInsets.only(top: 6, left: 5),
      child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 12)),
    )
        : const SizedBox(height: 10);
  }

  void showSummaryModal(BuildContext context, ContributeViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0A2A44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 350,
            constraints: const BoxConstraints(maxHeight: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        buildSummaryRow("Dialect:", vm.selectedDialect ?? ""),
                        buildSummaryRow("Word:", vm.wordController.text),
                        buildSummaryRow("Translation:", vm.translationController.text),
                        buildSummaryRow("Phonetic:", vm.phoneticController.text),
                        buildSummaryRow("Tagalog:", vm.tagalogTranslationController.text),
                        buildSummaryRow("Part of Speech:", vm.selectedPartOfSpeech ?? ""),
                        buildSummaryRow("Definition:", vm.definitionController.text),
                        if (vm.etymologyController.text.isNotEmpty)
                          buildSummaryRow("Etymology:", vm.etymologyController.text),
                        buildSummaryRow("Example:", vm.exampleController.text),
                        buildSummaryRow("Synonyms:", vm.synonymsController.text),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          vm.submitForm();
                          Navigator.of(context).pop(); // close summary modal

                          // show success modal using parent context
                          Future.microtask(() {
                            showSuccessModal(
                              Navigator.of(context, rootNavigator: true).context,
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        ),
                        child: const Text("Submit"),
                      ),

                      const SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        ),
                        child: const Text("Edit"),
                      ),
                    ],
                  ),
                ),
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
          backgroundColor: const Color(0xFF0A2A44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    color: Colors.white,
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
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
