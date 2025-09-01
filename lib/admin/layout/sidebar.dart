import 'package:flutter/material.dart';
import '../shared/theme.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name ?? '';

    Widget navItem({
      required IconData icon,
      required String label,
      required String routeName,
    }) {
      final selected = route == routeName;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (!selected) Navigator.pushReplacementNamed(context, routeName);
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: selected ? brandNavy : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(icon, color: selected ? Colors.white : Colors.black87),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black87,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: 260,
      height: double.infinity,
      color: sidebarBg,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: const [
                Icon(Icons.travel_explore, size: 28, color: brandNavy),
                SizedBox(width: 8),
                Text('TARAMI', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          navItem(icon: Icons.home_outlined, label: 'Home', routeName: '/admin/trivia'),
          navItem(icon: Icons.inbox_outlined, label: 'Inbox', routeName: '/admin/trivia'),
          navItem(icon: Icons.add_circle_outline, label: 'Contribute', routeName: '/admin/trivia'),
          navItem(icon: Icons.fact_check, label: 'Trivia', routeName: '/admin/trivia'),
          navItem(icon: Icons.group_outlined, label: 'User Management', routeName: '/admin/trivia'),
          navItem(icon: Icons.assignment_outlined, label: 'View Submissions', routeName: '/admin/trivia'),
          navItem(icon: Icons.edit_outlined, label: 'Word Management', routeName: '/admin/trivia'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.black.withOpacity(0.1)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: const [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 10),
                Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Admin', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('admin@gmail.com', overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
