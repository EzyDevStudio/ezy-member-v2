import 'dart:io';

class ConnectionHelper {
  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup("google.com").timeout(Duration(seconds: 3));

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
