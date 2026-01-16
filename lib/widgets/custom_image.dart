import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:flutter/material.dart';

class CustomAvatarImage extends StatelessWidget {
  final double size;
  final String networkImage;

  const CustomAvatarImage({super.key, required this.size, required this.networkImage});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: size,
    width: size,
    child: ClipOval(
      child: networkImage.isNotEmpty
          ? Image.network(
              networkImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset("assets/images/default_avatar.jpg"),
            )
          : Image.asset("assets/images/default_avatar.jpg", fit: BoxFit.cover),
    ),
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
      borderRadius: isBorderRadius! ? BorderRadius.circular(kBorderRadiusM) : BorderRadius.zero,
      color: Theme.of(context).colorScheme.primary,
      boxShadow: isShadow!
          ? <BoxShadow>[
              BoxShadow(color: Theme.of(context).colorScheme.surfaceContainerHigh, blurRadius: kBlurRadius, offset: Offset(kOffsetX, kOffsetY)),
            ]
          : null,
    ),
    child: ClipRRect(
      borderRadius: isBorderRadius! ? BorderRadius.circular(kBorderRadiusM) : BorderRadius.zero,
      child: Stack(
        children: <Widget>[
          if (backgroundImage.isNotEmpty)
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.25), BlendMode.darken),
                child: Image.network(backgroundImage, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => SizedBox()),
              ),
            ),
          if (child != null) child!,
        ],
      ),
    ),
  );
}
