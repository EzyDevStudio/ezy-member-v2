import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/history_model.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomHistoryListTile extends StatelessWidget {
  final HistoryModel history;

  const CustomHistoryListTile({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.black87;
    String title = "";
    String location = "";
    String value = "";

    if (history.type == HistoryType.credit) {
      title = history.credit!.creditDescription;
      location = [history.credit?.branchName, history.credit?.counterDesc].where((s) => s != null && s.isNotEmpty).join(" - ");
      value = history.credit!.credit.toStringAsFixed(1);
      textColor = history.credit!.credit < 0 ? Colors.red : Colors.green;
    } else if (history.type == HistoryType.point) {
      title = history.point!.pointDescription;
      location = [history.point?.branchName, history.point?.counterDesc].where((s) => s != null && s.isNotEmpty).join(" - ");
      value = history.point!.point.toStringAsFixed(1);
      textColor = history.point!.point < 0 ? Colors.red : Colors.green;
    } else if (history.type == HistoryType.voucher) {
      title = history.voucher!.batchDescription;
      location = [history.voucher?.branchName, history.voucher?.counterDesc].where((s) => s != null && s.isNotEmpty).join(" - ");
      value = history.voucher!.redeemDate == 0 ? "collect".tr : "redeem".tr;
      textColor = history.voucher!.redeemDate == 0 ? Colors.green : Colors.red;
    }

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(context, SizeType.m),
        vertical: ResponsiveHelper.getSpacing(context, SizeType.s),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getSpacing(context, SizeType.xs)),
            child: CustomText(title, fontSize: 16.0),
          ),
          if (location.isNotEmpty) CustomText(location, color: Colors.black54, fontSize: 12.0),
        ],
      ),
      title: CustomText(
        FormatterHelper.timestampToString(history.transactionDate, format: FormatterHelper.formatDateTime),
        color: Colors.black54,
        fontSize: 12.0,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomText(value, color: textColor, fontSize: 14.0),
          if (history.type != HistoryType.voucher)
            CustomText(history.type == HistoryType.point ? "points".tr : "credits".tr, color: Theme.of(context).colorScheme.primary, fontSize: 12.0),
        ],
      ),
    );
  }
}

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
