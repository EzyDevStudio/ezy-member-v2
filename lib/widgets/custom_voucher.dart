import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/company_model.dart';
import 'package:ezy_member_v2/models/voucher_model.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomVoucher extends StatelessWidget {
  final VoidCallback? onTap, onTapCollect;
  final VoucherModel voucher;

  const CustomVoucher({super.key, this.onTap, this.onTapCollect, required this.voucher});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: CouponCard(
      curveAxis: Axis.vertical,
      clockwise: false,
      borderRadius: kBorderRadiusS,
      curvePosition: ResponsiveHelper.getVoucherCurvePosition(context),
      curveRadius: kBorderRadiusS * 2,
      height: ResponsiveHelper.getVoucherHeight(context),
      width: ResponsiveHelper.getVoucherWidth(context),
      shadow: const Shadow(color: Colors.black12, blurRadius: kBlurRadius, offset: Offset(kOffsetX, kOffsetY)),
      firstChild: Badge(
        alignment: Alignment.topLeft,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        padding: EdgeInsets.only(left: 10.0, right: 6.0),
        offset: Offset(-6.0, ResponsiveHelper.getSpacing(context, SizeType.s)),
        label: CustomText("x${voucher.quantity}", color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 11.0),
        child: Container(
          color: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.xs)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ClipOval(
                child: Image.network(
                  voucher.companyLogo,
                  fit: BoxFit.cover,
                  height: ResponsiveHelper.getVoucherImgSize(context),
                  width: ResponsiveHelper.getVoucherImgSize(context),
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                    return Center(
                      child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: ResponsiveHelper.getVoucherImgSize(context)),
                    );
                  },
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              CustomText(
                voucher.companyName,
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      secondChild: Container(
        color: Colors.white,
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.s)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: CustomText(voucher.batchDescription, fontSize: 14.0)),
                InkWell(
                  onTap: onTapCollect,
                  child: CustomText(AppStrings.collect, color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 12.0),
                ),
              ],
            ),
            CustomText("${voucher.discountValue} ${AppStrings.off}", fontSize: 12.0),
            const Spacer(),
            CustomText("${AppStrings.minSpend} ${voucher.minimumSpend}", fontSize: 12.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: CustomText(
                    "${AppStrings.validTill} ${FormatterHelper.timestampToString(voucher.expiredDate)}",
                    color: Colors.black54,
                    fontSize: 11.0,
                  ),
                ),
                InkWell(
                  onTap: () => Get.toNamed(AppRoutes.termsCondition, arguments: {"voucher": voucher}),
                  child: CustomText(AppStrings.tnc, color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 11.0),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class CustomCompanyVoucher extends StatelessWidget {
  final VoucherModel voucher;
  final VoidCallback? onTap;

  const CustomCompanyVoucher({super.key, required this.voucher, this.onTap});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => InkWell(
      onTap: onTap,
      child: CouponCard(
        curveAxis: Axis.vertical,
        clockwise: false,
        borderRadius: kBorderRadiusS,
        curvePosition: constraints.maxWidth * 0.3,
        curveRadius: kBorderRadiusS * 2,
        shadow: const Shadow(color: Colors.black12, blurRadius: kBlurRadius, offset: Offset(kOffsetX, kOffsetY)),
        firstChild: Container(
          color: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.s)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              CustomText(
                "${voucher.discountValue} ${AppStrings.off}",
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                maxLines: 2,
              ),
              CustomText(
                "${AppStrings.minSpend} ${voucher.minimumSpend.toStringAsFixed(1)}",
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16.0,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        secondChild: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CustomText(voucher.batchDescription, fontSize: 20.0, fontWeight: FontWeight.bold, maxLines: 2),
              Row(
                spacing: ResponsiveHelper.getSpacing(context, SizeType.s),
                children: <Widget>[
                  Expanded(
                    child: CustomText(
                      "${AppStrings.validTill} ${FormatterHelper.timestampToString(voucher.expiredDate)}",
                      color: Colors.black54,
                      fontSize: 16.0,
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.toNamed(AppRoutes.termsCondition, arguments: {"voucher": voucher}),
                    child: CustomText(AppStrings.tnc, color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 16.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class CustomCompaniesVoucher extends StatelessWidget {
  final VoucherModel voucher;
  final VoidCallback? onTap;

  const CustomCompaniesVoucher({super.key, required this.voucher, this.onTap});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => InkWell(
      onTap: onTap,
      child: CouponCard(
        curveAxis: Axis.vertical,
        clockwise: false,
        borderRadius: kBorderRadiusS,
        curvePosition: constraints.maxWidth * 0.3,
        curveRadius: kBorderRadiusS * 2,
        shadow: const Shadow(color: Colors.black12, blurRadius: kBlurRadius, offset: Offset(kOffsetX, kOffsetY)),
        firstChild: Container(
          color: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.s)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ClipOval(
                child: Image.network(
                  voucher.companyLogo,
                  fit: BoxFit.cover,
                  height: ResponsiveHelper.getVoucherImgSize(context),
                  width: ResponsiveHelper.getVoucherImgSize(context),
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                    return Center(
                      child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: ResponsiveHelper.getVoucherImgSize(context)),
                    );
                  },
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              CustomText(
                voucher.companyName,
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 14.0,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        secondChild: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CustomText(voucher.batchDescription, fontSize: 18.0, fontWeight: FontWeight.bold),
              CustomText("${voucher.discountValue} ${AppStrings.off}", fontSize: 14.0),
              const Spacer(),
              CustomText("${AppStrings.minSpend} ${voucher.minimumSpend}", fontSize: 14.0),
              Row(
                spacing: ResponsiveHelper.getSpacing(context, SizeType.s),
                children: <Widget>[
                  Expanded(
                    child: CustomText(
                      "${AppStrings.validTill} ${FormatterHelper.timestampToString(voucher.expiredDate)}",
                      color: Colors.black54,
                      fontSize: 14.0,
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.toNamed(AppRoutes.termsCondition, arguments: {"voucher": voucher}),
                    child: CustomText(AppStrings.tnc, color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 14.0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
