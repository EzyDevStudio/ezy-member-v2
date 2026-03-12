import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/widgets/custom_loading.dart';
import 'package:ezymember/widgets/custom_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageHelper {
  static Future<bool?> confirmation({required String message, String? confirmText, String? title}) async {
    if (Get.isDialogOpen ?? false) Get.back();

    return Get.dialog<bool>(
      CustomDialog(type: DialogType.confirmation, content: message, confirmText: confirmText, title: title, onConfirm: () => Get.back(result: true)),
    );
  }

  static void disconnected() {
    if (Get.isDialogOpen ?? false) Get.back();

    Get.dialog(CustomDialog(type: DialogType.disconnected, content: Globalization.msgConnectionOff.tr));
  }

  static void error({required String message, String? title}) {
    if (Get.isDialogOpen ?? false) Get.back();

    Get.dialog(CustomDialog(type: DialogType.error, content: message, title: title));
  }

  static void success({required String message, String? title}) {
    if (Get.isDialogOpen ?? false) Get.back();

    Get.dialog(CustomDialog(type: DialogType.success, content: message, title: title));
  }

  static void warning({required String message, String? title}) {
    if (Get.isDialogOpen ?? false) Get.back();

    Get.dialog(CustomDialog(type: DialogType.warning, content: message, title: title));
  }

  static void loading({required String message}) {
    if (Get.isDialogOpen ?? false) Get.back();

    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          insetPadding: EdgeInsets.all(16.dp),
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          content: CustomLoading(label: Globalization.loading.tr),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
