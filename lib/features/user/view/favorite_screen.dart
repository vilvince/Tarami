import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarami_application/features/user/viewmodel/favorite_viewmodel.dart'; // Adjust import

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  void _removeFavoriteDialog(BuildContext context, FavoriteViewModel viewModel, int index) {
    final itemToRemove = viewModel.favoriteItems[index];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1E2D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        content: SizedBox(
          width: 350, // adjust width
          height: 120, // adjust height
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(
                'Remove "${itemToRemove.word}" from favorites?',
                style: TextStyle(color: Colors.white, fontSize: 20),
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
    final favoriteItems = favoriteViewModel.favoriteItems;

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

            // List of favorites
            Expanded(
              // You had an Expanded widget wrapping another Expanded widget for the list part.
              // Only one is needed here.
              child: favoriteItems.isEmpty
                  ? const Center(
                child: Text(
                  'You have no saved favorites.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                itemCount: favoriteItems.length,
                itemBuilder: (context, index) {
                  final item = favoriteItems[index];
                  return ListTile(
                    title: Text(item.word),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      // ---- FIX: Pass favoriteViewModel to the dialog method ----
                      onPressed: () => _removeFavoriteDialog(context, favoriteViewModel, index),
                    ),
                  );
                },
              ),
            ),
            // Clear all button
            if (favoriteItems.isNotEmpty)
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
                    child: Text('Clear all Favorites', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
          ],
        ),
      ),


    );
  }
}
