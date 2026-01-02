import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/voucher_model.dart';
import 'package:ezy_member_v2/widgets/custom_image.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum VoucherType { collectable, normal, redeemable }

class CustomVoucher extends StatelessWidget {
  final Color? shadowColor;
  final VoucherModel voucher;
  final VoucherType type;
  final VoidCallback? onTap, onTapCollect, onTapRedeem;

  const CustomVoucher({
    super.key,
    this.shadowColor = Colors.black12,
    required this.voucher,
    required this.type,
    this.onTap,
    this.onTapCollect,
    this.onTapRedeem,
  });

  bool get isCollectable => type == VoucherType.collectable;
  bool get isRedeemable => type == VoucherType.redeemable;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => InkWell(
      onTap: isCollectable ? null : (voucher.startDate > DateTime.now().millisecondsSinceEpoch ? null : onTap),
      child: CouponCard(
        curveAxis: Axis.vertical,
        clockwise: false,
        borderRadius: kBorderRadiusS,
        curvePosition: (isCollectable ? ResponsiveHelper.getVoucherWidth(context) : constraints.maxWidth) * 0.3,
        curveRadius: kBorderRadiusS * 2,
        height: isCollectable ? ResponsiveHelper.getVoucherHeight(context) : kVoucherDefaultHeight,
        width: isCollectable ? ResponsiveHelper.getVoucherWidth(context) : null,
        shadow: Shadow(color: shadowColor!, blurRadius: kBlurRadius, offset: Offset(kOffsetX, kOffsetY)),
        firstChild: _buildFirstChild(context),
        secondChild: _buildSecondChild(context),
      ),
    ),
  );

  Widget _buildFirstChild(BuildContext context) {
    final bgColor = !isCollectable && voucher.startDate > DateTime.now().millisecondsSinceEpoch
        ? Colors.grey.shade500
        : Theme.of(context).colorScheme.primary;

    Widget content = Container(
      color: bgColor,
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 4.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          CustomAvatarImage(size: ResponsiveHelper.getBranchImgSize(context) * (isCollectable ? 1 : 1.1), networkImage: voucher.companyLogo),
          CustomText(
            voucher.companyName,
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: isCollectable ? 10.0 : 14.0,
            fontWeight: isCollectable ? FontWeight.bold : FontWeight.normal,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (type == VoucherType.normal) return content;

    return Badge(
      alignment: Alignment.topLeft,
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      padding: EdgeInsets.only(left: 10.0, right: 6.0),
      offset: Offset(-6.0, ResponsiveHelper.getSpacing(context, 8.0)),
      label: CustomText("x${voucher.quantity}", color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 11.0),
      child: content,
    );
  }

  Widget _buildSecondChild(BuildContext context) {
    final bgColor = !isCollectable && voucher.startDate > DateTime.now().millisecondsSinceEpoch ? Colors.grey.shade200 : Colors.white;

    return Container(
      color: bgColor,
      padding: EdgeInsets.all(isCollectable ? ResponsiveHelper.getSpacing(context, 8.0) : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            spacing: ResponsiveHelper.getSpacing(context, 8.0),
            children: <Widget>[
              Expanded(
                child: CustomText(
                  voucher.batchDescription,
                  fontSize: isCollectable ? 14.0 : 18.0,
                  fontWeight: isCollectable ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              if (isCollectable)
                InkWell(
                  onTap: onTapCollect,
                  child: CustomText("collect".tr, color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 12.0),
                ),
              if (isRedeemable)
                InkWell(
                  onTap: onTapRedeem,
                  child: CustomText("redeem".tr, color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 12.0),
                ),
            ],
          ),
          CustomText("${voucher.discountValue.toStringAsFixed(1)} ${"off".tr}", fontSize: isCollectable ? 12.0 : 14.0),
          const Spacer(),
          if (isRedeemable) CustomText("${"redeem_with".tr} ${voucher.usePointRedeem} ${"points".tr}", fontSize: isCollectable ? 12.0 : 14.0),
          if (!isRedeemable) CustomText("${"min_spend".tr} ${voucher.minimumSpend}", fontSize: isCollectable ? 12.0 : 14.0),
          Row(
            spacing: ResponsiveHelper.getSpacing(context, 8.0),
            children: <Widget>[
              Expanded(
                child: CustomText(
                  "${"valid_till".tr} ${FormatterHelper.timestampToString(voucher.expiredDate)}",
                  color: Colors.black54,
                  fontSize: isCollectable ? 11.0 : 14.0,
                ),
              ),
              InkWell(
                onTap: () => Get.toNamed(AppRoutes.termsCondition, arguments: {"voucher": voucher}),
                child: CustomText("tnc".tr, color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: isCollectable ? 11.0 : 14.0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
