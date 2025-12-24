import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  final Color? backgroundColor;
  final String label;
  final VoidCallback onTap;

  const CustomFilledButton({super.key, this.backgroundColor, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusS)),
    ),
    onPressed: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(context, 16.0),
        vertical: ResponsiveHelper.getSpacing(context, 8.0),
      ),
      child: CustomText(label, color: Theme.of(context).colorScheme.onPrimary, fontSize: 20.0, fontWeight: FontWeight.w700),
    ),
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
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 8.0)),
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
          SizedBox(height: ResponsiveHelper.getSpacing(context, 8.0)),
          if (isLabelVisible!) CustomText(label, fontSize: 14.0),
          if (isLabelVisible! && content != null) CustomText(content!, fontSize: 14.0),
        ],
      ),
    ),
  );
}
