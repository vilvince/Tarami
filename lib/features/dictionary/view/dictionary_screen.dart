import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/dictionary_view_model.dart';
import 'package:tarami_application/features/user/view/favorite_screen.dart';
import 'package:tarami_application/core/services/voice_search_service.dart';
import 'dart:async';

class Dictionary extends StatefulWidget {
  const Dictionary({super.key});

  @override
  State<Dictionary> createState() => _DictionaryState();
  }


class _DictionaryState extends State<Dictionary> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final VoiceSearchService _voiceService = VoiceSearchService();
  bool _isSearchLocked = false;
  bool _isListening = false;
  bool _showIdleMessage = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _recognizedText = "";
  Timer? _idleTimer;


  @override
  void dispose() {
    _searchController.dispose();
    _voiceService.dispose();
    _pulseController.dispose();
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize dictionary data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DictionaryViewModel>().initialize();
    });

    // Setup pulse animation for microphone
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
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
    final viewModel = context.watch<DictionaryViewModel>();

    if (viewModel.searchQuery.isEmpty && _searchController.text.isNotEmpty) {
      // We use a post-frame callback to avoid modifying the controller during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchController.clear();
      });
    }

    return WillPopScope(
        onWillPop: () async {
          if (viewModel.selectedWord != null) {
            // ✅ Instead of closing the app, clear selection and reload list
            viewModel.selectWord(null);
            viewModel.searchWords("");
            return false; // stop Navigator.pop
          }
          return true; // allow normal back navigation when no word is selected
        },

      child: Scaffold(
      backgroundColor: const Color(0xFF0B1D2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1D2B),
        elevation: 0,
        leading: viewModel.selectedWord != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            viewModel.selectWord(null);
            viewModel.searchWords(""); // ✅ reload full list immediately
          },
        )
            : null,
        title: _buildSearchBar(),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const FavoriteScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlainTextDialectRow(viewModel),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: viewModel.selectedWord == null
                  ? _buildWordList(viewModel)
                  : _buildDetailView(viewModel),
            ),
          ),
        ],
      ),
    ),
    );
  }


  Widget _buildSynonyms(DictionaryViewModel viewModel, String word) {
    final synonymsList = viewModel.getSynonyms(word);

    if (synonymsList.isEmpty) {
      return const Text(
        "No synonyms available",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      );
    }

    return Wrap(
      spacing: 6.0,
      runSpacing: 4.0,
      children: List.generate(synonymsList.length, (index) {
        final syn = synonymsList[index];
        final exists = viewModel.currentWordList
            .map((w) => w.toLowerCase().trim())
            .contains(syn.toLowerCase().trim());

        return GestureDetector(
          onTap: exists ? () => viewModel.selectWord(syn) : null,
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 18,
                color: exists ? Colors.blueAccent : Colors.black,
                decoration: exists ? TextDecoration.underline : TextDecoration.none,
              ),
              children: [
                TextSpan(text: syn),
                if (index < synonymsList.length - 1)
                  const TextSpan(
                    text: ',',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }




  Widget _buildSearchBar() {
    return GestureDetector(
        onTap: () {
          setState(() => _isSearchLocked = false); // Unlock on tap
        },
    child:  Container(
      height: 50,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              readOnly: _isSearchLocked,
              cursorColor: Colors.black,
              controller: _searchController, // ✅ attach controller here
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (query) {
                final vm = context.read<DictionaryViewModel>();
                if (vm.selectedWord != null) {
                  vm.selectWord(null);
                }
                vm.searchWords(query);
                setState(() {}); // rebuild to show/hide ❌ button
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                suffixIcon: _isSearchLocked
                    ? null
                    : _searchController.text.isNotEmpty
                         ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey, size: 22),
                  onPressed: () {
                    _searchController.clear();
                    final vm = context.read<DictionaryViewModel>();
                    vm.searchWords("");
                    setState(() {});
                  },
                )
                : GestureDetector(
                  onTap: _isListening ? null : _startVoiceSearch,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.mic,
                      color: _isListening ? Colors.redAccent : Colors.grey,
                      size: 25,
                    ),
                  ),
                ),
              ),
              style: const TextStyle(color: Colors.black87),
              onTap: () => setState(() => _isSearchLocked = false), // ✅ Unlock
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildPlainTextDialectRow(DictionaryViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(viewModel.dialects.length, (index) {
            final isSelected = index == viewModel.selectedDialectIndex;
            return GestureDetector(
              onTap: () => viewModel.selectDialect(index),
              child: Padding(
                padding: const EdgeInsets.only(right: 40),
                child: Text(
                  viewModel.dialects[index],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.amber : Colors.white,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildWordList(DictionaryViewModel viewModel) {
    if (viewModel.isLoading || viewModel.isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading dictionary...'),
          ],
        ),
      );
    }
    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${viewModel.errorMessage}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                viewModel.clearError();
                viewModel.refresh();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
        if (viewModel.currentWordList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              viewModel.searchQuery.isNotEmpty
                  ? 'No words found for "${viewModel.searchQuery}"'
                  : 'No words available',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

// In lib/features/dictionary/view/dictionary_screen.dart

    return ListView.builder(
      itemCount: viewModel.currentWordList.length,
      itemBuilder: (context, index) {
        final word = viewModel.currentWordList[index];

        final String firstLetter = word.isNotEmpty ? word[0].toUpperCase() : '#';
        final String headerText = "$firstLetter${firstLetter.toLowerCase()}";

        bool showHeader = false;

        if (viewModel.searchQuery.isEmpty) {
          if (index == 0) {
            showHeader = true;
          } else {
            final String prevWord = viewModel.currentWordList[index - 1];
            final String prevFirstLetter = prevWord.isNotEmpty ? prevWord[0].toUpperCase() : '#';
            if (firstLetter != prevFirstLetter) {
              showHeader = true;
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ HEADER
            if (showHeader)
              Padding(
                // Top: 24 (Space from previous section)
                // Bottom: -5 (Negative margin to pull the next item UP)
                padding: const EdgeInsets.only(left: 17, right: 20, top: 24, bottom: 0),
                child: Text(
                  headerText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6C6B6B),
                    height: 0.8, // ✅ Reduce line height to less than 1.0 to crop font padding
                  ),
                ),
              ),

            // ✅ WORD ITEM
            // Use Transform.translate to nudge the list tile up slightly
            Transform.translate(
              offset: showHeader ? const Offset(0, -5) : Offset.zero, // ✅ Move up 5px if under a header
              child: ListTile(
                minVerticalPadding: 10,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                visualDensity: const VisualDensity(vertical: -4), // ✅ Compact the tile vertically

                title: Text(
                  word,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  if (viewModel.searchQuery.isNotEmpty) {
                    _searchController.text = viewModel.currentWordList[index];
                    setState(() => _isSearchLocked = true);
                  }
                  FocusScope.of(context).unfocus();
                  viewModel.selectWord(viewModel.currentWordList[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailView(DictionaryViewModel viewModel) {
    final word = viewModel.selectedWord!.word;
    final rawTranslation = viewModel.getDialectTranslation(word);
    final dialectTranslation = (rawTranslation == null || rawTranslation.trim().isEmpty)
        ? "No translation available"
        : rawTranslation;
    final phonetics = viewModel.getPhoneticsForDialect(word);
    final tagalog = viewModel.getTagalogTranslation(word) ?? "Not available";
    final definition = viewModel.getDefinition(word) ?? "Definition not available";
    final partOfSpeech = viewModel.getPartOfSpeech(word) ?? "Unknown";
    final sampleInEnglish = viewModel.getSampleSentenceInEnglish(word);
    final sampleInDialect = viewModel.getSampleSentence(word);
    final audioUrl = viewModel.getAudioUrlForSelectedDialect();


    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Word Title
          Padding(
            padding: const EdgeInsets.only(top: 26),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min, // 👈 shrinks to fit content (word + icon)
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      word,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // prevents overflow on super long words
                    ),
                  ),
                  const SizedBox(width: 10), // small space between word and heart
                  GestureDetector(
                    onTap: () {
                      viewModel.toggleFavorite(word);
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: animation,
                        child: child,
                      ),
                      child: Icon(
                        viewModel.isFavorite(word)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        key: ValueKey(viewModel.isFavorite(word)),
                        size: 28,
                        color: viewModel.isFavorite(word)
                            ? Colors.amber
                            : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Tagalog & POS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tagalog: $tagalog",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),


                 Align(
                   alignment: Alignment.centerRight,
                   child: Text(
                    partOfSpeech,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                   ),
                 ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Translation Card
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Translation",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(thickness: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              dialectTranslation,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              phonetics.isNotEmpty ? phonetics : "/${word.toLowerCase()}/",
                              style: const TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (audioUrl != null && audioUrl.isNotEmpty) // 👈 show only if audio exists
                        IconButton(
                          icon: const Icon(Icons.volume_up_outlined, size: 28),
                          color: Colors.black,
                          tooltip: 'Listen to pronunciation',
                          onPressed: () async {
                            try {
                              // Try to play the audio.
                              await viewModel.playAudio(audioUrl);
                            } catch (e) {
                              // If it throws an error (like being offline), show a SnackBar.
                              if (mounted) { // mounted is available because this is a StatefulWidget
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString().replaceFirst("Exception: ", "")),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Definition Card
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Definition",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(thickness: 1),
                  const SizedBox(height: 8),
                  Text(
                    definition,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sample Sentence Card
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sample Sentence",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(thickness: 1),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(

                      style: DefaultTextStyle.of(context).style.copyWith( // Inherit default text style
                        fontSize: 18,
                        color: Colors.black, // Or your desired default color for this section
                      ),
                      children: <TextSpan>[
                        const TextSpan(
                          text: 'English',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // No need to repeat fontSize or color if inherited correctly
                          ),
                        ),
                        TextSpan(text: ' : $sampleInEnglish'), // Inherits base style (normal weight)
                      ],
                    ),
                  ),
                  const SizedBox(height: 11),
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: viewModel.selectedDialect,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: ': $sampleInDialect'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Sample Sentence Card

          // Synonyms
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Synonyms",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(thickness: 1),
                const SizedBox(height: 8),
                _buildSynonyms(viewModel, word),

              ],
            ),
          ),

        ],
      ),
    );
  }
}