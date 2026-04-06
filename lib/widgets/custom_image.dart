import 'dart:typed_data';

import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class CustomAvatarImage extends StatelessWidget {
  final bool isCircle, showEdit;
  final double size;
  final String networkImage;
  final String? name;
  final Uint8List? cacheImage;
  final VoidCallback? onTap;

  const CustomAvatarImage({
    super.key,
    this.isCircle = true,
    this.showEdit = false,
    required this.size,
    this.networkImage = "",
    this.name,
    this.cacheImage,
    this.onTap,
  });

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r"\s+"));

    List<String> initials = [];

    for (var word in words) {
      final cleaned = word.replaceAll(RegExp(r"[^a-zA-Z0-9]"), "");

      if (cleaned.isNotEmpty) initials.add(cleaned[0].toUpperCase());
      if (initials.length == 2) break;
    }

    if (initials.isEmpty) return "";

    return initials.join();
  }

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Stack(
      children: <Widget>[
        SizedBox(
          height: size,
          width: size,
          child: isCircle
              ? ClipOval(child: _buildImage())
              : ClipRRect(borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusS)), child: _buildImage()),
        ),
        if (showEdit)
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
  );

  Widget _buildImage() => cacheImage != null
      ? Image.memory(cacheImage!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => SizedBox())
      : Image.network(
          networkImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (name != null) {
              return Container(
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: CustomText(
                  _getInitials(name!),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else {
              return Image.asset("assets/images/default_avatar.jpg");
            }
          },
        );
}

class CustomBackgroundImage extends StatelessWidget {
  final bool? isBorderRadius, isShadow;
  final String backgroundImage;
  final Uint8List? cacheImage;
  final Widget? child;

  const CustomBackgroundImage({
    super.key,
    this.isBorderRadius = false,
    this.isShadow = false,
    this.backgroundImage = "",
    this.cacheImage,
    this.child,
  });

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
          Positioned.fill(
            child: ColorFiltered(colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.5), BlendMode.darken), child: _buildImage()),
          ),
          if (child != null) child!,
        ],
      ),
    ),
  );

  Widget _buildImage() => cacheImage != null
      ? Image.memory(cacheImage!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => SizedBox())
      : Image.network(
          backgroundImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(backgroundImage, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => SizedBox());
          },
        );
}
