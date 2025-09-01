import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../layout/admin_scaffold.dart';
import '../../../shared/theme.dart';
import '../viewmodel/trivia_admin_vm.dart';
import '../data/trivia_model.dart';

class TriviaPage extends StatelessWidget {
  const TriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TriviaAdminVM>();

    return AdminScaffold(
      title: 'Trivia',
      actions: [
        FilledButton.icon(
          onPressed: () => _openAddDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add New Trivia'),
          style: FilledButton.styleFrom(backgroundColor: brandGold, foregroundColor: Colors.black),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final crossAxisCount = w >= 1200 ? 3 : 2;
          return GridView.builder(
            itemCount: vm.items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 28,
              mainAxisSpacing: 28,
              childAspectRatio: 1.9,
            ),
            itemBuilder: (_, i) => _TriviaCard(item: vm.items[i]),
          );
        },
      ),
    );
  }

  Future<void> _openAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    final vm = context.read<TriviaAdminVM>();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Trivia'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter trivia text…',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                vm.addTrivia(controller.text);
                Navigator.pop(context);
              }
            },
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardNavy,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 8), color: Color(0x14000000))],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.text,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.35,
                  fontSize: 15.5,
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () => _openEditDialog(context, item),
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () => _confirmDelete(context, vm, item.id),
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
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
        title: const Text('Edit Trivia'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                vm.updateTrivia(item.id, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, TriviaAdminVM vm, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Trivia'),
        content: const Text('Are you sure you want to delete this trivia?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) vm.deleteTrivia(id);
  }
}
