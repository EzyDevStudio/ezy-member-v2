import 'package:flutter/services.dart';

// App Bar
const double appBarHeight = 300.0;
const double serviceHeight = 80.0;

// Aspect Ratio
const double kBarcodeRatio = 4 / 1;
const double kCardRatio = 1.5857;
const double kSquareRatio = 1.0;

// Border
const double kBorderRadiusXS = 4.0;
const double kBorderRadiusS = 8.0;
const double kBorderRadiusM = 16.0;
const double kBorderRadiusL = 32.0;
const double kBorderRadiusModal = 10.0;
const double kBorderWidth = 2.0;

// Box Shadow
const double kBlurRadius = 6.0;
const double kOffsetX = 4.0;
const double kOffsetY = 4.0;

// Elevation
const double kElevation = 4.0;

// Image
const double kSettingImage = 50.0;

// Input Formatter
final List<TextInputFormatter> kFormatterAddress = [LengthLimitingTextInputFormatter(60)];
final List<TextInputFormatter> kFormatterEmail = [
  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9@._-]")),
  LengthLimitingTextInputFormatter(191),
];
final List<TextInputFormatter> kFormatterName = [
  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Zà-ÿÀ-ß\s'-]")),
  LengthLimitingTextInputFormatter(100),
];
final List<TextInputFormatter> kFormatterPostcode = [
  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z0-9\s-]")),
  LengthLimitingTextInputFormatter(10),
];

// Offset
const double kBackToTop = 150.0;

// Phone
const int kPhoneLength = 15;

// Position
const double kPositionEmpty = 0.0;

// Profile
const double kProfileImgSizeM = 80.0;
const double kProfileImgSizeL = 100.0;
