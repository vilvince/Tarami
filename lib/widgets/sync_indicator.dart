

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class SyncIndicator extends StatefulWidget {
  @override
  _SyncIndicatorState createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator> {
  bool _isOnline = true;
  bool _isSyncing = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _listenToConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  void _listenToConnectivity() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      final wasOffline = !_isOnline;
      final isNowOnline = result != ConnectivityResult.none;

      setState(() {
        _isOnline = isNowOnline;
      });

      // If just came online, trigger sync
      if (wasOffline && isNowOnline) {
        await _performSync();
      }
    });
  }

  Future<void> _performSync() async {
    setState(() {
      _isSyncing = true;
    });

    // Simulate short sync delay
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isSyncing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Synced with server'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isOnline && !_isSyncing) {
      return SizedBox.shrink(); // Don’t show anything when online and not syncing
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _isSyncing ? Colors.blue[100] : Colors.orange[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isSyncing)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          else
            Icon(
              Icons.wifi_off,
              size: 16,
              color: Colors.orange[800],
            ),
          SizedBox(width: 8),
          Text(
            _isSyncing ? 'Syncing...' : 'Offline Mode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _isSyncing ? Colors.blue[800] : Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }
}

