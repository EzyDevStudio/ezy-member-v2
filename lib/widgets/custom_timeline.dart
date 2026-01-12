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
    padding: EdgeInsets.symmetric(vertical: 16.dp),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.dp,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.dp),
          child: Row(
            spacing: 8.dp,
            children: <Widget>[
              GestureDetector(
                onTap: () => isDetail
                    ? null
                    : (isNavigateCompany ? Get.toNamed(AppRoutes.companyDetail, arguments: {"company_id": timeline.companyID}) : null),
                child: CustomAvatarImage(size: ResponsiveHelper().avatarSize(), networkImage: timeline.companyLogo),
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
          padding: EdgeInsets.symmetric(horizontal: 16.dp),
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
