import 'package:flutter/material.dart';
import 'package:tarami_application/features/user/view/about_screen.dart';
import 'package:tarami_application/features/user/view/favorite_screen.dart';
import 'package:tarami_application/features/user/view/quiz_question_screen.dart';
import 'package:tarami_application/features/user/view/profile_screen.dart';
import 'package:tarami_application/features/user/view/quiz_start_screen.dart';
import 'package:tarami_application/features/user/view/recent_screen.dart';
import 'package:tarami_application/features/user/view/submission_screen.dart';
import 'package:tarami_application/features/user/view/faqs_screen.dart';
import 'package:tarami_application/features/auth/view/login.dart';

class UserTabScreen extends StatefulWidget { // Changed to StatefulWidget
  const UserTabScreen({super.key});

  @override
  // Correctly typed State object
  State<UserTabScreen> createState() => _UserTabScreenState();
}


class _UserTabScreenState extends State<UserTabScreen> { // State class
  // --- START OF LOGOUT LOGIC ---
  Future<void> _performLogout() async {
    // 1. Add your actual logout logic here:
    //    - Clear any stored user tokens (e.g., from SharedPreferences, secure storage).
    //    - Reset any user-specific state in your ViewModels or services.
    //    - Example:
    //      final prefs = await SharedPreferences.getInstance();
    //      await prefs.remove('userToken');
    //      Provider.of<AuthViewModel>(context, listen: false).clearUserData(); // If you have an AuthViewModel

    print('User logged out. Add actual token/session clearing logic here.');

    // 2. Navigate to the LoginScreen and remove all previous routes.
    //    This prevents the user from pressing 'back' to return to the UserTabScreen.
    if (mounted) { // Check if the widget is still in the tree
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()), // Navigate to LoginScreen
            (Route<dynamic> route) => false, // This predicate removes all routes
      );
    }
  }
  // --

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top user header
          Container(
            color: const Color(0xFF0d2334),
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); // Right to left
                      const end = Offset.zero;
                      const curve = Curves.ease;

                      final tween =
                      Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Hi, user!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text('user@gmail.com',
                            style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // User options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _userItem( // Changed to call method within the State class
                    icon: Icons.article_outlined,
                    label: 'View my submission',
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const SubmissionScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0); // Right to left
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            final tween =
                            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                ),
                _userItem(
                    icon: Icons.help_outline,
                    label: 'Frequently Asked Questions',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const FaqsScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0); // Right to left
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          final tween =
                          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
                _userItem(
                    icon: Icons.favorite_border,
                    label: 'Favorite',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const FavoriteScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0); // Right to left
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          final tween =
                          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
                _userItem(
                    icon: Icons.history,
                    label: 'Recent',
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const RecentScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0); // Right to left
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          final tween =
                          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
                _userItem(
                    icon: Icons.sports_esports,
                    label: 'Game',
                  onTap: (){
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const QuizStartScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0); // Right to left
                          const end = Offset.zero;
                          const curve = Curves.ease;

                          final tween =
                          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
                _userItem(
                    icon: Icons.groups,
                    label: 'About Us',
                    onTap: (){
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const AboutScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0); // Right to left
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            final tween =
                            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                ),
                const SizedBox(height: 100),

                // Log out button
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Log Out',
                        style: TextStyle(color: Colors.red)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.red),
                    onTap: () {
                      // TODO: Add your logout logic
                      _performLogout();
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method moved into the State class
  Widget _userItem(
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Icon(icon, color: Colors.black),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}