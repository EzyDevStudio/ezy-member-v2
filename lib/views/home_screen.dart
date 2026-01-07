import 'dart:async';

import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/controllers/branch_controller.dart';
import 'package:ezy_member_v2/controllers/settings_controller.dart';
import 'package:ezy_member_v2/controllers/member_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/timeline_controller.dart';
import 'package:ezy_member_v2/controllers/voucher_controller.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/helpers/permission_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/widgets/custom_image.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:ezy_member_v2/widgets/custom_card.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:ezy_member_v2/widgets/custom_timeline.dart';
import 'package:ezy_member_v2/widgets/custom_voucher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_bar_code/code/code.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _hive = Get.find<MemberHiveController>();
  final _settingsController = Get.find<SettingsController>();
  final _branchController = Get.put(BranchController(), tag: "home");
  final _memberController = Get.put(MemberController(), tag: "home");
  final _timelineController = Get.put(TimelineController(), tag: "home");
  final _voucherController = Get.put(VoucherController(), tag: "home");
  final _scrollController = ScrollController();

  // late StreamSubscription<bool> _subscription;

  bool _showFab = false;

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

    _branchController.loadBranches(true);
    _timelineController.loadTimelines();

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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    body: Obx(
      () => RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            _buildAppBar(),
            if (_hive.isSignIn) _buildQuickAccess(),
            if (_hive.isSignIn) _buildVouchers(),
            _buildNearby(),
            _buildTimeline(),
          ],
        ),
      ),
    ),
    floatingActionButton: _showFab ? _buildFAB() : null,
  );

  Widget _buildAppBar() => SliverAppBar(
    floating: true,
    pinned: true,
    snap: false,
    actions: _buildAppBarAction(),
    bottom: _buildAppBarBottom(),
    flexibleSpace: FlexibleSpaceBar(background: CustomBackgroundImage(backgroundImage: _hive.backgroundImage)),
    title: Text(Globalization.home.tr),
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

  PreferredSize _buildAppBarBottom() => PreferredSize(
    preferredSize: Size.fromHeight(kProfileImgSizeM + ResponsiveHelper.getSpacing(context, 32.0)),
    child: Padding(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
      child: SafeArea(
        child: Column(
          spacing: ResponsiveHelper.getSpacing(context, 16.0),
          children: <Widget>[
            Row(
              spacing: ResponsiveHelper.getSpacing(context, 16.0),
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Get.toNamed(_hive.isSignIn ? AppRoutes.profileDetail : AppRoutes.authentication),
                      child: CustomAvatarImage(size: kProfileImgSizeM, networkImage: _hive.isSignIn ? _hive.memberProfile.value!.image : ""),
                    ),
                    Positioned(
                      bottom: kPositionEmpty,
                      right: kPositionEmpty,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(Icons.edit_rounded, color: Theme.of(context).colorScheme.primary, size: 15.0),
                        ),
                      ),
                    ),
                  ],
                ),
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
          ],
        ),
      ),
    ),
  );

  Widget _buildQuickAccess() => Obx(
    () => SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GridView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getSpacing(context, 16.0),
                vertical: ResponsiveHelper.getSpacing(context, 24.0),
              ),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: ResponsiveHelper.getSpacing(context, 16.0),
                mainAxisExtent: ResponsiveHelper.getQuickAccessHeight(context),
                mainAxisSpacing: ResponsiveHelper.getSpacing(context, 16.0),
                crossAxisCount: ResponsiveHelper.getQuickAccessCount(context),
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
                CustomImageTextButton(assetName: "assets/icons/invoice.png", label: Globalization.eInvoice.tr, onTap: () => Get.toNamed(AppRoutes.invoice)),
              ],
            ),
            _buildBarcode(),
          ],
        ),
      ),
    ),
  );

  Widget _buildBarcode() => InkWell(
    onTap: () => Get.toNamed(AppRoutes.scan),
    child: Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveHelper.getSpacing(context, 24.0),
        left: ResponsiveHelper.getSpacing(context, 32.0),
        right: ResponsiveHelper.getSpacing(context, 32.0),
      ),
      child: AspectRatio(
        aspectRatio: 4 / 1,
        child: Code(drawText: false, codeType: CodeType.code128(), backgroundColor: Colors.white, data: _hive.memberProfile.value!.memberCode),
      ),
    ),
  );

  Widget _buildVouchers() => Obx(() {
    if (_voucherController.vouchers.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          color: Colors.grey.withValues(alpha: 0.7),
          height: ResponsiveHelper.getSpacing(context, 5.0),
          margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context, 8.0)),
        ),
      );
    }

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
            padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.getSpacing(context, 8.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
                  child: CustomText(Globalization.vouchers.tr, fontSize: 16.0, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: ResponsiveHelper.getVoucherHeight(context) + ResponsiveHelper.getSpacing(context, 8.0),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: vouchers.length,
                    separatorBuilder: (_, _) => SizedBox(width: ResponsiveHelper.getSpacing(context, 16.0)),
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(
                        bottom: ResponsiveHelper.getSpacing(context, 24.0),
                        left: index == 0 ? ResponsiveHelper.getSpacing(context, 16.0) : 0.0,
                        right: index == vouchers.length - 1 ? ResponsiveHelper.getSpacing(context, 16.0) : 0.0,
                      ),
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
            margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context, 16.0)),
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

  Widget _buildNearby() => SliverToBoxAdapter(
    child: Padding(
      padding: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context, 16.0)),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: ResponsiveHelper.getSpacing(context, 16.0),
              children: <Widget>[
                Expanded(child: CustomText(Globalization.shopsNearby.tr, fontSize: 16.0, fontWeight: FontWeight.w600)),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.branchList),
                  child: CustomText(Globalization.viewAll.tr, color: Colors.blue, fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Obx(() {
            if (_branchController.isLoading.value) {
              return SizedBox(
                height: ResponsiveHelper.getNearbyHeight(context),
                child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
              );
            }

            if (_branchController.branches.isEmpty) {
              return SizedBox(
                height: ResponsiveHelper.getNearbyHeight(context),
                child: Center(
                  child: CustomText(Globalization.msgNoAvailable.trParams({"label": Globalization.shopsNearby.tr.toLowerCase()}), fontSize: 16.0, maxLines: 2),
                ),
              );
            }

            return SizedBox(
              height: ResponsiveHelper.getNearbyHeight(context),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _branchController.branches.length,
                separatorBuilder: (_, _) => SizedBox(width: ResponsiveHelper.getSpacing(context, 16.0)),
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: ResponsiveHelper.getSpacing(context, 16.0),
                    left: index == 0 ? ResponsiveHelper.getSpacing(context, 16.0) : 0.0,
                    right: index == _branchController.branches.length - 1 ? ResponsiveHelper.getSpacing(context, 16.0) : 0.0,
                  ),
                  child: GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.companyDetail, arguments: {"company_id": _branchController.branches[index].companyID}),
                    child: CustomNearbyCard(branch: _branchController.branches[index], members: _memberController.members),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    ),
  );

  Widget _buildTimeline() => Obx(() {
    if (_branchController.branches.isEmpty || _timelineController.timelines.isEmpty) return SliverToBoxAdapter();

    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.withValues(alpha: 0.7), width: ResponsiveHelper.getSpacing(context, 5.0)),
          ),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _timelineController.timelines.length,
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (_, _) => Container(color: Colors.grey.withValues(alpha: 0.7), height: ResponsiveHelper.getSpacing(context, 5.0)),
          itemBuilder: (context, index) => CustomTimeline(timeline: _timelineController.timelines[index]),
        ),
      ),
    );
  });

  Widget _buildFAB() => FloatingActionButton(
    onPressed: () => _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut),
    child: Icon(Icons.keyboard_arrow_up_rounded),
  );
}
