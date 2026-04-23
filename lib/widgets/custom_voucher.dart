import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/helpers/formatter_helper.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/voucher_model.dart';
import 'package:ezymember/widgets/custom_image.dart';
import 'package:ezymember/widgets/custom_text.dart';
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
        curvePosition: (isCollectable ? rsp.voucherWidth() : constraints.maxWidth) * 0.3,
        curveRadius: kBorderRadiusS * 2,
        height: isCollectable ? rsp.voucherHeight() : 150.0,
        width: isCollectable ? rsp.voucherWidth() : null,
        shadow: Shadow(color: Colors.grey.withValues(alpha: 0.4), blurRadius: kBlurRadius, offset: Offset(kOffsetX, kOffsetY)),
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
      width: double.infinity,
      padding: EdgeInsets.all(4.dp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          CustomAvatarImage(size: rsp.avatarSize() * (isCollectable ? 1.0 : 1.1), networkImage: voucher.companyLogo, name: voucher.companyName),
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

    return content;
  }

  Widget _buildSecondChild(BuildContext context) {
    final bgColor = !isCollectable && voucher.startDate > DateTime.now().millisecondsSinceEpoch ? Colors.grey.shade200 : Colors.white;
    final dateTitle = isCollectable ? Globalization.collectBy.tr : (isRedeemable ? Globalization.redeemBy.tr : Globalization.validTill.tr);
    final date = isCollectable || isRedeemable ? voucher.endCollectDate : voucher.expiredDate;

    return Container(
      color: bgColor,
      padding: EdgeInsets.all(isCollectable ? 8.dp : 16.dp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            spacing: 8.dp,
            children: <Widget>[
              Expanded(
                child: CustomText(
                  voucher.batchDescription,
                  fontSize: isCollectable ? 14.0 : 18.0,
                  fontWeight: isCollectable ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              if (isCollectable)
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onTapCollect,
                  child: CustomText(Globalization.collect.tr, color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 12.0),
                ),
              if (isRedeemable)
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onTapRedeem,
                  child: CustomText(Globalization.redeem.tr, color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 12.0),
                ),
            ],
          ),
          CustomText("${voucher.discountValue.toStringAsFixed(2)} ${Globalization.off.tr}", fontSize: isCollectable ? 12.0 : 14.0),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 8.dp,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (isRedeemable && voucher.usePointRedeem > 0)
                      CustomText(
                        "${Globalization.redeemWith.tr} ${voucher.usePointRedeem} ${Globalization.points.tr}",
                        fontSize: isCollectable ? 12.0 : 14.0,
                      ),
                    if (!isRedeemable) CustomText("${Globalization.minSpend.tr} ${voucher.minimumSpend}", fontSize: isCollectable ? 12.0 : 14.0),
                    CustomText("$dateTitle ${date.tsToStr}", color: Colors.black54, fontSize: isCollectable ? 11.0 : 14.0),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => Get.toNamed(AppRoutes.termsCondition, arguments: {"voucher": voucher}),
                child: CustomText(
                  Globalization.tnc.tr,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: isCollectable ? 11.0 : 14.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
