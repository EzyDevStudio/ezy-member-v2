import 'package:flutter/material.dart';

enum SizeType { xs, s, m, l, xl }

class ResponsiveHelper {
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1200.0;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobileBreakpoint && MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static double getSpacing(BuildContext context, SizeType type) {
    double spacing = 0.0;

    switch (type) {
      case SizeType.xs:
        isDesktop(context) ? spacing = 6.0 : spacing = 4.0;
      case SizeType.s:
        isDesktop(context) ? spacing = 12.0 : spacing = 8.0;
      case SizeType.m:
        isDesktop(context) ? spacing = 24.0 : spacing = 16.0;
      case SizeType.l:
        isDesktop(context) ? spacing = 32.0 : spacing = 24.0;
      case SizeType.xl:
        isDesktop(context) ? spacing = 40.0 : spacing = 32.0;
    }

    return spacing;
  }

  static double getTextScaler(BuildContext context) {
    return isDesktop(context) ? 1.3 : 1.0;
  }

  static double getWelcomeImgSize(BuildContext context) {
    return isDesktop(context) ? 500.0 : 400.0;
  }

  static double getAuthImgSize(BuildContext context) {
    return isDesktop(context) ? 300.0 : 200.0;
  }

  static double getBranchImgSize(BuildContext context) {
    return isDesktop(context) ? 70.0 : 50.0;
  }

  static double getVoucherHeight(BuildContext context) {
    return isDesktop(context) ? 175.0 : 125.0;
  }

  static double getVoucherWidth(BuildContext context) {
    return isDesktop(context) ? 400.0 : 300.0;
  }

  static int getQuickAccessCount(BuildContext context) {
    return isDesktop(context) ? 5 : (isTablet(context) ? 4 : 3);
  }

  static double getNearbyHeight(BuildContext context) {
    return isDesktop(context) ? 300.0 : 200.0;
  }

  static double getPromoAdsHeight(BuildContext context) {
    return isDesktop(context) ? 200.0 : 150.0;
  }
}
