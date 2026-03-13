import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class CustomLoading extends StatelessWidget {
  final String label;

  const CustomLoading({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16.dp,
      children: <Widget>[
        Image.asset("assets/images/launcher.png", height: 100.0),
        CustomText(label, color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold, maxLines: null),
      ],
    ),
  );
}
