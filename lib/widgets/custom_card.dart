import 'dart:typed_data';

import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/helpers/formatter_helper.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/company_model.dart';
import 'package:ezymember/models/member_model.dart';
import 'package:ezymember/widgets/custom_image.dart';
import 'package:ezymember/widgets/custom_chip.dart';
import 'package:ezymember/widgets/custom_text.dart';
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
          padding: EdgeInsets.all(16.dp),
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
                        Flexible(
                          child: CustomText(member.company.companyName, color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Spacer(),
                    CustomAvatarImage(size: rsp.avatarSize() * 1.2, networkImage: member.company.companyLogo, name: member.company.companyName),
                    const Spacer(),
                    CustomText("${member.memberCard.cardTier} · ${member.memberCard.expiredDate.tsToStr}", color: Colors.white, fontSize: 16.0),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  CustomLabelChip(
                    backgroundColor: member.memberCard.expiredDate.isExpired ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                    label: member.memberCard.expiredDate.isExpired ? Globalization.expired.tr : Globalization.active.tr,
                  ),
                  const Spacer(),
                  CustomText(member.point.toString(), color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
                  CustomText(Globalization.points.tr, color: Colors.white, fontSize: 16.0),
                  const Spacer(),
                  CustomText(member.credit.toStringAsFixed(2), color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
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

class CustomProfileCard extends StatelessWidget {
  final String memberCode, name;
  final Uint8List? backgroundImage, image;

  const CustomProfileCard({super.key, required this.memberCode, required this.name, this.backgroundImage, this.image});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(16.dp),
    child: CustomBackgroundImage(
      isBorderRadius: true,
      isShadow: true,
      cacheImage: backgroundImage,
      child: Padding(
        padding: EdgeInsets.all(24.dp),
        child: IntrinsicHeight(
          child: Row(
            spacing: 24.dp,
            children: <Widget>[
              CustomAvatarImage(size: kProfileImgSizeL, cacheImage: image),
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
            child: CustomText(title, color: Colors.black54, fontSize: 16.0),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(bottom: 16.dp, left: 24.dp, right: 24.dp, top: 8.dp),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 8.dp, children: children),
          ),
        ],
      ),
    ),
  );
}

class CustomShopCard extends StatelessWidget {
  final CompanyModel company;

  const CustomShopCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      CustomAvatarImage(isCircle: false, size: kProfileImgSizeL, networkImage: company.companyLogo, name: company.companyName),
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 8.dp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.dp,
            children: <Widget>[
              CustomText(company.companyName, fontSize: 14.0, fontWeight: FontWeight.w700, maxLines: 2),
              CustomText(company.fullAddress, fontSize: 12.0),
              CustomText(company.categoryTitle.join(", "), color: Colors.black54, fontSize: 12.0),
              if (company.databaseName.isNotEmpty && company.domainName.isNotEmpty)
                CustomLabelChip(backgroundColor: Colors.green, foregroundSize: 12.0, label: Globalization.msgJoinEzyMember.tr),
            ],
          ),
        ),
      ),
    ],
  );
}
