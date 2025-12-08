import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class CustomInfoListTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? subWidget;
  final VoidCallback? onTap;

  const CustomInfoListTile({super.key, this.icon, required this.title, this.subtitle, this.subWidget, this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    child: ListTile(
      leading: icon != null ? Icon(icon, size: ResponsiveHelper.getTextScaler(context) * 24.0) : null,
      subtitle: subtitle != null ? CustomText(subtitle!, fontSize: 14.0, maxLines: null) : subWidget,
      title: CustomText(title, color: Theme.of(context).colorScheme.primary, fontSize: 16.0, fontWeight: FontWeight.bold, maxLines: null),
      onTap: onTap,
    ),
  );
}
