import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityUtils {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has active internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      // Check if we have any connection (mobile, wifi, ethernet, etc.)
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }

      // connectivityResult is a List<ConnectivityResult>
      // If it's not empty and doesn't contain none, we have some form of connectivity
      return connectivityResult.isNotEmpty;
    } catch (e) {
      print('Error checking connectivity: $e');
      // If we can't check, assume no connection to be safe
      return false;
    }
  }

  /// Get readable connection status message
  static Future<String> getConnectionStatusMessage() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return 'No internet connection';
      } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
        return 'Connected via mobile data';
      } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
        return 'Connected via WiFi';
      } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
        return 'Connected via Ethernet';
      } else {
        return 'Connected';
      }
    } catch (e) {
      return 'Unable to determine connection status';
    }
  }

  /// Stream to listen to connectivity changes
  static Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged;
  }
}
