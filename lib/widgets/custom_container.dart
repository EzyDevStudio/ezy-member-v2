import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Color color;
  final double? height;
  final EdgeInsets? margin, padding;
  final Widget? child;

  const CustomContainer({super.key, this.color = Colors.white, this.height, this.margin, this.padding, this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10.dp),
      color: color,
      boxShadow: <BoxShadow>[BoxShadow(color: Color(0x0D000000), blurRadius: 10.0, offset: Offset(0.0, 0.4))],
    ),
    height: height,
    margin: margin,
    padding: padding,
    child: child,
  );
}
