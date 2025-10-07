import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/features/contribute/viewmodel/contribute_viewmodel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ContributeScreenPage extends StatefulWidget {
  const ContributeScreenPage({super.key});

  @override
  State<ContributeScreenPage> createState() => _ContributeScreenPageState();
}

class _ContributeScreenPageState extends State<ContributeScreenPage> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _listenToConnectivity();
  }

  // Check initial connectivity - FIXED for newer API
  Future<void> _checkConnectivity() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  // Listen to connectivity changes - FIXED for newer API
  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
      });
    });
  }

  // Check if has internet connection - FIXED for newer API
  Future<bool> _hasInternetConnection() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Show offline dialog
  void _showOfflineDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.orange[700]),
              const SizedBox(width: 10),
              const Text('No Internet Connection'),
            ],
          ),
          content: const Text(
            'You need an internet connection to submit a word contribution. Please check your connection and try again.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(fontSize: 16, color: Colors.orange[700])),
            ),
          ],
        );
      },
    );
  }

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
              backgroundColor: const Color(0xFF0d2334),
              body: _isOnline
                  ? _buildContributeForm(context, vm)
                  : _buildOfflineContent(),
            ),
          );
        },
      ),
    );
  }

  // Offline content screen
  Widget _buildOfflineContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 100, color: Colors.orange[300]),
          const SizedBox(height: 24),
          const Text(
            'No Internet Connection',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'You need an internet connection to submit a word contribution.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[300]),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final hasInternet = await _hasInternetConnection();
                if (hasInternet) {
                  setState(() => _isOnline = true);
                } else {
                  _showOfflineDialog();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: const Color(0xFF333333),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text(
                    'TRY AGAIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributeForm(BuildContext context, ContributeViewModel vm) {
    return Column(
      children: [
        // Optional: Show banner even when online but want to inform user
        // Remove this if block if you only want offline screen
        if (!_isOnline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.orange[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 18, color: Colors.orange[800]),
                const SizedBox(width: 8),
                Text(
                  'Offline - Internet required to submit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
          ),

        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.83,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 24, top: 24, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                "Let's keep our language alive — send us a word!",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 24),
                              child: vm.isLoadingCount
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                                  : Text(
                                "${vm.remainingSubmissions}/5 left",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: vm.remainingSubmissions > 0
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Error message display
                      if (vm.errorMessage != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            border: Border.all(color: Colors.red[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  vm.errorMessage!,
                                  style: TextStyle(color: Colors.red[700], fontSize: 13),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: vm.clearError,
                                color: Colors.red[700],
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
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
                                buildTextField(vm.tagalogTranslationController, "Provide the Tagalog translation", "*Provide the Tagalog translation", vm),
                                buildPartOfSpeechDropdown(vm),
                                buildValidationText(vm.selectedPartOfSpeech == null, "*Choose the part of speech", vm),
                                buildTextField(vm.definitionController, "Provide the word's definition", "*Give a clear definition", vm, maxLines: 3),
                                buildTextField(vm.exampleSentenceInDialectController, "Example sentences in the selected dialect", "*Provide at least one example sentence in the selected dialect", vm, maxLines: 2),
                                buildTextField(vm.exampleSentenceInEnglishController, "Example sentences in English", "*Provide at least one example sentence in English", vm, maxLines: 2),
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
                                onPressed: vm.isSubmitting || !vm.canSubmit()
                                    ? null
                                    : () async {
                                  // CHECK INTERNET CONNECTION FIRST
                                  bool hasInternet = await _hasInternetConnection();
                                  if (!hasInternet) {
                                    _showOfflineDialog();
                                    return;
                                  }

                                  if (!vm.validateForm()) return;
                                  showSummaryModal(context, vm);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFC107),
                                  foregroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.grey[300],
                                  disabledForegroundColor: Colors.grey[600],
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                child: vm.isSubmitting
                                    ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                                    : const Text("Submit"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 120,
                              child: ElevatedButton(
                                onPressed: vm.isSubmitting ? null : vm.clearForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  foregroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.grey[200],
                                  disabledForegroundColor: Colors.grey[500],
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
      ],
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
      onChanged: vm.isSubmitting ? null : vm.selectDialect,
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
          onChanged: vm.isSubmitting ? null : vm.selectPartOfSpeech,
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
          enabled: !vm.isSubmitting,
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
      barrierDismissible: !vm.isSubmitting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                            buildSummaryRow("Example in Dialect:", vm.exampleSentenceInDialectController.text),
                            buildSummaryRow("Example in English:", vm.exampleSentenceInEnglishController.text),
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
                            onPressed: vm.isSubmitting
                                ? null
                                : () async {
                              // CHECK INTERNET AGAIN BEFORE FINAL SUBMIT
                              bool hasInternet = await _hasInternetConnection();
                              if (!hasInternet) {
                                Navigator.of(dialogContext).pop();
                                _showOfflineDialog();
                                return;
                              }

                              final success = await vm.submitForm();
                              if (success && dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                                if (context.mounted) {
                                  showSuccessModal(context);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC107),
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: Colors.grey[300],
                              disabledForegroundColor: Colors.grey[600],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            ),
                            child: vm.isSubmitting
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                                : const Text("Submit"),
                          ),
                          const SizedBox(width: 5),
                          ElevatedButton(
                            onPressed: vm.isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black,
                              disabledBackgroundColor: Colors.grey[200],
                              disabledForegroundColor: Colors.grey[500],
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