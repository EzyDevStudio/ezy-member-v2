import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, 16.0), vertical: ResponsiveHelper.getSpacing(context, 8.0)),
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

class CustomSegmentedButton extends StatefulWidget {
  final Function(ScanType) onSelectionChanged;

  const CustomSegmentedButton({super.key, required this.onSelectionChanged});

  @override
  State<CustomSegmentedButton> createState() => _CustomSegmentedButtonState();
}

class _CustomSegmentedButtonState extends State<CustomSegmentedButton> {
  late ScanType _scan;

  double borderRadius = 50.0;

  @override
  void initState() {
    super.initState();

    _scan = ScanType.barcode;
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius), color: Colors.white.withValues(alpha: 0.25)),
      margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 4.0)),
      child: Row(
        children: <Widget>[_buildSegmentedButton(context, ScanType.barcode, "earn".tr), _buildSegmentedButton(context, ScanType.qrCode, "redeem".tr)],
      ),
    ),
  );

  Widget _buildSegmentedButton(BuildContext context, ScanType type, String label) => Expanded(
    child: GestureDetector(
      onTap: () {
        setState(() => _scan = type);
        widget.onSelectionChanged(_scan);
      },
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius), color: _scan == type ? Colors.white : Colors.transparent),
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
        child: CustomText(
          label,
          color: _scan == type ? Theme.of(context).colorScheme.primary : Colors.white,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
