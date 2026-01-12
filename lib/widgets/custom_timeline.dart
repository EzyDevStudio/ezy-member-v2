import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/timeline_model.dart';
import 'package:ezy_member_v2/widgets/custom_image.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTimeline extends StatelessWidget {
  final TimelineModel timeline;
  final bool isDetail, isNavigateCompany, isNavigateTimeline;

  const CustomTimeline({super.key, required this.timeline, this.isDetail = false, this.isNavigateCompany = false, this.isNavigateTimeline = false});

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getSpacing(context, 16.0)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: ResponsiveHelper.getSpacing(context, 8.0),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, 16.0)),
          child: Row(
            spacing: ResponsiveHelper.getSpacing(context, 8.0),
            children: <Widget>[
              GestureDetector(
                onTap: () => isDetail
                    ? null
                    : (isNavigateCompany ? Get.toNamed(AppRoutes.companyDetail, arguments: {"company_id": timeline.companyID}) : null),
                child: CustomAvatarImage(size: ResponsiveHelper.getBranchImgSize(context), networkImage: timeline.companyLogo),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CustomText(timeline.companyName, fontSize: 18.0, fontWeight: FontWeight.bold),
                    CustomText(FormatterHelper.timestampToString(timeline.createdAt), fontSize: 14.0),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, 16.0)),
          child: CustomReadMore(
            text: timeline.timelineCaption,
            style: const TextStyle(fontFamily: "AlibabaPuHuiTi", fontSize: 16.0),
          ),
        ),
        GestureDetector(
          onTap: () => isDetail ? null : (isNavigateTimeline ? Get.toNamed(AppRoutes.timelineDetail, arguments: {"timeline": timeline}) : null),
          child: Image.network(timeline.timelineImage, fit: BoxFit.cover, height: isDetail ? null : kTimelineHeight, width: double.infinity),
        ),
      ],
    ),
  );
}
