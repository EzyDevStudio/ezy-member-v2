import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/branch_model.dart';
import 'package:ezy_member_v2/models/timeline_model.dart';
import 'package:ezy_member_v2/widgets/custom_avatar.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class CustomTimeline extends StatelessWidget {
  final BranchModel branch;
  final TimelineModel timeline;

  const CustomTimeline({super.key, required this.branch, required this.timeline});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: ResponsiveHelper.getSpacing(context, SizeType.s),
    children: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, SizeType.m)),
        child: Row(
          spacing: ResponsiveHelper.getSpacing(context, SizeType.s),
          children: <Widget>[
            CustomAvatar(defaultSize: 50.0, desktopSize: 60.0, networkImage: branch.aboutUs.companyLogo),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomText(branch.branchName, fontSize: 18.0, fontWeight: FontWeight.bold),
                  CustomText(FormatterHelper.timestampToString(timeline.createdAt), fontSize: 14.0),
                ],
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, SizeType.m)),
        child: CustomText(timeline.timelineCaption, fontSize: 16.0, maxLines: null),
      ),
      Image.network(timeline.timelineImage, fit: BoxFit.cover, height: 300.0, width: double.infinity),
    ],
  );
}
