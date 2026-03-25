import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum DevicePlatform { app, web }

enum DeviceType { mobile, tablet, desktop }

class ResponsiveHelper {
  static final ResponsiveHelper _instance = ResponsiveHelper._internal();
  factory ResponsiveHelper() => _instance;
  ResponsiveHelper._internal();

  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1200.0;

  static const double mobileSmall = 320.0; // Mobile (Portrait): 320px – 480px
  static const double mobileLarge = 480.0; // Mobile (Landscape): 481px – 600px
  static const double tabletSmall = 600.0; // Tablets (Portrait): 601px – 768px
  static const double tabletLarge = 768.0; // Tablets (Landscape): 769px – 1024px
  static const double desktop = 1024.0; // Desktops: 1025px – 1280px

  late double aspectRatio, longestSide, shortestSide;
  late double screenHeight, screenWidth;
  late DevicePlatform platform;
  late DeviceType deviceType;
  late Orientation orientation;

  void init(BuildContext context) {
    final mq = MediaQuery.of(context);

    longestSide = mq.size.longestSide;
    shortestSide = mq.size.shortestSide;
    screenHeight = mq.size.height;
    screenWidth = mq.size.width;
    aspectRatio = screenWidth / screenHeight;
    orientation = mq.orientation;

    _detectPlatform();
    _detectDeviceType();
  }

  bool get _isInitialized {
    try {
      platform;
      deviceType;
      orientation;

      return true;
    } catch (_) {
      return false;
    }
  }

  void _detectPlatform() {
    if (kIsWeb) {
      platform = DevicePlatform.web;
    } else if (Platform.isAndroid || Platform.isIOS) {
      platform = DevicePlatform.app;
    } else {
      platform = DevicePlatform.app;
    }
  }

  void _detectDeviceType() {
    double deviceWidth = 0.0;

    if (platform == DevicePlatform.app) {
      if (shortestSide < mobileLarge) {
        deviceType = DeviceType.mobile;
      } else if (shortestSide >= mobileLarge && shortestSide < tabletLarge) {
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

  // Check platform
  bool isAppView() => _isInitialized && platform == DevicePlatform.app;
  bool isWebView() => _isInitialized && platform == DevicePlatform.web;
  // Check if what device type
  bool isMobile() => _isInitialized && deviceType == DeviceType.mobile;
  bool isTablet() => _isInitialized && deviceType == DeviceType.tablet;
  bool isDesktop() => _isInitialized && deviceType == DeviceType.desktop;
  // Check orientation
  bool isLandscape() => _isInitialized && orientation == Orientation.landscape;
  bool isPortrait() => _isInitialized && orientation == Orientation.portrait;
  // Check App with orientation
  bool isMobileLandscape() => isAppView() && isMobile() && isLandscape();
  bool isMobilePortrait() => isAppView() && isMobile() && isPortrait();
  bool isTabletLandscape() => isAppView() && isTablet() && isLandscape();
  bool isTabletPortrait() => isAppView() && isTablet() && isPortrait();

  double _textScale() => 1.0;
  double _sizeScale() => 1.0;

  int quickCount() => isDesktop() ? 5 : (isTablet() ? 4 : 3);
  double authSize() => isDesktop() ? 300.0 : 200.0;
  double avatarSize() => isDesktop() ? 70.0 : 50.0;
  double nearbyHeight() => isDesktop() ? 300.0 : 200.0;
  double quickHeight() => 100.0;
  double timelineHeight() => isDesktop() ? 400.0 : 300.0;
  double voucherHeight() => isDesktop() ? 125.0 : 125.0;
  double voucherWidth() => isDesktop() ? 400.0 : 300.0;
  double welcomeSize() => isDesktop() ? 500.0 : 400.0;
}

extension ResponsiveExtensions on num {
  double get sp => this * ResponsiveHelper()._textScale();
  double get dp => this * ResponsiveHelper()._sizeScale();
}

ResponsiveHelper get rsp => ResponsiveHelper();

bool get isAppView => rsp.isAppView();
bool get isWebView => rsp.isWebView();

bool get isMobile => rsp.isMobile();
bool get isTablet => rsp.isTablet();
bool get isDesktop => rsp.isDesktop();

bool get isLandscape => rsp.isLandscape();
bool get isPortrait => rsp.isPortrait();

bool get isMobileLandscape => rsp.isMobileLandscape();
bool get isMobilePortrait => rsp.isMobilePortrait();
bool get isTabletLandscape => rsp.isTabletLandscape();
bool get isTabletPortrait => rsp.isTabletPortrait();
