import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/helpers/formatter_helper.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/models/timeline_model.dart';
import 'package:ezymember/widgets/custom_image.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTimeline extends StatelessWidget {
  final TimelineModel timeline;
  final bool isDetail, isNavigateCompany, isNavigateTimeline, isShowMore;

  const CustomTimeline({
    super.key,
    required this.timeline,
    this.isDetail = false,
    this.isNavigateCompany = false,
    this.isNavigateTimeline = false,
    this.isShowMore = true,
  });

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
          child: isShowMore
              ? CustomReadMore(
                  text: timeline.timelineCaption,
                  style: const TextStyle(fontFamily: "AlibabaPuHuiTi", fontSize: 16.0),
                )
              : CustomText(timeline.timelineCaption, fontSize: 16.0, maxLines: null),
        ),
        GestureDetector(
          onTap: () => isDetail ? null : (isNavigateTimeline ? Get.toNamed(AppRoutes.timelineDetail, arguments: {"timeline": timeline}) : null),
          child: Image.network(
            timeline.timelineImage,
            fit: BoxFit.cover,
            height: isDetail ? null : kTimelineHeight,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey,
              padding: EdgeInsets.all(32.dp),
              child: Center(
                child: Icon(Icons.broken_image_rounded, color: Colors.white, size: 70.dp),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
