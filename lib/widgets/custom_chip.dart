import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class CustomChoiceChip<T> extends StatelessWidget {
  final Color? backgroundColor, textColor;
  final Map<T, String> values;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final WrapAlignment? alignment;

  const CustomChoiceChip({
    super.key,
    this.backgroundColor,
    this.textColor,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
    this.alignment = WrapAlignment.center,
  });

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16.dp,
    alignment: alignment!,
    children: values.keys.map((value) {
      final bool isSelected = selectedValue == value;

      return ChoiceChip(
        selected: isSelected,
        side: BorderSide.none,
        backgroundColor: Colors.grey.withValues(alpha: 0.3),
        checkmarkColor: textColor ?? Theme.of(context).colorScheme.onPrimary,
        selectedColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        onSelected: (_) => onSelected(value),
        label: CustomText(
          values[value]!,
          color: isSelected ? (textColor ?? Theme.of(context).colorScheme.onPrimary) : Colors.black54,
          fontSize: 16.0,
        ),
      );
    }).toList(),
  );
}

class CustomLabelChip extends StatelessWidget {
  final Color? backgroundColor, foregroundColor;
  final double? chipRadius, foregroundSize;
  final IconData? icon;
  final String label;

  const CustomLabelChip({
    super.key,
    this.backgroundColor = Colors.red,
    this.foregroundColor = Colors.white,
    this.chipRadius = kBorderRadiusXS,
    this.foregroundSize = 14.0,
    this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(chipRadius!), color: backgroundColor),
    padding: EdgeInsets.symmetric(horizontal: 8.dp, vertical: 4.dp),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4.dp,
      children: <Widget>[
        if (icon != null) Icon(icon, color: foregroundColor, size: foregroundSize!.sp),
        CustomText(label, color: foregroundColor, fontSize: foregroundSize!),
      ],
    ),
  );
}
