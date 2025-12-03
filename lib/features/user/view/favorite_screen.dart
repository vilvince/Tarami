import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/features/user/viewmodel/favorite_viewmodel.dart'; // Adjust import

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    // Load favorite words when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteViewModel>().initialize();
    });
  }

  void _removeFavoriteDialog(BuildContext context, FavoriteViewModel viewModel, int index) {
    final itemToRemove = viewModel.favoriteItems[index];
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
                'Remove "${itemToRemove.word}" from favorites?',
                style: const TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // OK button
                  TextButton(
                    onPressed: () {
                      viewModel.removeFavoriteByIndex(index);
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(25, 0, 30, 0),
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Ok',
                      style: TextStyle(color: Colors.black, fontSize: 17),
                    ),
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

  void _clearAllFavoritesDialog(BuildContext context, FavoriteViewModel viewModel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1E2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Text(
          'Are you sure you want to clear your favorites?',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        actions: [
          TextButton(
            onPressed: () {
              viewModel.clearAllFavorites();
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
    final favoriteViewModel = Provider.of<FavoriteViewModel>(context);

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
                    'Favorites',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Content area with loading states
            Expanded(
              child: _buildContent(favoriteViewModel),
            ),

            // Clear all button - only show if there are favorites
            if (favoriteViewModel.favoriteItems.isNotEmpty && !favoriteViewModel.isLoading)
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
                  onPressed: () => _clearAllFavoritesDialog(context, favoriteViewModel),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    child: Text(
                      'Clear all Favorites',
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

  Widget _buildContent(FavoriteViewModel viewModel) {
    // Loading state
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading favorite words...'),
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
    if (viewModel.favoriteItems.isEmpty) {
      return const Center(
        child: Text(
          'You have no saved favorites.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    // List of favorites
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
      itemCount: viewModel.favoriteItems.length,
      itemBuilder: (context, index) {
        final item = viewModel.favoriteItems[index];
        return ListTile(
          title: Text(item.word),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _removeFavoriteDialog(context, viewModel, index),
          ),
        );
      },
    );
  }
}