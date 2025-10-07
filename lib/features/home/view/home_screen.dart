import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/features/home/viewmodel/home_viewmodel.dart';
import 'package:tarami_application/features/dictionary/viewmodel/dictionary_view_model.dart';
import 'package:tarami_application/features/dictionary/view/dictionary_screen.dart';
import 'package:tarami_application/widgets/main_scaffold.dart';
import 'dart:async';


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

class _HomeScreenContentState extends State<HomeScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dictVm = Provider.of<DictionaryViewModel>(context);
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // ✅ prevents auto screen resize
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // ✅ Logo position changes with keyboard
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

            // ✅ Search bar + results move up with keyboard
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

                  // ✅ Search bar
                  Container(
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
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
                                setState(() => _isSearching = false ); // rebuild after debounce delay
                              });
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
                                  : const Icon(Icons.mic,
                                  color: Colors.grey, size: 25),
                            ),
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ Search results (fixed height, scrolls inside only)
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
  // ✅ Move this INSIDE the class
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
