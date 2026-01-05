import 'dart:async';

import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/advertisement_model.dart';
import 'package:ezy_member_v2/models/branch_model.dart';
import 'package:ezy_member_v2/models/member_model.dart';
import 'package:ezy_member_v2/models/promotion_model.dart';
import 'package:ezy_member_v2/widgets/custom_image.dart';
import 'package:ezy_member_v2/widgets/custom_chip.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomMemberCard extends StatelessWidget {
  final MemberModel member;
  final VoidCallback? onTap;

  const CustomMemberCard({super.key, required this.member, this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: AspectRatio(
      aspectRatio: kCardRatio,
      child: CustomBackgroundImage(
        isBorderRadius: true,
        isShadow: true,
        backgroundImage: member.memberCard.cardImage,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: ResponsiveHelper.getSpacing(context, 16.0),
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomText(member.branch.companyName, color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                    const Spacer(),
                    CustomAvatarImage(size: ResponsiveHelper.getBranchImgSize(context) * 1.2, networkImage: member.branch.companyLogo),
                    const Spacer(),
                    CustomText(
                      member.memberCard.memberCardNumber.replaceAllMapped(RegExp(r".{4}"), (m) => "${m.group(0)} "),
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                    const Spacer(),
                    CustomText(
                      "${member.memberCard.cardDesc} · ${FormatterHelper.timestampToString(member.memberCard.expiredDate)}",
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  CustomLabelChip(
                    backgroundColor: member.isExpired ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    label: member.isExpired ? "expired".tr : "active".tr,
                  ),
                  const Spacer(),
                  CustomText(member.point.toString(), color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                  CustomText("points".tr, color: Colors.white, fontSize: 16.0),
                  const Spacer(),
                  CustomText(member.credit.toStringAsFixed(1), color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                  CustomText("credits".tr, color: Colors.white, fontSize: 16.0),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class CustomNearbyCard extends StatelessWidget {
  final BranchModel branch;
  final RxList<MemberModel> members;

  const CustomNearbyCard({super.key, required this.branch, required this.members});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final member = members.firstWhere((m) => m.companyID == branch.companyID, orElse: () => MemberModel.empty());

      return InkWell(
        child: AspectRatio(
          aspectRatio: kCardRatio,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kBorderRadiusM),
              color: Colors.white,
              boxShadow: <BoxShadow>[
                BoxShadow(color: Theme.of(context).colorScheme.surfaceContainerHigh, blurRadius: kBlurRadius, offset: Offset(kOffsetX, kOffsetY)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(kBorderRadiusM)),
                        child: SizedBox.expand(
                          child: Image.network(
                            branch.companyLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                              return Center(
                                child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: ResponsiveHelper.getPromoAdsHeight(context) / 2),
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
                      ),
                      if (member.isMember) ...[
                        if (member.isExpired)
                          Positioned(
                            right: kPositionLabel,
                            top: kPositionLabel,
                            child: CustomLabelChip(label: "expired".tr),
                          ),
                        Positioned(
                          bottom: kPositionLabel,
                          right: kPositionLabel,
                          child: Row(
                            spacing: ResponsiveHelper.getSpacing(context, 8.0),
                            children: <Widget>[
                              CustomLabelChip(
                                backgroundColor: Colors.white.withValues(alpha: 0.85),
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                label: "${member.point} pts",
                              ),
                              CustomLabelChip(
                                backgroundColor: Colors.white.withValues(alpha: 0.85),
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                icon: Icons.card_giftcard_rounded,
                                label: (member.normalVoucherCount + member.specialVoucherCount).toString(),
                              ),
                              CustomLabelChip(
                                backgroundColor: Colors.white.withValues(alpha: 0.85),
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                label: "${member.credit} cr",
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Positioned(
                          right: kPositionLabel,
                          top: kPositionLabel,
                          child: CustomLabelChip(label: "join_now".tr),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getSpacing(context, 16.0),
                    vertical: ResponsiveHelper.getSpacing(context, 8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: ResponsiveHelper.getSpacing(context, 4.0),
                    children: <Widget>[
                      CustomText(branch.branchName, fontSize: 16.0, fontWeight: FontWeight.w700),
                      CustomText(branch.fullAddress, fontSize: 14.0),
                      CustomText(branch.categories, color: Colors.black54, fontSize: 12.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class CustomAdvertisementCard extends StatelessWidget {
  final AdvertisementModel advertisement;

  const CustomAdvertisementCard({super.key, required this.advertisement});

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: kCardRatio,
    child: Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusS)),
          child: SizedBox.expand(
            child: Image.network(
              advertisement.adsImage,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Center(
                  child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: ResponsiveHelper.getPromoAdsHeight(context) / 2),
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
        ),
        Positioned(
          bottom: kPositionEmpty,
          left: kPositionEmpty,
          right: kPositionEmpty,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadiusGeometry.vertical(bottom: Radius.circular(kBorderRadiusS)),
              color: Colors.black.withValues(alpha: 0.25),
            ),
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, 8.0), vertical: ResponsiveHelper.getSpacing(context, 4.0)),
            child: CustomText(advertisement.adsTitle, color: Colors.white, fontSize: 16.0),
          ),
        ),
      ],
    ),
  );
}

class CustomProfileCard extends StatelessWidget {
  final String backgroundImage, image, memberCode, name;

  const CustomProfileCard({super.key, required this.backgroundImage, required this.image, required this.memberCode, required this.name});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
    child: CustomBackgroundImage(
      isBorderRadius: true,
      isShadow: true,
      backgroundImage: backgroundImage,
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 24.0)),
        child: IntrinsicHeight(
          child: Row(
            spacing: ResponsiveHelper.getSpacing(context, 24.0),
            children: <Widget>[
              CustomAvatarImage(size: kProfileImgSizeL, networkImage: image),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CustomText(name, color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
                    CustomText(memberCode, color: Colors.white, fontSize: 18.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class CustomPromotionCard extends StatefulWidget {
  final PromotionModel promotion;

  const CustomPromotionCard({super.key, required this.promotion});

  @override
  State<CustomPromotionCard> createState() => _CustomPromotionCardState();
}

class _CustomPromotionCardState extends State<CustomPromotionCard> {
  Duration _time = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final end = DateTime.fromMillisecondsSinceEpoch(widget.promotion.expiredDate);
    final difference = end.difference(now);

    setState(() => _time = difference.isNegative ? Duration.zero : difference);
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: kCardRatio,
    child: Stack(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusS)),
          child: SizedBox.expand(
            child: Image.network(
              widget.promotion.promotionImage,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Center(
                  child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: ResponsiveHelper.getPromoAdsHeight(context) / 2),
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
        ),
        Positioned(
          right: kPositionLabel,
          top: kPositionLabel,
          child: CustomLabelChip(icon: Icons.timer_rounded, label: FormatterHelper.displayCarousel(_time)),
        ),
        Positioned(
          bottom: kPositionEmpty,
          left: kPositionEmpty,
          right: kPositionEmpty,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadiusGeometry.vertical(bottom: Radius.circular(kBorderRadiusS)),
              color: Colors.black.withValues(alpha: 0.25),
            ),
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, 8.0), vertical: ResponsiveHelper.getSpacing(context, 4.0)),
            child: CustomText(widget.promotion.promotionTitle, color: Colors.white, fontSize: 16.0),
          ),
        ),
      ],
    ),
  );
}

class CustomSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const CustomSectionCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(kBorderRadiusS),
      color: Colors.white,
      boxShadow: <BoxShadow>[
        BoxShadow(color: Theme.of(context).colorScheme.surfaceContainerHigh, blurRadius: kBlurRadius, offset: Offset(kOffsetX, kOffsetY)),
        BoxShadow(color: Theme.of(context).colorScheme.surfaceDim, blurRadius: kBlurRadius, offset: Offset(-kOffsetX, -kOffsetY)),
      ],
    ),
    margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, 16.0), vertical: ResponsiveHelper.getSpacing(context, 8.0)),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(kBorderRadiusM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: ResponsiveHelper.getSpacing(context, 16.0),
              right: ResponsiveHelper.getSpacing(context, 16.0),
              top: ResponsiveHelper.getSpacing(context, 16.0),
            ),
            child: CustomText(title, color: Colors.black54, fontSize: 18.0),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getSpacing(context, 24.0),
              vertical: ResponsiveHelper.getSpacing(context, 16.0),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: ResponsiveHelper.getSpacing(context, 8.0), children: children),
          ),
        ],
      ),
    ),
  );
}

class CustomShopCard extends StatelessWidget {
  final BranchModel branch;

  const CustomShopCard({super.key, required this.branch});

  @override
  Widget build(BuildContext context) => InkWell(
    child: AspectRatio(
      aspectRatio: kCardRatio,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadiusM),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(color: Theme.of(context).colorScheme.surfaceContainerHigh, blurRadius: kBlurRadius, offset: Offset(kOffsetX, kOffsetY)),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, 16.0), vertical: ResponsiveHelper.getSpacing(context, 8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          spacing: ResponsiveHelper.getSpacing(context, 8.0),
          children: <Widget>[
            Row(
              spacing: ResponsiveHelper.getSpacing(context, 16.0),
              children: <Widget>[
                CustomAvatarImage(size: kProfileImgSizeM, networkImage: branch.companyLogo),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomText(branch.branchName, fontSize: 16.0, fontWeight: FontWeight.w700),
                      CustomText(branch.contactNumber, fontSize: 14.0),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: ResponsiveHelper.getSpacing(context, 4.0),
              children: <Widget>[
                CustomText(branch.companyName, fontSize: 14.0, maxLines: 2, fontWeight: FontWeight.bold),
                CustomText(branch.fullAddress, fontSize: 13.0, maxLines: 2),
                CustomText(branch.categories, color: Colors.black54, fontSize: 12.0, maxLines: 2),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
