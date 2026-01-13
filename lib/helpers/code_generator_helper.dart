import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_bar_code/code/code.dart';

class CodeGeneratorHelper {
  const CodeGeneratorHelper._();

  static Widget barcode(String data, {EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 32.0)}) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.scan),
        child: Padding(
          padding: padding,
          child: AspectRatio(
            aspectRatio: 4 / 1,
            child: Code(drawText: false, codeType: CodeType.code128(), backgroundColor: Colors.white, data: data),
          ),
        ),
      ),
    ),
  );
}
