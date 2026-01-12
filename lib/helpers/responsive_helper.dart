import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum DevicePlatform { android, ios, web, unknown }

enum DeviceType { mobile, tablet, desktop }

class ResponsiveHelper {
  static final ResponsiveHelper _instance = ResponsiveHelper._internal();
  factory ResponsiveHelper() => _instance;
  ResponsiveHelper._internal();

  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1200.0;

  late double aspectRatio;
  late double screenHeight, screenWidth;
  late DevicePlatform platform;
  late DeviceType deviceType;
  late Orientation orientation;

  void init(BuildContext context) {
    final mq = MediaQuery.of(context);

    screenHeight = mq.size.height;
    screenWidth = mq.size.width;
    aspectRatio = screenWidth / screenHeight;
    orientation = mq.orientation;

    _detectPlatform();
    _detectDeviceType();
  }

  void _detectPlatform() {
    if (kIsWeb) {
      platform = DevicePlatform.web;
    } else if (Platform.isAndroid) {
      platform = DevicePlatform.android;
    } else if (Platform.isIOS) {
      platform = DevicePlatform.ios;
    } else {
      platform = DevicePlatform.unknown;
    }
  }

  void _detectDeviceType() {
    double deviceWidth = 0.0;

    if (platform == DevicePlatform.android || platform == DevicePlatform.ios) {
      deviceWidth = orientation == Orientation.portrait ? screenWidth : screenHeight;

      if (deviceWidth < mobileBreakpoint) {
        deviceType = DeviceType.mobile;
      } else {
        deviceType = DeviceType.tablet;
      }
    } else {
      deviceWidth = screenWidth;

      if (deviceWidth < mobileBreakpoint) {
        deviceType = DeviceType.mobile;
      } else if (deviceWidth >= mobileBreakpoint && deviceWidth <= tabletBreakpoint) {
        deviceType = DeviceType.tablet;
      } else {
        deviceType = DeviceType.desktop;
      }
    }
  }

  // String getAspectRatioName() {
  //   final ratio = screenWidth > screenHeight ? screenWidth / screenHeight : screenHeight / screenWidth;
  //
  //   if ((ratio - 16 / 9).abs() < 0.01) return "16:9";
  //   if ((ratio - 19.5 / 9).abs() < 0.01) return "19.5:9";
  //   if ((ratio - 4 / 3).abs() < 0.01) return "4:3";
  //
  //   return "H: ${screenHeight.toStringAsFixed(1)}, W: ${screenWidth.toStringAsFixed(1)}, R: ${aspectRatio.toStringAsFixed(1)}";
  // }

  double _textScale() => deviceType == DeviceType.desktop ? 1.3 : 1.0;
  double _sizeScale() => deviceType == DeviceType.desktop ? 2.0 : (deviceType == DeviceType.tablet ? 1.5 : 1.0);

  int quickAccessCount() => deviceType == DeviceType.desktop ? 5 : (deviceType == DeviceType.tablet ? 4 : 3);
  double authSize() => deviceType == DeviceType.desktop ? 300.0 : 200.0;
  double avatarSize() => deviceType == DeviceType.desktop ? 70.0 : 50.0;
  double nearbyHeight() => deviceType == DeviceType.desktop ? 300.0 : 200.0;
  double quickAccessHeight() => deviceType == DeviceType.desktop ? 150.0 : 100.0;
  double voucherHeight() => deviceType == DeviceType.desktop ? 175.0 : 125.0;
  double voucherWidth() => deviceType == DeviceType.desktop ? 400.0 : 300.0;
  double welcomeSize() => deviceType == DeviceType.desktop ? 500.0 : 400.0;
}

extension ResponsiveExtensions on num {
  double get sp => this * ResponsiveHelper()._textScale();
  double get dp => this * ResponsiveHelper()._sizeScale();
}
