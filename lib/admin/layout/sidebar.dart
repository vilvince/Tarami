import 'package:flutter/material.dart';
import '../shared/theme.dart'; // keep your theme for brandNavy, sidebarBg

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            if (!selected) {
              Navigator.pushReplacementNamed(context, routeName);
            }
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
                Icon(
                  icon,
                  size: 22,
                  color: selected ? Colors.white : Colors.black87,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black87,
                  ),
                ),
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
          // Logo/Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Center(
              child: SizedBox(
                height: 150, // bigger logo area
                child: Image.asset(
                  'assets/Taramilogo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Expanded nav items (scrollable kung kulang space)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                navItem(icon: Icons.home_outlined, label: 'Home', routeName: '/admin/home'),
                navItem(icon: Icons.mail_outline, label: 'Inbox', routeName: '/admin/inbox'),
                navItem(icon: Icons.add_circle_outline, label: 'Contribute', routeName: '/admin/contribute'),
                navItem(icon: Icons.fact_check_outlined, label: 'Trivia', routeName: '/admin/trivia'),
                navItem(icon: Icons.group_outlined, label: 'User Management', routeName: '/admin/users'),
                navItem(icon: Icons.insert_drive_file_outlined, label: 'View Submissions', routeName: '/admin/submissions'),
                navItem(icon: Icons.edit_outlined, label: 'Word Management', routeName: '/admin/words'),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.black.withOpacity(0.1)),
          ),

          // Logout button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Row(
                children: const [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 10),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // User Info (sticky at the very bottom)
          const ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16),
            leading: CircleAvatar(
              backgroundColor: Colors.black12,
              child: Icon(Icons.person, color: Colors.black87),
            ),
            title: Text(
              'Admin',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              'admin@gmail.com',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
