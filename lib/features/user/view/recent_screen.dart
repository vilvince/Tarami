import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/features/user/viewmodel/recent_viewmodel.dart'; // Adjust import

class RecentScreen extends StatefulWidget {
  const RecentScreen({super.key});

  @override
  State<RecentScreen> createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  @override
  void initState() {
    super.initState();
    // Load recent words when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecentViewModel>().initialize();
    });
  }

  void _removeRecentDialog(BuildContext context, RecentViewModel viewModel, int index) {
    final itemToRemove = viewModel.recentItems[index];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1E2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        content: SizedBox(
          width: 350,
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remove "${itemToRemove.word}" from Recent?',
                style: const TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // OK button
                  TextButton(
                    onPressed: () {
                      viewModel.removeRecentByIndex(index);
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(25, 0, 30, 0),
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Ok', style: TextStyle(color: Colors.black, fontSize: 17)),
                  ),
                  const SizedBox(width: 12),
                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.black, fontSize: 15)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearAllRecentsDialog(BuildContext context, RecentViewModel viewModel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1E2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Text(
          'Are you sure you want to clear your recents?',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        actions: [
          TextButton(
            onPressed: () {
              viewModel.clearAllRecents();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(25, 0, 30, 0),
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Ok', style: TextStyle(color: Colors.black, fontSize: 17)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.black, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentViewModel = Provider.of<RecentViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 100),
                  const Text(
                    'Recent',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Content area with loading states
            Expanded(
              child: _buildContent(recentViewModel),
            ),

            // Clear all button - only show if there are recent words
            if (recentViewModel.recentItems.isNotEmpty && !recentViewModel.isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => _clearAllRecentsDialog(context, recentViewModel),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    child: Text(
                      'Clear all Recent',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(RecentViewModel viewModel) {
    // Loading state
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading recent words...'),
          ],
        ),
      );
    }

    // Error state
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

    // Empty state
    if (viewModel.recentItems.isEmpty) {
      return const Center(
        child: Text(
          'You have no recent searches.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    // List of recent words
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
      itemCount: viewModel.recentItems.length,
      itemBuilder: (context, index) {
        final item = viewModel.recentItems[index];
        return ListTile(
          title: Text(item.word),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _removeRecentDialog(context, viewModel, index),
          ),
        );
      },
    );
  }
}