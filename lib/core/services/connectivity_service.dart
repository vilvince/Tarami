
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Stream to listen for connectivity changes
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  // Check current connectivity status
  Future<bool> isConnected() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // Check if device has actual internet connection
  Future<bool> hasInternetConnection() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      return false;
    }

    // Optional: perform a lightweight internet reachability check
    // (e.g., ping Google DNS)
    // try {
    //   final result = await InternetAddress.lookup('example.com');
    //   return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    // } catch (_) {
    //   return false;
    // }

    return true;
  }
}

