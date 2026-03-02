import 'package:ezymember/constants/enum.dart';
import 'package:ezymember/helpers/formatter_helper.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/history_model.dart';
import 'package:ezymember/widgets/custom_text.dart';
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
      location = [history.credit?.branchName, history.credit?.counterName].where((s) => s != null && s.isNotEmpty).join(" - ");
      value = history.credit!.credit.toStringAsFixed(1);
      textColor = history.credit!.credit < 0 ? Colors.red : Colors.green;
    } else if (history.type == HistoryType.point) {
      title = history.point!.pointDescription;
      location = [history.point?.branchName, history.point?.counterName].where((s) => s != null && s.isNotEmpty).join(" - ");
      value = history.point!.point.toStringAsFixed(1);
      textColor = history.point!.point < 0 ? Colors.red : Colors.green;
    } else if (history.type == HistoryType.voucher) {
      title = history.voucher!.batchDescription;
      location = history.voucher!.redeemDate == history.transactionDate
          ? history.voucher != null
                ? history.voucher!.branchName
                : ""
          : "";
      value = history.voucher!.redeemDate == 0
          ? Globalization.collect.tr
          : (history.voucher!.redeemDate == history.transactionDate ? Globalization.redeem.tr : Globalization.collect.tr);
      textColor = history.voucher!.redeemDate == 0
          ? Colors.green
          : (history.voucher!.redeemDate == history.transactionDate ? Colors.red : Colors.green);
    }

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 8.dp),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.dp),
            child: CustomText(title, fontSize: 16.0),
          ),
          if (location.isNotEmpty) CustomText(location, color: Colors.black54, fontSize: 12.0),
        ],
      ),
      title: CustomText(history.transactionDate.tsToStrDateTime, color: Colors.black54, fontSize: 12.0),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomText(value, color: textColor, fontSize: 14.0),
          if (history.type != HistoryType.voucher)
            CustomText(
              history.type == HistoryType.point ? Globalization.points.tr : Globalization.credits.tr,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 11.0,
            ),
        ],
      ),
    );
  }
}

class CustomInfoListTile extends StatelessWidget {
  final IconData? icon, trailing;
  final String title;
  final String? subtitle;
  final Widget? subWidget;
  final VoidCallback? onTap, onTapCopy;

  const CustomInfoListTile({super.key, this.icon, this.trailing, required this.title, this.subtitle, this.subWidget, this.onTap, this.onTapCopy});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: icon != null ? Icon(icon, size: 24.sp) : null,
    subtitle: subtitle != null ? CustomText(subtitle!, fontSize: 14.0, maxLines: null) : subWidget,
    title: CustomText(title, color: Theme.of(context).colorScheme.primary, fontSize: 16.0, fontWeight: FontWeight.bold, maxLines: null),
    trailing: trailing != null
        ? GestureDetector(
            onTap: onTapCopy,
            child: Icon(trailing, size: 24.sp),
          )
        : null,
    onTap: onTap,
  );
}
