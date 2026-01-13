import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/constants/app_themes.dart';
import 'package:ezy_member_v2/controllers/authentication_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/settings_controller.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/language/intl_keys.dart';
import 'package:ezy_member_v2/services/local/connection_service.dart';
import 'package:ezy_member_v2/services/local/member_profile_storage_service.dart';
import 'package:ezy_member_v2/services/local/notification_service.dart';
import 'package:ezy_member_v2/services/local/settings_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Settle AssetImage, NetworkImage, Image.asset, Image.network
// quick access "Shops Nearby", "Company Subscribed (See Who’s on Our App / Trusted by These Companies)"
// combine api - home, member_detail, company_detail

// Possible Features: Payment Gateway (Join or Renew member), soe company don't want expiry
// Possible Features: Google Sign In or Up
// Possible Features: Referral Program - deep linking (Gain points or voucher)
// Possible Features: Point expires
// Possible Features: Voucher auto show (new user, birthday)
// Possible Features: Auto upgrade or downgrade member tier
// Possible Features: Device sign in another devices

// run "adb devices" to get devices
// run "adb -s <DEVICE_NAME> reverse tcp:8000 tcp:8000" for physical device
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await MemberProfileStorageService().init();
  await NotificationService.init();
  await SettingsStorageService().init();

  Get.put(MemberHiveController());
  Get.put(SettingsController());

  ConnectionService.instance.start();

  runApp(
    GetMaterialApp(
      builder: (context, child) {
        ResponsiveHelper().init(context);
        return child!;
      },
      title: AppStrings.appName,
      theme: AppThemes().lightTheme,
      getPages: AppRoutes.pages,
      initialRoute: AppRoutes.wrapper,
      locale: Get.locale,
      fallbackLocale: Globalization.defaultLocale,
      translations: IntlKeys(),
      supportedLocales: Globalization.languages.values.toList(),
      localizationsDelegates: [GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
    ),
  );
}

class WrapperScreen extends StatefulWidget {
  const WrapperScreen({super.key});

  @override
  State<WrapperScreen> createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> with SingleTickerProviderStateMixin {
  final _authController = Get.put(AuthenticationController());
  final _hive = Get.find<MemberHiveController>();

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
    await _hive.loadMemberHive();
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (_hive.isSignIn) {
      await _authController.checkToken(_hive.memberProfile.value!.memberCode, _hive.memberProfile.value!.token);

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
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxHeight: size.height * 0.5, maxWidth: size.width * 0.5),
                  decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/splash_logo.png"))),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
