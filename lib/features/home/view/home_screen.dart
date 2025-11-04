import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/features/home/viewmodel/home_viewmodel.dart';
import 'package:tarami_application/features/dictionary/viewmodel/dictionary_view_model.dart';
import 'package:tarami_application/widgets/main_scaffold.dart';
import 'dart:async';
import 'package:tarami_application/core/services/voice_search_service.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({super.key});

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final VoiceSearchService _voiceService = VoiceSearchService();
  bool _isSearching = false;
  bool _isListening = false;
  Timer? _debounce;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _recognizedText = "";

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _voiceService.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startVoiceSearch() async {
    final dictVm = Provider.of<DictionaryViewModel>(context, listen: false);
    final isReady = await _voiceService.initialize();

    if (!isReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not initialized')),
      );
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = "";
    });
    _showVoiceDialog();

    await _voiceService.startListening(
      onResult: (recognizedText) {
        if (recognizedText.isNotEmpty) {
          setState(() => _recognizedText = recognizedText);
          _searchController.text = recognizedText;
          dictVm.searchWords(recognizedText);
        }
      },
      onListening: () {
        setState(() => _isListening = true);
      },
      onNotListening: () {
        setState(() => _isListening = false);
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
    );
  }

  void _showVoiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: const Icon(Icons.mic, color: Colors.redAccent, size: 70),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isListening ? "Listening..." : "Processing...",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _recognizedText.isEmpty ? "" : _recognizedText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () async {
                      await _voiceService.stopListening();
                      if (mounted) {
                        setState(() => _isListening = false);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Stop",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dictVm = Provider.of<DictionaryViewModel>(context);
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: isKeyboardVisible ? 40 : 150,
              child: Image.asset(
                'assets/TaramiLogo.png',
                width: 350,
                fit: BoxFit.contain,
              ),
            ),

            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: isKeyboardVisible ? 180 : 330,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Search bar (same design)
                  Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isListening ? Colors.red : Colors.black26,
                        width: _isListening ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            cursorColor: Colors.black,
                            controller: _searchController,
                            textAlign: TextAlign.left,
                            textAlignVertical: TextAlignVertical.center,
                            onChanged: (query) {
                              if (_debounce?.isActive ?? false) _debounce!.cancel();
                              setState(() => _isSearching = true);
                              _debounce = Timer(const Duration(milliseconds: 100), () async {
                                await dictVm.searchWords(query);
                                setState(() => _isSearching = false);
                              });
                            },
                            decoration: InputDecoration(
                              hintText: _isListening ? 'Listening...' : 'Search...',
                              hintStyle: TextStyle(
                                color: _isListening ? Colors.red : Colors.black54,
                                fontSize: 18,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),

                        // ✅ New Google-style mic button
                        GestureDetector(
                          onTap: _isListening ? null : _startVoiceSearch,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.mic,
                              color: _isListening ? Colors.white : Colors.grey[0],
                              size: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_searchController.text.isNotEmpty && dictVm.searchResults.isNotEmpty)
                    _buildResultsList(dictVm)
                  else if (_searchController.text.isNotEmpty &&
                      dictVm.searchResults.isEmpty &&
                      !_isSearching)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "No words found",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(DictionaryViewModel dictVm) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black26),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: dictVm.searchResults.length,
        itemBuilder: (context, index) {
          final entry = dictVm.searchResults[index];
          return Column(
            children: [
              ListTile(
                leading: const Icon(Icons.search, color: Colors.grey),
                title: Text(entry.word),
                onTap: () {
                  dictVm.selectWord(entry.word);
                  MainScaffold.of(context)?.changeTab(1);
                },
              ),
              if (index < dictVm.searchResults.length - 1)
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 48,
                  endIndent: 16,
                  color: Colors.black12,
                ),
            ],
          );
        },
      ),
    );
  }
}
