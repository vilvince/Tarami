// screens/submission_screen.dart
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
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to build custom styled tabs with counts
  Widget _buildCustomTab({required String text, required int tabIndex, required int count}) {
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmissionTap(Submission submission) {
    Map<String, String> submissionMap = {
      'word': submission.word,
      'dialect': submission.dialect,
      'date': submission.date.toIso8601String().split('T').first,
      'status': submission.status,
      'translation': submission.translation,
      'phonetic': submission.phonetics,
      'tagalog': submission.tagalog,
      'definition': submission.definition,
      'partOfSpeech': submission.partOfSpeech,
      'exampleSentence': submission.exampleSentence,
      'synonyms': submission.synonyms,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmissionDetailScreen(submission: submissionMap),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubmissionViewModel(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0d2334),
        body: SafeArea(
          child: Consumer<SubmissionViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0),
                    child: Row(
                      children: [
                        IconButton(
                          color: Colors.white,
                          iconSize: 28,
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Show loading indicator while data is loading
                  if (viewModel.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),

                  // Show error if there's an error
                  if (viewModel.error != null)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Column(
                        children: [
                          Text(
                            viewModel.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: viewModel.refreshSubmissions,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),

                  // Tab bar (only show if not loading)
                  if (!viewModel.isLoading)
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
                          final count = viewModel.getCountByStatus(entry.value);
                          return _buildCustomTab(
                            text: entry.value,
                            tabIndex: entry.key,
                            count: count,
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Content area
                  if (!viewModel.isLoading)
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: _tabTitles.map((status) => buildSubmissionList(context, status)).toList(),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildSubmissionList(BuildContext context, String status) {
    final submissionViewModel = Provider.of<SubmissionViewModel>(context);
    List<Submission> filteredSubmissions = submissionViewModel.getSubmissionsByStatus(status);

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
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  status == 'All' ? 'No submissions yet' : 'No ${status.toLowerCase()} submissions',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your contributions will appear here',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
              : RefreshIndicator(
            onRefresh: submissionViewModel.refreshSubmissions,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredSubmissions.length,
              itemBuilder: (context, index) {
                final Submission item = filteredSubmissions[index];
                return GestureDetector(
                  onTap: () => _onSubmissionTap(item),
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
                                'Word: ${item.word}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dialect: ${item.dialect}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(item.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item.status,
                                  style: TextStyle(
                                    color: _getStatusColor(item.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
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
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'denied':
        return Colors.red;
      case 'flagged':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}