import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class CustomLoading extends StatefulWidget {
  final String label;

  const CustomLoading({super.key, required this.label});

  @override
  State<CustomLoading> createState() => _CustomLoadingState();
}

class _CustomLoadingState extends State<CustomLoading> with SingleTickerProviderStateMixin {
  final String text = "......";

  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: Duration(milliseconds: 1200), vsync: this);
    _createAnimations();
    _controller.repeat();
  }

  void _createAnimations() {
    final length = text.length;

    _animations = List.generate(length, (index) {
      final start = (index / length).clamp(0.0, 1.0);
      final end = ((index / length) + 0.5).clamp(0.0, 1.0);

      return TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: -20.0).chain(CurveTween(curve: Curves.easeOut)), weight: 50.0),
        TweenSequenceItem(tween: Tween(begin: -20.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50.0),
      ]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.linear),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16.dp,
      children: <Widget>[
        Image.asset("assets/images/launcher.png", height: 100.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            text.length,
            (index) => AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) => Transform.translate(offset: Offset(0.0, _animations[index].value), child: child),
              child: CustomText(text[index], color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold, maxLines: null),
            ),
          ),
        ),
      ],
    ),
  );
}
