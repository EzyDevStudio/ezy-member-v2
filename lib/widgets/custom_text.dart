import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String data;
  final Color? color;
  final double fontSize;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  const CustomText(this.data, {super.key, this.color, required this.fontSize, this.fontWeight, this.maxLines = 1, this.textAlign, this.overflow});

  @override
  Widget build(BuildContext context) => Text(
    data,
    maxLines: maxLines,
    textAlign: textAlign,
    overflow: maxLines == null ? null : overflow ?? TextOverflow.ellipsis,
    textScaler: TextScaler.linear(ResponsiveHelper.getTextScaler(context)),
    style: TextStyle(color: color ?? Colors.black87, fontSize: fontSize, fontWeight: fontWeight),
  );
}
