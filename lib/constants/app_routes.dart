import 'package:ezymember/main.dart';
import 'package:ezymember/views/authentication/change_password_screen.dart';
import 'package:ezymember/views/authentication/forgot_password_screen.dart';
import 'package:ezymember/views/authentication/sign_in_screen.dart';
import 'package:ezymember/views/authentication/sign_up_screen.dart';
import 'package:ezymember/views/company_detail_screen.dart';
import 'package:ezymember/views/company_list_screen.dart';
import 'package:ezymember/views/home_screen.dart';
import 'package:ezymember/views/invoice_screen.dart';
import 'package:ezymember/views/timeline_detail_screen.dart';
import 'package:ezymember/views/member_detail_screen.dart';
import 'package:ezymember/views/member_list_screen.dart';
import 'package:ezymember/views/notification_screen.dart';
import 'package:ezymember/views/payment_screen.dart';
import 'package:ezymember/views/scan_screen.dart';
import 'package:ezymember/views/profile_detail_screen.dart';
import 'package:ezymember/views/terms_condition_screen.dart';
import 'package:ezymember/views/voucher_list_screen.dart';
import 'package:ezymember/views/welcome_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const wrapper = "/";
  static const changePassword = "/authentication/change_password";
  static const forgotPassword = "/authentication/forgot_password";
  static const signIn = "/authentication/sign_in";
  static const signUp = "/authentication/sign_up";
  static const companyDetail = "/company_detail";
  static const companyList = "/company_list";
  static const home = "/home";
  static const invoice = "/invoice";
  static const memberDetail = "/member_detail";
  static const memberList = "/member_list";
  static const notification = "/notification";
  static const payment = "/payment";
  static const scan = "/scan";
  static const profileDetail = "/profile_detail";
  static const termsCondition = "/terms_condition";
  static const timelineDetail = "/timeline_detail";
  static const voucherList = "/voucher_list";
  static const welcome = "/welcome";

  static final pages = <GetPage>[
    GetPage(name: wrapper, page: () => WrapperScreen()),
    GetPage(name: changePassword, page: () => ChangePasswordScreen()),
    GetPage(name: forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(name: signIn, page: () => SignInScreen()),
    GetPage(name: signUp, page: () => SignUpScreen()),
    GetPage(name: companyDetail, page: () => CompanyDetailScreen()),
    GetPage(name: companyList, page: () => CompanyListScreen()),
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: invoice, page: () => InvoiceScreen()),
    GetPage(name: memberDetail, page: () => MemberDetailScreen()),
    GetPage(name: memberList, page: () => MemberListScreen()),
    GetPage(name: notification, page: () => NotificationScreen()),
    GetPage(name: payment, page: () => PaymentScreen()),
    GetPage(name: scan, page: () => ScanScreen()),
    GetPage(name: profileDetail, page: () => ProfileDetailScreen()),
    GetPage(name: termsCondition, page: () => TermsConditionScreen()),
    GetPage(name: timelineDetail, page: () => TimelineDetailScreen()),
    GetPage(name: voucherList, page: () => VoucherListScreen()),
    GetPage(name: welcome, page: () => WelcomeScreen()),
  ];

  static void back({String? destination, String fallback = AppRoutes.welcome}) {
    if (destination == null && Get.previousRoute.isEmpty) {
      Get.offAllNamed(fallback);
    } else if (destination == null && Get.previousRoute.isNotEmpty) {
      Get.back();
    } else if (destination != null && Get.previousRoute.isEmpty) {
      Get.offAllNamed(destination);
    } else if (destination != null && Get.previousRoute.isNotEmpty) {
      Get.previousRoute == destination ? Get.back() : Get.offAllNamed(destination);
    } else {
      Get.offAllNamed(fallback);
    }
  }

  static void backAuth() {
    bool found = false;

    Get.until((route) {
      if (route.settings.name == AppRoutes.welcome || route.settings.name == AppRoutes.home) {
        found = true;

        return true;
      }

      return false;
    });

    if (!found) Get.offAllNamed(AppRoutes.welcome);
  }
}
