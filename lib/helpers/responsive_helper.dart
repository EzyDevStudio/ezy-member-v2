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

  static double getSpacing(BuildContext context, double value) {
    return value * (isDesktop(context) ? 2.0 : (isTablet(context) ? 1.5 : 1.0));
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
