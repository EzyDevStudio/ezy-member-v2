import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final double size;
  final String networkImage;

  const CustomAvatar({super.key, required this.size, required this.networkImage});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      image: DecorationImage(
        fit: BoxFit.cover,
        image: networkImage.isNotEmpty ? NetworkImage(networkImage) : AssetImage(AppStrings.tmpImgDefaultAvatar),
      ),
    ),
    height: size,
    width: size,
  );
}
