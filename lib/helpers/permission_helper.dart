import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // Check if device GPS/location service is turned on
  static Future<bool> isLocationServiceEnabled() async => await Permission.location.serviceStatus.isEnabled;
  // Check if user allowed app to use location
  static Future<bool> isLocationGranted() async => await Permission.location.status.isGranted;

  static Future<bool> checkAndRequestLocation() async {
    if (!await isLocationServiceEnabled()) return false;
    if (await isLocationGranted()) return true;

    // If permission is not granted then request location permission
    return await requestLocationPermission();
  }

  static Future<bool> requestLocationPermission({bool openSettingsIfDenied = true}) async {
    var result = await Permission.location.request();

    if (result.isGranted) {
      return true;
    } else if (result.isPermanentlyDenied && openSettingsIfDenied) {
      await openAppSettings();
      return false;
    } else {
      return false;
    }
  }
}
