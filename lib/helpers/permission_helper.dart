import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // Check if device GPS/location service is turned on
  static Future<bool> isDeviceGPSEnabled() async => await Permission.location.serviceStatus.isEnabled;
  static Future<bool> isLocationGranted() async => await Permission.location.status.isGranted;

  static Future<bool> checkAndRequestLocation({bool openSettingsIfDenied = true}) async {
    if (!await isDeviceGPSEnabled()) return false;
    if (await isLocationGranted()) return true;

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

  static Future<bool> isNotificationGranted() async => await Permission.notification.status.isGranted;

  static Future<bool> checkAndRequestNotification({bool openSettingsIfDenied = true}) async {
    if (await isNotificationGranted()) return true;

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

  static Future<bool> isCameraGranted() async => await Permission.camera.status.isGranted;

  static Future<bool> checkAndRequestCamera({bool openSettingsIfDenied = true}) async {
    if (await isCameraGranted()) return true;

    var result = await Permission.camera.request();

    if (result.isGranted) {
      return true;
    } else if (result.isPermanentlyDenied && openSettingsIfDenied) {
      _showDialog("take_photos".tr, "camera".tr);
      return false;
    } else {
      return false;
    }
  }

  static Future<bool> isGalleryGranted() async {
    if (GetPlatform.isAndroid) {
      return await Permission.photos.status.isGranted;

      // if (AndroidSDK >= 33) {
      //   await Permission.photos.status.isGranted;
      // } else {
      //   await Permission.storage.status.isGranted;
      // }
    } else {
      return await Permission.photos.status.isGranted;
    }
  }

  static Future<bool> checkAndRequestGallery({bool openSettingsIfDenied = true}) async {
    if (await isGalleryGranted()) return true;

    Permission permission;

    if (GetPlatform.isAndroid) {
      permission = Permission.photos;

      // if (AndroidSDK >= 33) {
      //   permission = Permission.photos;
      // } else {
      //   permission = Permission.storage;
      // }
    } else {
      permission = Permission.photos;
    }

    var result = await permission.request();

    if (result.isGranted) {
      return true;
    } else if (result.isPermanentlyDenied && openSettingsIfDenied) {
      _showDialog("select_photos".tr, "gallery".tr);
      return false;
    } else {
      return false;
    }
  }

  static Future<void> _showDialog(String action, String permission) async {
    bool? result = await MessageHelper.showConfirmationDialog(
      backgroundColor: Colors.blue,
      icon: Icons.info_rounded,
      message: "msg_need_permission".trParams({"action": action, "permission": permission}),
      title: "need_permission".trParams({"permission": permission}),
      confirmText: "go_now".tr,
    );

    if (result != null && result) await openAppSettings();
  }
}
