import 'package:ezymember/main.dart';
import 'package:ezymember/views/authentication_screen.dart';
import 'package:ezymember/views/change_password_screen.dart';
import 'package:ezymember/views/company_detail_screen.dart';
import 'package:ezymember/views/branch_list_screen.dart';
import 'package:ezymember/views/forgot_password_screen.dart';
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
