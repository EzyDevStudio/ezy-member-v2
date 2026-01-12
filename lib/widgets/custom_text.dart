import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    style: TextStyle(color: color ?? Colors.black87, fontSize: fontSize.sp, fontWeight: fontWeight),
  );
}

class CustomReadMore extends StatefulWidget {
  final int maxLines;
  final String text;
  final TextStyle? style;

  const CustomReadMore({super.key, this.maxLines = 2, required this.text, this.style});

  @override
  State<CustomReadMore> createState() => _CustomReadMoreState();
}

class _CustomReadMoreState extends State<CustomReadMore> {
  bool _collapsed = true;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final effectiveStyle = defaultStyle.merge(widget.style);
    final textScaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final fullPainter = TextPainter(
          text: TextSpan(text: widget.text, style: effectiveStyle),
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
          textScaler: textScaler,
        )..layout(maxWidth: maxWidth);

        if (!fullPainter.didExceedMaxLines) return Text(widget.text, style: effectiveStyle);

        final suffix = _collapsed ? " ...${Globalization.more.tr.toLowerCase()}" : " ${Globalization.less.tr.toLowerCase()}";
        final suffixPainter = TextPainter(
          text: TextSpan(text: suffix, style: effectiveStyle),
          textDirection: TextDirection.ltr,
          textScaler: textScaler,
        )..layout(maxWidth: maxWidth);
        final cutOffset = fullPainter.getPositionForOffset(Offset(maxWidth - suffixPainter.width, fullPainter.height));
        final endIndex = fullPainter.getOffsetBefore(cutOffset.offset) ?? 0;
        final displayText = _collapsed ? widget.text.substring(0, endIndex) : widget.text;

        return RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: displayText),
              TextSpan(
                recognizer: TapGestureRecognizer()..onTap = () => setState(() => _collapsed = !_collapsed),
                text: suffix,
                style: effectiveStyle.copyWith(color: Colors.blue),
              ),
            ],
            style: effectiveStyle,
          ),
          textScaler: textScaler,
        );
      },
    );
  }
}
