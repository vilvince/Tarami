import 'package:flutter/material.dart';


class contribute extends StatefulWidget {
  const contribute({super.key});

  @override
  State<contribute> createState() => _contributeState();
}

class _contributeState extends State<contribute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Contribute Page')),
    );
  }
}
