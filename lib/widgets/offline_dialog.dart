import 'package:flutter/material.dart';

class OfflineDialog {
  static void show(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.orange),
              SizedBox(width: 10),
              Text('No Internet Connection'),
            ],
          ),
          content: Text(
            'You need an internet connection to $feature. Please check your connection and try again.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  // Alternative: Show a SnackBar instead of dialog
  static void showSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text('No internet. You need connection to $feature.'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}