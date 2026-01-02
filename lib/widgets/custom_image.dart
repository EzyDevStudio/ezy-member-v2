import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:flutter/material.dart';

class CustomAvatarImage extends StatelessWidget {
  final double size;
  final String networkImage;

  const CustomAvatarImage({super.key, required this.size, required this.networkImage});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      image: DecorationImage(
        fit: BoxFit.cover,
        image: networkImage.isNotEmpty ? NetworkImage(networkImage) : AssetImage("assets/images/default_avatar.jpg"),
      ),
    ),
    height: size,
    width: size,
  );
}

class CustomBackgroundImage extends StatelessWidget {
  final bool? isBorderRadius, isShadow;
  final String backgroundImage;
  final Widget? child;

  const CustomBackgroundImage({super.key, this.isBorderRadius = false, this.isShadow = false, required this.backgroundImage, this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: isBorderRadius! ? BorderRadius.circular(kBorderRadiusM) : null,
      color: Theme.of(context).colorScheme.primary,
      image: backgroundImage.isNotEmpty
          ? DecorationImage(
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.25), BlendMode.darken),
              image: NetworkImage(backgroundImage),
            )
          : null,
      boxShadow: isShadow!
          ? <BoxShadow>[
              BoxShadow(color: Theme.of(context).colorScheme.surfaceContainerHigh, blurRadius: kBlurRadius, offset: Offset(kOffsetX, kOffsetY)),
            ]
          : null,
    ),
    child: child,
  );
}
