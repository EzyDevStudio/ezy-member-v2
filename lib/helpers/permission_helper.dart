import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // Check if device GPS/location service is turned on
  static Future<bool> isLocationServiceEnabled() async => await Permission.location.serviceStatus.isEnabled;

  static Future<bool> isLocationGranted() async => await Permission.location.status.isGranted;
  static Future<bool> isNotificationGranted() async => await Permission.notification.status.isGranted;

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
      // await openAppSettings();
      return false;
    } else {
      return false;
    }
  }

  static Future<bool> checkAndRequestNotification() async {
    if (await isNotificationGranted()) return true;

    return await requestNotificationPermission();
  }

  static Future<bool> requestNotificationPermission({bool openSettingsIfDenied = true}) async {
    var result = await Permission.notification.request();

    if (result.isGranted) {
      return true;
    } else if (result.isPermanentlyDenied && openSettingsIfDenied) {
      // await openAppSettings();
      return false;
    } else {
      return false;
    }
  }
}
