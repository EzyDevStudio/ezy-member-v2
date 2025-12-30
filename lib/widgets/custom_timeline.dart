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

  const CustomTimeline({super.key, required this.timeline});

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
              CustomAvatarImage(size: ResponsiveHelper.getBranchImgSize(context), networkImage: timeline.companyLogo),
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
          child: CustomText(timeline.timelineCaption, fontSize: 16.0, maxLines: null),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.mediaViewer, arguments: {"media_url": timeline.timelineImage}),
          child: Image.network(timeline.timelineImage, fit: BoxFit.cover, height: kTimelineHeight, width: double.infinity),
        ),
      ],
    ),
  );
}
