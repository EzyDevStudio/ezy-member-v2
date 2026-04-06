import 'dart:async';

import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/controllers/authentication_controller.dart';
import 'package:ezymember/controllers/settings_controller.dart';
import 'package:ezymember/controllers/member_hive_controller.dart';
import 'package:ezymember/controllers/timeline_controller.dart';
import 'package:ezymember/controllers/voucher_controller.dart';
import 'package:ezymember/helpers/code_generator_helper.dart';
import 'package:ezymember/helpers/formatter_helper.dart';
import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/helpers/permission_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/widgets/custom_app_bar.dart';
import 'package:ezymember/widgets/custom_button.dart';
import 'package:ezymember/widgets/custom_fab.dart';
import 'package:ezymember/widgets/custom_image.dart';
import 'package:ezymember/widgets/custom_menu.dart';
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
  final _authController = Get.put(AuthenticationController());
  final _timelineController = Get.put(TimelineController(), tag: "home");
  final _voucherController = Get.put(VoucherController(), tag: "home");
  final _scrollController = ScrollController();

  // late StreamSubscription<bool> _subscription;

  bool _showFab = false;

  void _showMemberCode() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (context) => ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(32.dp),
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
                  cacheImage: _hive.backgroundImage,
                  child: Padding(
                    padding: EdgeInsets.all(16.dp),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CustomAvatarImage(size: kProfileImgSizeM, cacheImage: _hive.image),
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
      _authController.checkToken(_hive.memberProfile.value!.memberCode, _hive.memberProfile.value!.token);
      _voucherController.loadOverview(_hive.memberProfile.value!.memberCode);
    }
  }

  void _signOut() async {
    final bool? result = await MessageHelper.confirmation(message: Globalization.msgSignOutConfirmation.tr, title: Globalization.signOut.tr);

    if (result == true) _hive.signOut();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // _subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    rsp.init(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        final bool? result = await MessageHelper.confirmation(message: Globalization.msgQuitApp.tr);

        if (result == true) SystemNavigator.pop();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: RefreshIndicator(onRefresh: _onRefresh, child: _buildMobile()),
        floatingActionButton: _showFab ? CustomFab(controller: _scrollController) : null,
      ),
    );
  }

  Widget _buildDesktop() => CustomMenu(
    title: Globalization.home.tr,
    child: ListView(
      controller: _scrollController,
      shrinkWrap: true,
      padding: EdgeInsets.all(16.dp),
      children: <Widget>[
        if (_hive.isSignIn)
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ResponsiveHelper.tabletLarge),
              child: _buildVouchers(),
            ),
          ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ResponsiveHelper.tabletLarge),
            child: _buildTimeline(),
          ),
        ),
      ],
    ),
  );

  Widget _buildMobile() => Obx(
    () => CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        _buildAppBar(),
        _buildQuickAccess(),
        SliverToBoxAdapter(child: _buildVouchers()),
        SliverToBoxAdapter(child: _buildTimeline()),
      ],
    ),
  );

  Widget _buildAppBar() => CustomAppBar(
    isLeading: false,
    cacheAvatar: _hive.image,
    cacheBackground: _hive.backgroundImage,
    actions: _buildAppBarAction(),
    onTap: () => Get.toNamed(_hive.isSignIn ? AppRoutes.profileDetail : AppRoutes.signIn),
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
                  CustomText(
                    _hive.memberProfile.value!.memberCode.displayMemberCode,
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
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
      icon: Icon(Icons.language_rounded, color: Colors.white),
    ),
    if (_hive.isSignIn)
      IconButton(
        onPressed: _signOut,
        icon: Icon(Icons.logout_rounded, color: Colors.white),
      ),
  ];

  Widget _buildQuickAccess() => Obx(
    () => SliverToBoxAdapter(
      child: Column(
        children: <Widget>[
          GridView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 16.dp),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 16.dp,
              mainAxisExtent: rsp.quickHeight(),
              mainAxisSpacing: 16.dp,
              crossAxisCount: rsp.quickCount(),
            ),
            children: <Widget>[
              if (_hive.isSignIn)
                CustomImageTextButton(
                  isCountVisible: true,
                  count: _voucherController.redeemedCount.value,
                  assetName: "assets/icons/my_vouchers.png",
                  label: Globalization.myVouchers.tr,
                  onTap: () => Get.toNamed(AppRoutes.voucherList, arguments: {"check_start": 0}),
                ),
              if (_hive.isSignIn)
                CustomImageTextButton(
                  isCountVisible: true,
                  count: _voucherController.memberCount.value,
                  assetName: "assets/icons/my_members.png",
                  label: Globalization.myCards.tr,
                  onTap: () => Get.toNamed(AppRoutes.memberList),
                ),
              if (_hive.isSignIn)
                CustomImageTextButton(
                  assetName: "assets/icons/invoice.png",
                  label: Globalization.eInvoice.tr,
                  onTap: () => Get.toNamed(AppRoutes.invoice),
                ),
              CustomImageTextButton(
                assetName: "assets/icons/find_shops.png",
                label: Globalization.findShop.tr,
                onTap: () => Get.toNamed(AppRoutes.companyList),
              ),
              if (_hive.isSignIn) CustomImageTextButton(assetName: "assets/icons/scan.png", label: Globalization.scan.tr, onTap: _showMemberCode),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildVouchers() => Obx(() {
    if (_voucherController.vouchers.isEmpty) {
      return Divider(color: Colors.grey.withValues(alpha: 0.7), thickness: 5.dp);
    }

    final vouchers = _voucherController.vouchers;

    return ClipRRect(
      borderRadius: BorderRadius.zero,
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
                  height: rsp.voucherHeight() + 8.dp,
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
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.black12, blurRadius: 2.0, spreadRadius: 6.0),
                BoxShadow(color: Colors.black26, blurRadius: 5.0, spreadRadius: 12.0),
              ],
            ),
          ),
        ],
      ),
    );
  });

  Widget _buildTimeline() => Obx(() {
    if (_timelineController.isLoading.value) {
      return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }

    final timelines = _timelineController.timelines;

    if (timelines.isEmpty) return SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: timelines.length,
      physics: NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => Divider(color: Colors.grey.withValues(alpha: 0.7), thickness: 5.dp),
      itemBuilder: (context, index) {
        if (index == timelines.length - 1 && _timelineController.hasMore && !_timelineController.isLoading.value) {
          _timelineController.loadTimelines(isLoadMore: true);
        }

        return CustomTimeline(timeline: timelines[index], isNavigateCompany: true, isNavigateTimeline: true);
      },
    );
  });
}
