import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/widgets/custom_image.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String avatarImage, backgroundImage;
  final List<Widget>? actions;
  final Widget child;

  const CustomAppBar({super.key, required this.avatarImage, required this.backgroundImage, this.actions, required this.child});

  @override
  Widget build(BuildContext context) => SliverAppBar(
    floating: true,
    pinned: true,
    snap: false,
    actions: actions,
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(kProfileImgSizeM + 32.dp),
      child: Padding(
        padding: EdgeInsets.all(16.dp),
        child: SafeArea(
          child: Row(
            spacing: 16.dp,
            children: <Widget>[
              CustomAvatarImage(size: kProfileImgSizeM, networkImage: avatarImage),
              child,
            ],
          ),
        ),
      ),
    ),
    flexibleSpace: FlexibleSpaceBar(background: CustomBackgroundImage(backgroundImage: backgroundImage)),
  );
}
