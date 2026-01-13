import 'package:ezy_member_v2/main.dart';
import 'package:ezy_member_v2/views/authentication_screen.dart';
import 'package:ezy_member_v2/views/change_password_screen.dart';
import 'package:ezy_member_v2/views/company_detail_screen.dart';
import 'package:ezy_member_v2/views/branch_list_screen.dart';
import 'package:ezy_member_v2/views/forgot_password_screen.dart';
import 'package:ezy_member_v2/views/home_screen.dart';
import 'package:ezy_member_v2/views/invoice_screen.dart';
import 'package:ezy_member_v2/views/timeline_detail_screen.dart';
import 'package:ezy_member_v2/views/member_detail_screen.dart';
import 'package:ezy_member_v2/views/member_list_screen.dart';
import 'package:ezy_member_v2/views/notification_screen.dart';
import 'package:ezy_member_v2/views/payment_screen.dart';
import 'package:ezy_member_v2/views/scan_screen.dart';
import 'package:ezy_member_v2/views/profile_detail_screen.dart';
import 'package:ezy_member_v2/views/terms_condition_screen.dart';
import 'package:ezy_member_v2/views/voucher_list_screen.dart';
import 'package:ezy_member_v2/views/welcome_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const wrapper = "/";
  static const authentication = "/authentication";
  static const branchList = "/branch_list";
  static const changePassword = "/change_password";
  static const companyDetail = "/company_detail";
  static const forgotPassword = "/forgot_password";
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
    GetPage(name: authentication, page: () => AuthenticationScreen()),
    GetPage(name: branchList, page: () => BranchListScreen()),
    GetPage(name: changePassword, page: () => ChangePasswordScreen()),
    GetPage(name: companyDetail, page: () => CompanyDetailScreen()),
    GetPage(name: forgotPassword, page: () => ForgotPasswordScreen()),
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
}
