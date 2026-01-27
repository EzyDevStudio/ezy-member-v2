import 'package:app_links/app_links.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/constants/app_themes.dart';
import 'package:ezy_member_v2/controllers/authentication_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/settings_controller.dart';
import 'package:ezy_member_v2/firebase_options.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/language/intl_keys.dart';
import 'package:ezy_member_v2/services/local/connection_service.dart';
import 'package:ezy_member_v2/services/local/member_profile_storage_service.dart';
import 'package:ezy_member_v2/services/local/notification_service.dart';
import 'package:ezy_member_v2/services/local/settings_storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Future Features: Point expires
// Future Features: Auto upgrade or downgrade member tier
// Pending Features: Payment Gateway (Join or Renew member)
// Pending Features: Member code change to member card number
// Pending Features: App Bar put all logo instead of text

// run "adb devices" to get devices
// run "adb -s <DEVICE_NAME> reverse tcp:8000 tcp:8000" for physical device
// run php artisan serve --host=0.0.0.0 --port=8000 for API
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

    AppLinks appLinks = AppLinks();
    appLinks.uriLinkStream.listen((uri) {
      // TODO: 1. Deep Linking
      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == "company_detail") {
        final companyID = uri.pathSegments.length > 1 ? uri.pathSegments[1] : "";
        final referralCode = uri.pathSegments.length > 2 ? uri.pathSegments[2] : "";

        if (companyID.isNotEmpty) {
          Get.offAllNamed(AppRoutes.home);
          Future.delayed(
            const Duration(milliseconds: 300),
            () => Get.toNamed(AppRoutes.companyDetail, arguments: {"company_id": companyID, "referral_code": referralCode}),
          );
        }
      }
    });
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
                  child: Image.asset("assets/images/logo.png", fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
