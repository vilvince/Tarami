import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../layout/admin_scaffold.dart';
import '../../../shared/theme.dart';
import '../viewmodel/trivia_admin_vm.dart';
import '../data/trivia_model.dart';

class TriviaPage extends StatelessWidget {
  const TriviaPage({super.key});

  static const double desiredCardWidth = 450;
  static const double desiredCardHeight = 200;
  static const double cardSpacing = 16;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TriviaAdminVM>();
    final itemCount = vm.items.length;

    return AdminScaffold(
      title: 'Trivia',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
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
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = (itemCount / 2).ceil();
              final count = crossAxisCount > 0 ? crossAxisCount : 1;
              final childAspectRatio = desiredCardWidth / desiredCardHeight;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: count * desiredCardWidth +
                        (count - 1) * cardSpacing,
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(cardSpacing),
                    itemCount: itemCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count,
                      crossAxisSpacing: cardSpacing,
                      mainAxisSpacing: cardSpacing,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (_, i) => _TriviaCard(item: vm.items[i]),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    final vm = context.read<TriviaAdminVM>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Add New Trivia',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 500,
          height: 200,
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              hintText: 'Enter trivia text…',
              hintStyle: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                vm.addTrivia(controller.text);
                Navigator.pop(context);
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
  }
}

class _TriviaCard extends StatelessWidget {
  final Trivia item;
  const _TriviaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<TriviaAdminVM>();

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
              child: SingleChildScrollView(
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
                  onPressed: () => _confirmDelete(context, vm, item.id),
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

  Future<void> _openEditDialog(BuildContext context, Trivia item) async {
    final controller = TextEditingController(text: item.text);
    final vm = context.read<TriviaAdminVM>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Edit Trivia',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 500,
          height: 200,
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                vm.updateTrivia(item.id, controller.text);
                Navigator.pop(context);
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
  }

  Future<void> _confirmDelete(
      BuildContext context, TriviaAdminVM vm, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Trivia',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this trivia?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) vm.deleteTrivia(id);
  }
}
