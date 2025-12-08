import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum DialogType { success, warning, alert, information, loading }

class MessageHelper {
  static void show(String message, {Color? backgroundColor, Color? foregroundColor, Duration duration = const Duration(seconds: 5), IconData? icon}) {
    if (Get.isSnackbarOpen) Get.back();

    Get.snackbar(
      "",
      "",
      shouldIconPulse: false,
      backgroundColor: backgroundColor ?? Get.theme.colorScheme.primary,
      borderRadius: kBorderRadiusS,
      animationDuration: const Duration(milliseconds: 300),
      duration: duration,
      margin: EdgeInsets.all(ResponsiveHelper.getSpacing(Get.context!, SizeType.m)),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(Get.context!, SizeType.l),
        vertical: ResponsiveHelper.getSpacing(Get.context!, SizeType.m),
      ),
      snackPosition: SnackPosition.BOTTOM,
      snackStyle: SnackStyle.FLOATING,
      icon: Icon(icon, color: foregroundColor ?? Get.theme.colorScheme.onPrimary, size: 32.0 * ResponsiveHelper.getTextScaler(Get.context!)),
      messageText: CustomText(message, color: foregroundColor ?? Get.theme.colorScheme.onPrimary, fontSize: 14.0, maxLines: null),
      titleText: CustomText(
        AppStrings.appName,
        color: foregroundColor ?? Get.theme.colorScheme.onPrimary,
        fontSize: 12.0,
        fontWeight: FontWeight.bold,
        maxLines: null,
      ),
    );
  }

  static void showDialog({required DialogType type, required String message, required String title, Duration duration = const Duration(seconds: 5)}) {
    if (Get.isDialogOpen ?? false) Get.back();

    Color backgroundColor;
    IconData iconData;

    switch (type) {
      case DialogType.success:
        backgroundColor = Colors.green;
        iconData = Icons.check_circle_rounded;
        break;
      case DialogType.warning:
        backgroundColor = Colors.orange;
        iconData = Icons.warning_rounded;
        break;
      case DialogType.alert:
        backgroundColor = Colors.red;
        iconData = Icons.error_rounded;
        break;
      case DialogType.information:
        backgroundColor = Colors.blue;
        iconData = Icons.info_rounded;
        break;
      case DialogType.loading:
        backgroundColor = Colors.green;
        iconData = Icons.autorenew_rounded;
        break;
    }

    Get.dialog(
      PopScope(
        canPop: type != DialogType.loading,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusM)),
            padding: const EdgeInsets.all(kBorderRadiusM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(kBorderRadiusM)),
                    color: backgroundColor,
                  ),
                  height: kDialogHeight,
                  padding: EdgeInsets.all(type == DialogType.loading ? kBorderRadiusL : kBorderRadiusM),
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: type == DialogType.loading
                        ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 5.0))
                        : Icon(iconData, color: Colors.white),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(kBorderRadiusM)),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(kBorderRadiusM),
                  child: Column(
                    spacing: kBorderRadiusM,
                    children: <Widget>[
                      CustomText(title, fontSize: 24.0, fontWeight: FontWeight.bold, textAlign: TextAlign.center),
                      CustomText(message, fontSize: 18.0, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: type != DialogType.loading,
    );

    if (type != DialogType.loading) {
      Future.delayed(duration, () {
        if (Get.isDialogOpen ?? false) Get.back();
      });
    }
  }
}
