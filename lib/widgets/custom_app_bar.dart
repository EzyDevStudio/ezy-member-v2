import 'dart:typed_data';

import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget {
  final bool isLeading;
  final String avatarImage, backgroundImage;
  final List<Widget>? actions;
  final Uint8List? cacheAvatar, cacheBackground;
  final VoidCallback? onTap;
  final Widget child;

  const CustomAppBar({
    super.key,
    this.isLeading = true,
    this.avatarImage = "",
    this.backgroundImage = "",
    this.actions,
    this.onTap,
    this.cacheAvatar,
    this.cacheBackground,
    required this.child,
  });

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
              GestureDetector(
                onTap: onTap,
                child: Stack(
                  children: <Widget>[
                    CustomAvatarImage(size: kProfileImgSizeM, networkImage: avatarImage, cacheImage: cacheAvatar),
                    if (onTap != null)
                      Positioned(
                        bottom: kPositionEmpty,
                        right: kPositionEmpty,
                        child: Container(
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.edit_rounded, color: Theme.of(context).colorScheme.primary, size: 15.0),
                        ),
                      ),
                  ],
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    ),
    flexibleSpace: FlexibleSpaceBar(
      background: CustomBackgroundImage(backgroundImage: backgroundImage, cacheImage: cacheBackground),
    ),
    leading: isLeading
        ? IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          )
        : null,
  );
}
