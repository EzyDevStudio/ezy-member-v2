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

class CustomImageTextButton extends StatelessWidget {
  final bool isCountVisible, isLabelVisible;
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
      padding: EdgeInsets.all(8.dp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Badge.count(
                isLabelVisible: isCountVisible,
                backgroundColor: Theme.of(context).colorScheme.error,
                textColor: Theme.of(context).colorScheme.onError,
                count: count!,
                child: Image.asset(assetName, scale: kSquareRatio),
              ),
            ),
          ),
          SizedBox(height: 8.dp),
          if (isLabelVisible) CustomText(label, fontSize: 14.0),
          if (isLabelVisible && content != null) CustomText(content!, fontSize: 14.0),
        ],
      ),
    ),
  );
}

class CustomImageButton extends StatelessWidget {
  final IconData? icon;
  final String image, label;
  final VoidCallback? onTap;

  const CustomImageButton({super.key, this.icon, required this.label, this.image = "", this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        color: Colors.white,
        boxShadow: <BoxShadow>[BoxShadow(color: Color(0x0D000000), blurRadius: 10.0, offset: Offset(0.0, 0.4))],
      ),
      height: rsp.imageSettingHeight(),
      width: rsp.imageSettingHeight(),
      padding: EdgeInsets.all(16.dp),
      child: Column(
        spacing: 8.dp,
        children: <Widget>[
          icon != null ? Icon(icon, color: Colors.black87, size: kSettingImage) : Image.asset(image, height: kSettingImage, scale: kSquareRatio),
          CustomText(label, fontSize: 16.0, maxLines: 2, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class CustomMenuButton extends StatelessWidget {
  final String assetName, label;
  final VoidCallback onTap;

  const CustomMenuButton({super.key, required this.assetName, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusS)),
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 5.0,
      children: <Widget>[
        Expanded(child: Image.asset(assetName, scale: kSquareRatio)),
        CustomText(label, fontSize: 12.0),
      ],
    ),
  );
}

class CustomToggleButton extends StatelessWidget {
  final bool isToggled;
  final String assetName, label;
  final VoidCallback onTap;

  const CustomToggleButton({super.key, this.isToggled = false, required this.assetName, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusS)),
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 5.0,
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: isToggled ? Colors.green : Colors.grey.withValues(alpha: 0.3), width: 2.0),
                shape: BoxShape.circle,
              ),
              height: 70.0,
              width: 70.0,
              padding: EdgeInsets.all(10.dp),
              child: Image.asset(assetName, scale: kSquareRatio),
            ),
            if (isToggled)
              Positioned(
                right: 0.0,
                top: 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  padding: EdgeInsets.all(2.dp),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 14.0),
                ),
              ),
          ],
        ),
        CustomText(label, fontSize: 12.0, maxLines: 2, textAlign: TextAlign.center),
      ],
    ),
  );
}
