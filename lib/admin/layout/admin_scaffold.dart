import 'package:flutter/material.dart';
import 'sidebar.dart';

class AdminScaffold extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget child;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSidebar(),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFEAEAEA))),
                  ),
                  child: Row(
                    children: [
                      Text(title, style: Theme.of(context).appBarTheme.titleTextStyle),
                      const Spacer(),
                      ...actions,
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
