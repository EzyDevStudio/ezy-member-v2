import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class CustomChoiceChip<T> extends StatelessWidget {
  final Map<T, String> values;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final WrapAlignment? alignment;

  const CustomChoiceChip({
    super.key,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
    this.alignment = WrapAlignment.center,
  });

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
    alignment: alignment!,
    children: values.keys.map((value) {
      final bool isSelected = selectedValue == value;

      return ChoiceChip(
        selected: isSelected,
        side: BorderSide.none,
        backgroundColor: Colors.grey.withAlpha((0.5 * 255).round()),
        checkmarkColor: Theme.of(context).colorScheme.onPrimary,
        selectedColor: Theme.of(context).colorScheme.primary,
        onSelected: (_) => onSelected(value),
        label: CustomText(values[value]!, color: isSelected ? Theme.of(context).colorScheme.onPrimary : Colors.black87, fontSize: 16.0),
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
    padding: EdgeInsets.symmetric(
      horizontal: ResponsiveHelper.getSpacing(context, SizeType.s),
      vertical: ResponsiveHelper.getSpacing(context, SizeType.xs),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: ResponsiveHelper.getSpacing(context, SizeType.xs),
      children: <Widget>[
        if (icon != null) Icon(icon, color: foregroundColor, size: foregroundSize! * ResponsiveHelper.getTextScaler(context)),
        CustomText(label, color: foregroundColor, fontSize: foregroundSize!),
      ],
    ),
  );
}
