import 'package:flutter/material.dart';
import 'package:tarami_application/features/user/viewmodel/submission_viewmodel.dart';
import 'package:tarami_application/features/user/view/submission_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/data/models/submission_model.dart';

class SubmissionScreen extends StatefulWidget {
  const SubmissionScreen({super.key});

  @override
  State<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends State<SubmissionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabTitles = ['All', 'Approved', 'Pending', 'Denied', 'Flagged'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to build custom styled tabs
  Widget _buildCustomTab({required String text, required int tabIndex}) {
    bool isSelected = _tabController.index == tabIndex;

    return Tab(
      height: 44,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1E4563) : Color(0xFF1E4563)?.withOpacity(0.4),
          borderRadius: BorderRadius.circular(22.0),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.blueGrey[700]!,
            width: 1,
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmissionTap(Map<String, String> submission) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmissionDetailScreen(submission: submission),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d2334),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 12.0),
              child: IconButton(
                color: Colors.white,
                iconSize: 28,
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.transparent,
                indicatorWeight: 0,
                indicator: const BoxDecoration(),
                dividerColor: Colors.transparent,
                labelPadding: const EdgeInsets.symmetric(horizontal: 6.0),

                tabs: _tabTitles.asMap().entries.map((entry) {
                  return _buildCustomTab(text: entry.value, tabIndex: entry.key);
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),


            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabTitles.map((_) => buildSubmissionList(context)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSubmissionList(BuildContext context) {
    final submissionViewModel = Provider.of<SubmissionViewModel>(context);
    String currentTab = _tabTitles[_tabController.index];
    List<Submission> allActualSubmissions = submissionViewModel.submissions;
    List<Submission> filteredSubmissions;
    if (currentTab == 'All') {
      filteredSubmissions = allActualSubmissions;
    } else {
      filteredSubmissions = allActualSubmissions
          .where((submission) => // 'submission' is now a Submission object
      submission.status.toLowerCase() == currentTab.toLowerCase())
          .toList();
    }
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 25, bottom: 20),
          child: filteredSubmissions.isEmpty
              ? const Center(
            child: Text(
              'No submissions found.',
              style: TextStyle(color: Colors.black54),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filteredSubmissions.length,
            itemBuilder: (context, index) {
              final Submission item = filteredSubmissions[index];
              return GestureDetector(
                onTap: () {
                  Map<String, String> submissionMap = {
                    'word': item.word,
                    'dialect': item.dialect,
                    'date': item.date.toIso8601String().split('T').first, // Format date as string'
                    'status': item.status,
                    'translation': item.translation,
                    'phonetic': item.phonetics,
                    'tagalog': item.tagalog,
                    'definition': item.definition,
                    'partOfSpeech': item.partOfSpeech,
                    'exampleSentence': item.exampleSentence,
                    'synonyms': item.synonyms,
                    // Add any other fields your SubmissionDetailScreen or _onSubmissionTap expects from the map
                    // For example, if you had a 'dialect' field in Submission model:
                    // 'dialect': item.dialect ?? 'N/A',
                  };
                  _onSubmissionTap(submissionMap);
                },


                child: Container(
                  margin: EdgeInsets.only(
                    top: index == 0 ? 0 : 12,
                    bottom: 12,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1E2D),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Word:  ${item.word}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Dialect:  ${item.dialect}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.date.toLocal().toString().split(' ')[0],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white.withOpacity(0.8),
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

}


