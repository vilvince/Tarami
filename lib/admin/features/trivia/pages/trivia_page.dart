import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../layout/admin_scaffold.dart';
import '../../../shared/theme.dart';
import '../viewmodel/trivia_admin_vm.dart';
import '../data/trivia_model.dart';

class TriviaPage extends StatelessWidget {
  const TriviaPage({super.key});

  // Constants for card styling
  static const double desiredCardWidth = 450;
  static const double desiredCardHeight = 200;
  static const double cardSpacing = 16;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TriviaAdminVM>();

    return AdminScaffold(
      title: 'Trivia',
      child: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.errorMessage != null
          ? _buildErrorWidget(context, vm)
      // This is the main layout widget. It correctly handles scrolling.
          : Scrollbar(
            child: CustomScrollView(
                    slivers: [
            // Sliver #1: A non-scrolling "box" for your "Add" button.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => _openAddDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Trivia'),
                    style: FilledButton.styleFrom(
                      backgroundColor: brandGold,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            // Sliver #2: The main, scrollable grid for your trivia items.
            _buildSliverGrid(vm),
                    ],
                  ),
          ),
    );
  }

  /// Builds the error state UI with a retry button.
  Widget _buildErrorWidget(BuildContext context, TriviaAdminVM vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            vm.errorMessage!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => vm.reload(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: FilledButton.styleFrom(
              backgroundColor: brandGold,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the SliverGrid, which is the proper way to have a grid
  /// inside a CustomScrollView. This prevents layout errors.
  Widget _buildSliverGrid(TriviaAdminVM vm) {
    final itemCount = vm.items.length;

    if (itemCount == 0) {
      // If the list is empty, this sliver will fill the remaining screen space.
      return const SliverFillRemaining(
        child: Center(
          child: Text("No trivia found. Add one to get started!"),
        ),
      );
    }

    const childAspectRatio = desiredCardWidth / desiredCardHeight;

    // Use SliverPadding to add padding around the grid itself.
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: cardSpacing),
      sliver: SliverGrid.builder(
        itemCount: itemCount,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          // This delegate makes the grid responsive automatically.
          maxCrossAxisExtent: desiredCardWidth + cardSpacing,
          mainAxisSpacing: cardSpacing,
          crossAxisSpacing: cardSpacing,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (_, i) => _TriviaCard(item: vm.items[i]),
      ),
    );
  }

  /// Opens the dialog to add a new trivia item.
  Future<void> _openAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    final vm = context.read<TriviaAdminVM>();

    try {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: cardNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Trivia', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: 500,
            height: 200,
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              autofocus: true,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: 'Enter trivia text…',
                hintStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter trivia text')),
                    );
                  }
                  return;
                }
                try {
                  await vm.addTrivia(controller.text);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: brandGold,
                foregroundColor: Colors.black,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }
}

/// A card widget to display a single trivia item with edit and delete buttons.
class _TriviaCard extends StatelessWidget {
  final Trivia item;
  const _TriviaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardNavy,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 8),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ✅ Text area with padding so it won’t overlap icons
          Padding(
            padding: const EdgeInsets.only(top: 30.0, right: 40.0, left: 8.0),
            child: Center(
              child: SizedBox(
                height: 120, // adjust the scrollable area height
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Text(
                      item.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),



          // ✅ Edit/Delete icons stay at top-right
          Positioned(
            top: 4,
            right: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () => _openEditDialog(context, item),
                  icon: const Icon(Icons.edit_outlined,
                      color: Colors.lightBlue, size: 18),
                ),
                IconButton(
                  tooltip: 'Delete',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () => _confirmDelete(context, item.id),
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Opens the dialog to edit an existing trivia item.
  Future<void> _openEditDialog(BuildContext context, Trivia item) async {
    final controller = TextEditingController(text: item.text);
    final vm = context.read<TriviaAdminVM>();

    try {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: cardNavy,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit Trivia', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: 500,
            height: 200,
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              autofocus: true,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter trivia text')),
                    );
                  }
                  return;
                }
                try {
                  await vm.updateTrivia(item.id, controller.text);
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: brandGold,
                foregroundColor: Colors.black,
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  /// Opens a confirmation dialog before deleting a trivia item.
  Future<void> _confirmDelete(BuildContext context, String id) async {
    final vm = context.read<TriviaAdminVM>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Trivia', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this trivia?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await vm.deleteTrivia(id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }
}