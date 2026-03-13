import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  final bool isLarge;
  final Color? backgroundColor;
  final IconData? icon;
  final String label;
  final VoidCallback onTap;

  const CustomFilledButton({super.key, this.isLarge = true, this.backgroundColor, this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: isLarge ? double.infinity : null,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusS)),
      ),
      onPressed: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 8.dp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 8.dp,
          children: <Widget>[
            if (icon != null) Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 24.0),
            CustomText(label, color: Theme.of(context).colorScheme.onPrimary, fontSize: 16.0, fontWeight: FontWeight.bold),
          ],
        ),
      ),
    ),
  );
}

class CustomIconButton extends StatelessWidget {
  final String assetName;
  final VoidCallback? onPressed;

  const CustomIconButton({super.key, required this.assetName, this.onPressed});

  @override
  Widget build(BuildContext context) => ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: EdgeInsets.all(16.dp), shape: const CircleBorder()),
    onPressed: onPressed,
    child: Image.asset(assetName, fit: BoxFit.contain, height: 40.0, width: 40.0),
  );
}

class CustomImageTextButton extends StatelessWidget {
  final bool? isCountVisible, isLabelVisible;
  final int? count;
  final String assetName, label;
  final String? content;
  final VoidCallback? onTap;

  const CustomImageTextButton({
    super.key,
    this.isCountVisible = false,
    this.isLabelVisible = true,
    this.count = 0,
    required this.assetName,
    required this.label,
    this.content,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusS)),
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Badge.count(
                isLabelVisible: isCountVisible!,
                backgroundColor: Theme.of(context).colorScheme.error,
                textColor: Theme.of(context).colorScheme.onError,
                count: count!,
                child: Image.asset(assetName, scale: kSquareRatio),
              ),
            ),
          ),
          SizedBox(height: 8.0),
          if (isLabelVisible!) CustomText(label, fontSize: 14.0),
          if (isLabelVisible! && content != null) CustomText(content!, fontSize: 14.0),
        ],
      ),
    ),
  );
}
