import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/dictionary_view_model.dart';

class Dictionary extends StatelessWidget {
  const Dictionary({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DictionaryViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1D2B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1D2B),
        elevation: 0,
        leading: viewModel.selectedWord != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => viewModel.selectWord(null),
        )
            : null,
        title: _buildSearchBar(),
        actions: const [
          Icon(Icons.favorite, color: Colors.white),
          SizedBox(width: 12),
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 12),
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                suffixIcon: Icon(Icons.mic, color: Colors.grey, size: 25),
              ),
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
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
          onTap: () => viewModel.selectWord(viewModel.currentWordList[index]),
        );
      },
    );
  }


  Widget _buildDetailView(DictionaryViewModel viewModel) {
    final word = viewModel.selectedWord!;
    final dialectTranslation = viewModel.getDialectTranslation(word) ?? word;
    final pronunciation = "/${word.toLowerCase()}/";
    final tagalog = "Nagulat";
    final definitions = [
      "By surprise; unexpectedly startled or confused.",
      "(Nautical) With the sail pressed backward against the mast by the wind."
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Word Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 55),
            child: Padding(
              padding: const EdgeInsets.only(top: 26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          word,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pronunciation,
                          style: const TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Icon(Icons.favorite_border, size: 28),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Tagalog & POS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
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
                const Text(
                  "Noun",
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
                              pronunciation,
                              style: const TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  ...List.generate(
                    definitions.length,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        "${index + 1}. ${definitions[index]}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
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
                  Text(
                    viewModel.getSampleSentence(word) ??
                        'No sample sentence available.',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Synonyms & Antonyms
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Synonyms & Antonyms",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(thickness: 1),
                const SizedBox(height: 8),

                // Synonyms
                if (viewModel.getSynonyms(word).isNotEmpty) ...[
                  const Text(
                    "Synonyms",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    children: viewModel.getSynonyms(word).map((syn) {
                      return GestureDetector(
                        onTap: () => viewModel.selectWord(syn),
                        child: Text(
                          syn +
                              (viewModel.getSynonyms(word).last != syn
                                  ? ", "
                                  : ""),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.blueAccent,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Antonyms
                if (viewModel.getAntonyms(word).isNotEmpty) ...[
                  const Text(
                    "Antonyms",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    children: viewModel.getAntonyms(word).map((ant) {
                      return GestureDetector(
                        onTap: () => viewModel.selectWord(ant),
                        child: Text(
                          ant +
                              (viewModel.getAntonyms(word).last != ant
                                  ? ", "
                                  : ""),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.blueAccent,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),



        ],
      ),
    );
  }
}