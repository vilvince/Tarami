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
  Timer? _idleTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _recognizedText = "";
  bool _showIdleMessage = false;

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
    _idleTimer?.cancel();
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
      _showIdleMessage = false;
    });

    _showVoiceDialog();

    // Start idle timer (show message after 5 seconds of no speech)
    _startIdleTimer();

    await _voiceService.startListening(
      onResult: (recognizedText) {
        _idleTimer?.cancel(); // Cancel idle timer when speech is detected
        if (recognizedText.isNotEmpty) {
          setState(() => _recognizedText = recognizedText);
          _searchController.text = recognizedText;
          dictVm.searchWords(recognizedText);
        }
      },
      onListening: () {
        setState(() {
          _isListening = true;
          _showIdleMessage = false;
        });
      },
      onNotListening: () {
        setState(() => _isListening = false);
        _idleTimer?.cancel();
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
    );
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _recognizedText.isEmpty) {
        setState(() => _showIdleMessage = true);
      }
    });
  }

  void _showVoiceDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // ✅ Allow closing by tapping outside
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            // Stop listening when dialog is dismissed
            await _voiceService.stopListening();
            _idleTimer?.cancel();
            if (mounted) {
              setState(() => _isListening = false);
            }
            return true;
          },
          child: StatefulBuilder(builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Icon(
                        Icons.mic,
                        color: _showIdleMessage ? Colors.orange : Colors.redAccent,
                        size: 70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _showIdleMessage
                          ? "Please try again"
                          : _isListening
                          ? "Listening..."
                          : "Processing...",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: _showIdleMessage ? Colors.orange : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _recognizedText.isEmpty
                          ? (_showIdleMessage ? "No speech detected" : "Speak now...")
                          : _recognizedText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }),
        );
      },
    ).then((_) {
      // Cleanup when dialog closes
      _voiceService.stopListening();
      _idleTimer?.cancel();
      if (mounted) {
        setState(() => _isListening = false);
      }
    });
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

                  // Search bar
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
                            textCapitalization: TextCapitalization.sentences,
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
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.grey, size: 22),
                                onPressed: () {
                                  _searchController.clear();
                                  dictVm.searchWords("");
                                  setState(() {});
                                },
                              )
                                  : IconButton(
                                icon: const Icon(Icons.mic,
                                    color: Colors.grey, size: 25),
                                onPressed: _startVoiceSearch,
                              ),
                            ),
                            style: const TextStyle(color: Colors.black87),
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