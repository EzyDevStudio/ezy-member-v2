import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/models/branch_model.dart';
import 'package:ezy_member_v2/models/company_model.dart';
import 'package:ezy_member_v2/models/member_model.dart';
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
            spacing: 16.dp,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      spacing: 8.dp,
                      children: <Widget>[
                        if (member.memberCard.isFavorite) Icon(Icons.favorite_rounded, color: Colors.red),
                        CustomText(member.companyName, color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                      ],
                    ),
                    const Spacer(),
                    CustomAvatarImage(size: ResponsiveHelper().avatarSize() * 1.2, networkImage: member.companyLogo),
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
                    label: member.isExpired ? Globalization.expired.tr : Globalization.active.tr,
                  ),
                  const Spacer(),
                  CustomText(member.point.toString(), color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                  CustomText(Globalization.points.tr, color: Colors.white, fontSize: 16.0),
                  const Spacer(),
                  CustomText(member.credit.toStringAsFixed(1), color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                  CustomText(Globalization.credits.tr, color: Colors.white, fontSize: 16.0),
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
  final CompanyModel company;
  final MemberModel member;

  const CustomNearbyCard({super.key, required this.branch, required this.company, required this.member});

  @override
  Widget build(BuildContext context) => AspectRatio(
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
                      member.companyLogo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: 52.dp),
                      ),
                    ),
                  ),
                ),
                if (member.isMember) ...[
                  if (member.isExpired)
                    Positioned(
                      right: kPositionLabel,
                      top: kPositionLabel,
                      child: CustomLabelChip(label: Globalization.expired.tr),
                    ),
                  Positioned(
                    bottom: kPositionLabel,
                    right: kPositionLabel,
                    child: Row(
                      spacing: 8.dp,
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
                    child: CustomLabelChip(label: Globalization.joinNow.tr),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 8.dp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 4.dp,
              children: <Widget>[
                CustomText(branch.branchName, fontSize: 16.0, fontWeight: FontWeight.w700),
                CustomText(branch.fullAddress, fontSize: 14.0),
                CustomText(company.getCategoryTitles(), color: Colors.black54, fontSize: 12.0),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class CustomProfileCard extends StatelessWidget {
  final String backgroundImage, image, memberCode, name;

  const CustomProfileCard({super.key, required this.backgroundImage, required this.image, required this.memberCode, required this.name});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(16.dp),
    child: CustomBackgroundImage(
      isBorderRadius: true,
      isShadow: true,
      backgroundImage: backgroundImage,
      child: Padding(
        padding: EdgeInsets.all(24.dp),
        child: IntrinsicHeight(
          child: Row(
            spacing: 24.dp,
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
    margin: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 8.dp),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(kBorderRadiusM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: 16.dp, right: 16.dp, top: 16.dp),
            child: CustomText(title, color: Colors.black54, fontSize: 18.0),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24.dp, vertical: 16.dp),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8.dp, children: children),
          ),
        ],
      ),
    ),
  );
}
