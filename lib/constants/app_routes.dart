import 'package:ezy_member_v2/main.dart';
import 'package:ezy_member_v2/views/authentication_screen.dart';
import 'package:ezy_member_v2/views/branch_detail_screen.dart';
import 'package:ezy_member_v2/views/branch_list_screen.dart';
import 'package:ezy_member_v2/views/history_screen.dart';
import 'package:ezy_member_v2/views/home_screen.dart';
import 'package:ezy_member_v2/views/media_viewer_screen.dart';
import 'package:ezy_member_v2/views/member_list_screen.dart';
import 'package:ezy_member_v2/views/notification_screen.dart';
import 'package:ezy_member_v2/views/payment_screen.dart';
import 'package:ezy_member_v2/views/profile_detail_screen.dart';
import 'package:ezy_member_v2/views/terms_condition_screen.dart';
import 'package:ezy_member_v2/views/voucher_list_screen.dart';
import 'package:ezy_member_v2/views/welcome_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const wrapper = "/";
  static const authentication = "/authentication";
  static const branchDetail = "/branch_detail";
  static const branchList = "/branch_list";
  static const history = "/history";
  static const home = "/home";
  static const mediaViewer = "/media_viewer";
  static const memberList = "/member_list";
  static const notification = "/notification";
  static const payment = "/payment";
  static const profileDetail = "/profile_detail";
  static const termsCondition = "/terms_condition";
  static const voucherList = "/voucher_list";
  static const welcome = "/welcome";

  static final pages = <GetPage>[
    GetPage(name: wrapper, page: () => WrapperScreen()),
    GetPage(name: authentication, page: () => AuthenticationScreen()),
    GetPage(name: branchDetail, page: () => BranchDetailScreen()),
    GetPage(name: branchList, page: () => BranchListScreen()),
    GetPage(name: history, page: () => HistoryScreen()),
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: mediaViewer, page: () => MediaViewerScreen()),
    GetPage(name: memberList, page: () => MemberListScreen()),
    GetPage(name: notification, page: () => NotificationScreen()),
    GetPage(name: payment, page: () => PaymentScreen()),
    GetPage(name: profileDetail, page: () => ProfileDetailScreen()),
    GetPage(name: termsCondition, page: () => TermsConditionScreen()),
    GetPage(name: voucherList, page: () => VoucherListScreen()),
    GetPage(name: welcome, page: () => WelcomeScreen()),
  ];
}
