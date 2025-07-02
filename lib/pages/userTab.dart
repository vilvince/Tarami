import 'package:flutter/material.dart';


class userTab extends StatefulWidget {
  const userTab({super.key});

  @override
  State<userTab> createState() => _userTabState();
}

class _userTabState extends State<userTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('User  Page')),
    );
  }
}
