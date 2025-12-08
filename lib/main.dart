import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/constants/app_themes.dart';
import 'package:ezy_member_v2/controllers/advertisement_controller.dart';
import 'package:ezy_member_v2/controllers/authentication_controller.dart';
import 'package:ezy_member_v2/controllers/branch_controller.dart';
import 'package:ezy_member_v2/controllers/member_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/profile_controller.dart';
import 'package:ezy_member_v2/controllers/promotion_controller.dart';
import 'package:ezy_member_v2/controllers/voucher_controller.dart';
import 'package:ezy_member_v2/services/local/connection_service.dart';
import 'package:ezy_member_v2/services/local/member_profile_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Settle AssetImage, NetworkImage, Image.asset, Image.network
// Settle image such as avatar

// Required Controller: voucher_controller.dart

// Done Screen: authentication_screen.dart, terms_condition_screen.dart, welcome_screen.dart

// Check response 500 for access key: all

// Check string "": all

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MemberProfileStorageService().init();

  Get.put(AdvertisementController());
  Get.put(AuthenticationController());
  Get.put(BranchController());
  Get.put(MemberController());
  Get.put(MemberHiveController());
  Get.put(ProfileController());
  Get.put(PromotionController());
  Get.put(VoucherController());

  ConnectionService.instance.start();

  runApp(GetMaterialApp(title: AppStrings.appName, theme: AppThemes().lightTheme, initialRoute: AppRoutes.wrapper, getPages: AppRoutes.pages));
}

class WrapperScreen extends StatefulWidget {
  const WrapperScreen({super.key});

  @override
  State<WrapperScreen> createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> with SingleTickerProviderStateMixin {
  final _memberController = Get.find<MemberHiveController>();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.25).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnimation = Tween<double>(begin: 0.25, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSignIn());
  }

  Future<void> _checkSignIn() async {
    await _memberController.loadMemberHive();
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (_memberController.isSignIn) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(scale: _scaleAnimation, child: Image.asset(AppStrings.tmpImgSplashLogo)),
        ),
      ),
    ),
  );
}
