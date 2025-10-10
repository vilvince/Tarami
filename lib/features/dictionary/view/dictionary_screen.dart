import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/dictionary_view_model.dart';
import 'package:tarami_application/features/user/view/favorite_screen.dart';


class Dictionary extends StatefulWidget {
  const Dictionary({super.key});

  @override
  State<Dictionary> createState() => _DictionaryState();
  }


class _DictionaryState extends State<Dictionary> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchLocked = false;


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize dictionary data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DictionaryViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DictionaryViewModel>();

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
          const Icon(Icons.notifications_none, color: Colors.white),
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
                    : const Icon(Icons.mic, color: Colors.grey, size: 25),
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

    return ListView.builder(
      itemCount: viewModel.currentWordList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            viewModel.currentWordList[index],
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tagalog: $tagalog",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                 Text(
                  partOfSpeech,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
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
                      if (viewModel.hasAudio(word)) // 👈 show only if audio exists
                        Transform.translate(
                          offset: const Offset(-35, -15),
                          child: const Icon(
                            Icons.volume_up_outlined,
                            size: 28,
                            color: Colors.black,
                          ),
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