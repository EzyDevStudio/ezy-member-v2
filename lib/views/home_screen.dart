import 'dart:async';

import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/controllers/settings_controller.dart';
import 'package:ezymember/controllers/member_controller.dart';
import 'package:ezymember/controllers/member_hive_controller.dart';
import 'package:ezymember/controllers/timeline_controller.dart';
import 'package:ezymember/controllers/voucher_controller.dart';
import 'package:ezymember/helpers/code_generator_helper.dart';
import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/helpers/permission_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/widgets/custom_app_bar.dart';
import 'package:ezymember/widgets/custom_button.dart';
import 'package:ezymember/widgets/custom_fab.dart';
import 'package:ezymember/widgets/custom_image.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:ezymember/widgets/custom_timeline.dart';
import 'package:ezymember/widgets/custom_voucher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _hive = Get.find<MemberHiveController>();
  final _settingsController = Get.find<SettingsController>();
  final _memberController = Get.put(MemberController(), tag: "home");
  final _timelineController = Get.put(TimelineController(), tag: "home");
  final _voucherController = Get.put(VoucherController(), tag: "home");
  final _scrollController = ScrollController();

  // late StreamSubscription<bool> _subscription;

  bool _showFab = false;
  DateTime? _lastBackTime;

  void _showMemberCode() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (context) => ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(32.0),
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 32.dp,
          children: <Widget>[
            CustomText(Globalization.scan.tr, fontSize: 22.0, fontWeight: FontWeight.bold),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
              child: AspectRatio(
                aspectRatio: kCardRatio,
                child: CustomBackgroundImage(
                  isBorderRadius: true,
                  isShadow: true,
                  backgroundImage: _hive.backgroundImage,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CustomAvatarImage(size: kProfileImgSizeM, networkImage: _hive.image),
                          CustomText(_hive.memberProfile.value!.name, color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            CodeGeneratorHelper.barcode(_hive.memberProfile.value!.memberCode, padding: EdgeInsets.zero),
          ],
        ),
      ],
    ),
  );

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.offset > kBackToTop && !_showFab) {
        setState(() => _showFab = true);
      } else if (_scrollController.offset <= kBackToTop && _showFab) {
        setState(() => _showFab = false);
      }
    });

    // _subscription = ConnectionService.instance.stream.listen((connected) {
    //   if (!connected) {
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       MessageHelper.show(
    //         Globalization.msgConnectionOff.tr,
    //         backgroundColor: Theme.of(context).colorScheme.error,
    //         duration: Duration(seconds: 10),
    //         icon: Icons.wifi_off_rounded,
    //       );
    //     });
    //   }
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    await PermissionHelper.checkAndRequestLocation();

    // if (await PermissionHelper.checkAndRequestNotification()) {
    //   await NotificationService.show(id: 0, title: "EzyMember", body: "2 vouchers will be expired by today.");
    // }

    _timelineController.reset();
    _timelineController.loadTimelines(memberCode: _hive.isSignIn ? _hive.memberProfile.value!.memberCode : null);

    if (_hive.isSignIn) {
      _memberController.loadMembers(_hive.memberProfile.value!.memberCode);
      _voucherController.loadOverview(_hive.memberProfile.value!.memberCode);
    }
  }

  void _signOut() async {
    final bool? result = await MessageHelper.showConfirmationDialog(
      backgroundColor: Colors.red,
      icon: Icons.warning_rounded,
      message: Globalization.msgSignOutConfirmation.tr,
      title: Globalization.signOut.tr,
    );

    if (result == true) {
      _hive.signOut();
      _memberController.members.clear();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // _subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper().init(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        final now = DateTime.now();

        if (_lastBackTime == null || now.difference(_lastBackTime!) > const Duration(seconds: 2)) {
          _lastBackTime = now;

          MessageHelper.show(Globalization.msgPressBackAgain.tr, duration: const Duration(seconds: 2), icon: Icons.info_rounded);

          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Obx(
          () => RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[_buildAppBar(), if (_hive.isSignIn) _buildQuickAccess(), if (_hive.isSignIn) _buildVouchers(), _buildTimeline()],
            ),
          ),
        ),
        floatingActionButton: _showFab ? CustomFab(controller: _scrollController) : null,
      ),
    );
  }

  Widget _buildAppBar() => CustomAppBar(
    isLeading: false,
    avatarImage: _hive.isSignIn ? _hive.memberProfile.value!.image : "",
    backgroundImage: _hive.backgroundImage,
    actions: _buildAppBarAction(),
    onTap: () => Get.toNamed(_hive.isSignIn ? AppRoutes.profileDetail : AppRoutes.authentication),
    child: Expanded(
      child: Row(
        spacing: 16.dp,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CustomText(
                  _hive.isSignIn ? _hive.memberProfile.value!.name : Globalization.guest.tr,
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
                if (_hive.isSignIn)
                  CustomText(_hive.memberProfile.value!.memberCode, color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
              ],
            ),
          ),
          Obx(() {
            int totalCount = _voucherController.redeemableCount.value + _voucherController.todayCount.value;

            if (!_hive.isSignIn || totalCount <= 0) return SizedBox.shrink();

            return IconButton(
              onPressed: () => Get.toNamed(AppRoutes.notification),
              icon: Badge.count(
                count: totalCount,
                child: Icon(Icons.notifications_rounded, color: Colors.white, size: 40.0),
              ),
            );
          }),
        ],
      ),
    ),
  );

  List<Widget> _buildAppBarAction() => [
    PopupMenuButton<Locale>(
      onSelected: (locale) => _settingsController.changeLanguage(locale),
      itemBuilder: (context) => Globalization.languages.entries
          .map((entry) => PopupMenuItem<Locale>(value: entry.value, child: CustomText(entry.key, fontSize: 14.0)))
          .toList(),
      icon: const Icon(Icons.language_rounded, color: Colors.white),
    ),
    if (_hive.isSignIn) IconButton(onPressed: _signOut, icon: Icon(Icons.logout_rounded)),
  ];

  Widget _buildQuickAccess() => Obx(
    () => SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GridView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 24.dp),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 16.dp,
                mainAxisExtent: ResponsiveHelper().quickAccessHeight(),
                mainAxisSpacing: 16.dp,
                crossAxisCount: ResponsiveHelper().quickAccessCount(),
              ),
              children: <Widget>[
                CustomImageTextButton(
                  isCountVisible: true,
                  count: _voucherController.redeemedCount.value,
                  assetName: "assets/icons/my_vouchers.png",
                  label: Globalization.myVouchers.tr,
                  onTap: () => Get.toNamed(AppRoutes.voucherList, arguments: {"check_start": 0}),
                ),
                CustomImageTextButton(
                  isCountVisible: true,
                  count: _memberController.members.length,
                  assetName: "assets/icons/my_members.png",
                  label: Globalization.myCards.tr,
                  onTap: () => Get.toNamed(AppRoutes.memberList),
                ),
                CustomImageTextButton(
                  assetName: "assets/icons/invoice.png",
                  label: Globalization.eInvoice.tr,
                  onTap: () => Get.toNamed(AppRoutes.invoice),
                ),
                CustomImageTextButton(
                  assetName: "assets/icons/find_shops.png",
                  label: Globalization.findShop.tr,
                  onTap: () => Get.toNamed(AppRoutes.branchList),
                ),
                CustomImageTextButton(assetName: "assets/icons/scan.png", label: Globalization.scan.tr, onTap: _showMemberCode),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildVouchers() => Obx(() {
    if (_voucherController.vouchers.isEmpty) return SliverToBoxAdapter();

    final vouchers = _voucherController.vouchers;

    return SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.black38, blurRadius: 2.0, spreadRadius: 6.0),
                BoxShadow(color: Colors.black38, blurRadius: 5.0, spreadRadius: 12.0),
              ],
            ),
          ),
          Container(
            color: Colors.grey.withValues(alpha: 0.5),
            padding: EdgeInsets.symmetric(vertical: 8.dp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16.dp),
                  child: CustomText(Globalization.vouchers.tr, fontSize: 16.0, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: ResponsiveHelper().voucherHeight() + 8.dp,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: vouchers.length,
                    separatorBuilder: (_, _) => SizedBox(width: 16.dp),
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(bottom: 24.dp, left: index == 0 ? 16.dp : 0.0, right: index == vouchers.length - 1 ? 16.dp : 0.0),
                      child: CustomVoucher(
                        shadowColor: Colors.black54,
                        voucher: vouchers[index],
                        type: VoucherType.collectable,
                        onTapCollect: () async => _voucherController.collectVoucher(
                          vouchers[index].batchCode,
                          vouchers[index].companyID,
                          _hive.memberProfile.value!.memberCode,
                          _hive.memberProfile.value!.token,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 16.dp),
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.black38, blurRadius: 6.0, spreadRadius: 2.0, offset: Offset(0.0, -4.0)),
                BoxShadow(color: Colors.black38, blurRadius: 10.0, spreadRadius: 2.0, offset: Offset(0.0, -4.0)),
              ],
            ),
          ),
        ],
      ),
    );
  });

  Widget _buildTimeline() => Obx(() {
    if (_timelineController.isLoading.value) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    final timelines = _timelineController.timelines;

    if (timelines.isEmpty) return SliverToBoxAdapter();

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == timelines.length - 1 && _timelineController.hasMore && !_timelineController.isLoading.value) {
          _timelineController.loadTimelines(isLoadMore: true);
        }

        return Container(
          decoration: BoxDecoration(
            border: Border(
              top: index == 0 && !_hive.isSignIn ? BorderSide.none : BorderSide(color: Colors.grey.withValues(alpha: 0.7), width: 5.dp),
            ),
          ),
          child: CustomTimeline(timeline: timelines[index], isNavigateCompany: true, isNavigateTimeline: true),
        );
      }, childCount: timelines.length),
    );
  });
}
