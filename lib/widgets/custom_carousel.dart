import 'dart:async';

import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/advertisement_model.dart';
import 'package:ezy_member_v2/models/promotion_model.dart';
import 'package:ezy_member_v2/widgets/custom_chip.dart';
import 'package:flutter/material.dart';

class CustomAdsCarousel extends StatefulWidget {
  final List<AdvertisementModel> advertisements;

  const CustomAdsCarousel({super.key, required this.advertisements});

  @override
  State<CustomAdsCarousel> createState() => _CustomAdsCarouselState();
}

class _CustomAdsCarouselState extends State<CustomAdsCarousel> {
  final PageController _controller = PageController();

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _startAllTimers();
  }

  void _startAllTimers() {
    _timer?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _startCarouselTimer();
    });
  }

  void _startCarouselTimer() {
    _timer = Timer.periodic(const Duration(seconds: kCarouselInterval), (_) {
      if (!mounted || _controller.positions.isEmpty || widget.advertisements.isEmpty) return;

      int nextIndex = (_index + 1) % widget.advertisements.length;

      _controller.animateToPage(
        nextIndex,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: kCarouselAnimation),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: <Widget>[
      PageView.builder(
        controller: _controller,
        itemCount: widget.advertisements.length,
        onPageChanged: (index) => setState(() => _index = index),
        itemBuilder: (context, index) => Image.network(
          widget.advertisements[index].adsImage,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            return Center(
              child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: ResponsiveHelper.getPromoAdsHeight(context) / 2),
            );
          },
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;

            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          },
        ),
      ),
      Positioned(
        bottom: kPositionM,
        left: kPositionEmpty,
        right: kPositionEmpty,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.advertisements.length,
            (index) => AnimatedContainer(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kIndicatorSize / 2),
                color: _index == index ? Theme.of(context).colorScheme.primary : Colors.grey.withAlpha((0.6 * 255).round()),
              ),
              height: kIndicatorSize,
              width: _index == index ? kIndicatorSelected : kIndicatorSize,
              duration: const Duration(milliseconds: kCarouselAnimation),
              margin: const EdgeInsets.symmetric(horizontal: kIndicatorMargin),
            ),
          ),
        ),
      ),
    ],
  );
}

class CustomPromoCarousel extends StatefulWidget {
  final List<PromotionModel> promotions;

  const CustomPromoCarousel({super.key, required this.promotions});

  @override
  State<CustomPromoCarousel> createState() => _CustomPromoCarouselState();
}

class _CustomPromoCarouselState extends State<CustomPromoCarousel> {
  final PageController _controller = PageController();

  int _index = 0;
  Duration _timeLeft = Duration.zero;
  Timer? _carouselTimer;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    _startAllTimers();
  }

  void _startAllTimers() {
    _carouselTimer?.cancel();
    _countdownTimer?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _startCarouselTimer();
      _updateCountdown();
      _startCountdownTimer();
    });
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: kCarouselInterval), (_) {
      if (!mounted || _controller.positions.isEmpty || widget.promotions.isEmpty) return;

      int nextIndex = (_index + 1) % widget.promotions.length;

      _controller.animateToPage(
        nextIndex,
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: kCarouselAnimation),
      );
    });
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  void _updateCountdown() {
    if (widget.promotions.isEmpty || _index >= widget.promotions.length) return;

    final now = DateTime.now();
    final currentPromo = widget.promotions[_index];
    final promoEnd = currentPromo.expiredDate;
    final endTime = DateTime.fromMillisecondsSinceEpoch(promoEnd);
    final difference = endTime.difference(now);

    setState(() => _timeLeft = difference.isNegative ? Duration.zero : difference);
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _countdownTimer?.cancel();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: <Widget>[
      PageView.builder(
        controller: _controller,
        itemCount: widget.promotions.length,
        onPageChanged: (index) => setState(() => _index = index),
        itemBuilder: (context, index) => Image.network(
          widget.promotions[index].promotionImage,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            return Center(
              child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: ResponsiveHelper.getPromoAdsHeight(context) / 2),
            );
          },
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;

            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          },
        ),
      ),
      Positioned(
        right: kPositionLabel,
        top: kPositionLabel,
        child: CustomLabelChip(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          foregroundSize: 16.0,
          icon: Icons.timer_rounded,
          label: FormatterHelper.displayCarousel(_timeLeft),
        ),
      ),
      Positioned(
        bottom: kPositionM,
        left: kPositionEmpty,
        right: kPositionEmpty,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.promotions.length,
            (index) => AnimatedContainer(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kIndicatorSize / 2),
                color: _index == index ? Theme.of(context).colorScheme.primary : Colors.grey.withAlpha((0.6 * 255).round()),
              ),
              height: kIndicatorSize,
              width: _index == index ? kIndicatorSelected : kIndicatorSize,
              duration: const Duration(milliseconds: kCarouselAnimation),
              margin: const EdgeInsets.symmetric(horizontal: kIndicatorMargin),
            ),
          ),
        ),
      ),
    ],
  );
}
