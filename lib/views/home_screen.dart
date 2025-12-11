import 'dart:async';

import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/controllers/advertisement_controller.dart';
import 'package:ezy_member_v2/controllers/branch_controller.dart';
import 'package:ezy_member_v2/controllers/member_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/promotion_controller.dart';
import 'package:ezy_member_v2/controllers/timeline_controller.dart';
import 'package:ezy_member_v2/controllers/voucher_controller.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/services/local/connection_service.dart';
import 'package:ezy_member_v2/widgets/custom_avatar.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:ezy_member_v2/widgets/custom_card.dart';
import 'package:ezy_member_v2/widgets/custom_modal.dart';
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
  final _adsController = Get.put(AdvertisementController(), tag: "home");
  final _branchController = Get.put(BranchController(), tag: "home");
  final _memberController = Get.put(MemberController(), tag: "home");
  final _promoController = Get.put(PromotionController(), tag: "home");
  final _voucherController = Get.put(VoucherController(), tag: "home");
  final _hive = Get.find<MemberHiveController>();

  final _timelineController = Get.put(TimelineController(), tag: "home");

  late StreamSubscription<bool> _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = ConnectionService.instance.stream.listen((connected) {
      if (!connected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          MessageHelper.show(
            AppStrings.msgConnectionOff,
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: Duration(seconds: 10),
            icon: Icons.wifi_off_rounded,
          );
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());

    ever(_branchController.branches, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _hive.loadMemberHive();

        if (_hive.isSignIn && _branchController.branches.isNotEmpty) _memberController.loadMembersCheckStart(_hive.memberProfile.value!.memberCode);

        _timelineController.loadTimelines(companyID: "SIGMA1234");
      });
    });
  }

  Future<void> _onRefresh() async {
    _adsController.loadAdvertisements();
    _branchController.loadBranches(true);
    _promoController.loadPromotions();

    await _hive.loadMemberHive();

    if (_hive.isSignIn) {
      _voucherController.loadCollectableVouchers(_hive.memberProfile.value!.memberCode);
      _memberController.loadMembers(_hive.memberProfile.value!.memberCode);
    }
  }

  void _signOut() async {
    final bool? result = await CustomConfirmationDialog.show(
      context,
      backgroundColor: Colors.red,
      icon: Icons.warning_rounded,
      message: AppStrings.msgSignOutConfirmation,
      title: AppStrings.signOut,
    );

    if (result == true) {
      _hive.signOut();
      _memberController.membersCheckStart.value = [];
    }
  }

  @override
  void dispose() {
    _subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Obx(
      () => RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar2(),
            // _buildUserInfo(),
            if (_hive.isSignIn) ...[_buildQuickAccess(), _buildSection(AppStrings.vouchers, _buildVouchers(), isPrimaryContainer: true)],
            _buildSection(AppStrings.shopsNearby, _buildNearby(), onTap: () {}),
            // _buildSection(AppStrings.promotions, _buildPromotions(), isPrimaryContainer: true),
            // _buildSection(AppStrings.advertisements, _buildAdvertisements()),
            _buildTimeline(),
          ],
        ),
      ),
    ),
  );

  Widget _buildAppBar() => SliverAppBar(
    floating: true,
    pinned: true,
    actions: <IconButton>[
      IconButton(onPressed: () => {}, icon: Icon(Icons.settings_rounded)),
      if (_hive.isSignIn) IconButton(onPressed: _signOut, icon: Icon(Icons.logout_rounded)),
    ],
    title: Text(AppStrings.home),
  );

  Widget _buildAppBar1() => SliverAppBar(
    floating: true,
    pinned: true,
    snap: false,
    actions: <Widget>[
      IconButton(onPressed: () {}, icon: Icon(Icons.settings_rounded)),
      if (_hive.isSignIn) IconButton(onPressed: _signOut, icon: Icon(Icons.logout_rounded)),
    ],
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(ResponsiveHelper.getSpacing(context, SizeType.m) * 3 + kProfileImgSizeM + kProfileBarcodeHeight),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, SizeType.xl), vertical: ResponsiveHelper.getSpacing(context, SizeType.m)),
        child: Column(
          spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
          children: <Widget>[
            Row(
              spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
              children: <Widget>[
                GestureDetector(
                  onTap: () => Get.toNamed(_hive.isSignIn ? AppRoutes.profileDetail : AppRoutes.authentication),
                  child: CustomAvatar(defaultSize: kProfileImgSizeM, desktopSize: kProfileImgSizeM, networkImage: ""),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CustomText(
                        _hive.isSignIn ? _hive.memberProfile.value!.name : AppStrings.guest,
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                      if (_hive.isSignIn)
                        CustomText(_hive.memberProfile.value!.memberCode, color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                    ],
                  ),
                ),
              ],
            ),
            if (_hive.isSignIn) _buildBarcode(_hive.memberProfile.value!.memberCode),
          ],
        ),
      ),
    ),
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withAlpha((0.25 * 255).round()), BlendMode.darken),
            image: AssetImage(AppStrings.tmpImgBackground),
          ),
        ),
      ),
    ),
    title: Text(AppStrings.home),
  );

  Widget _buildAppBar2() => SliverAppBar(
    floating: true,
    pinned: true,
    snap: false,
    expandedHeight: kToolbarHeight + ResponsiveHelper.getSpacing(context, SizeType.m) * 3 + kProfileImgSizeM + kProfileBarcodeHeight,
    actions: <Widget>[
      PopupMenuButton<String>(
        icon: const Icon(Icons.language_rounded, color: Colors.white),
        onSelected: (value) {
          // TODO: switch language here
          print("Selected language: $value");
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'en',
            child: Text("English"),
          ),
          const PopupMenuItem(
            value: 'zh',
            child: Text("中文"),
          ),
          const PopupMenuItem(
            value: 'ms',
            child: Text("Bahasa Melayu"),
          ),
        ],
      ),

      IconButton(onPressed: () {}, icon: Icon(Icons.settings_rounded)),
      if (_hive.isSignIn) IconButton(onPressed: _signOut, icon: Icon(Icons.logout_rounded)),
    ],
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black.withAlpha((0.25 * 255).round()), BlendMode.darken),
            image: AssetImage(AppStrings.tmpImgBackground),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, SizeType.xl), vertical: ResponsiveHelper.getSpacing(context, SizeType.m)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
            children: <Widget>[
              Row(
                spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Get.toNamed(_hive.isSignIn ? AppRoutes.profileDetail : AppRoutes.authentication),
                    child: CustomAvatar(defaultSize: kProfileImgSizeM, desktopSize: kProfileImgSizeM, networkImage: ""),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        CustomText(
                          _hive.isSignIn ? _hive.memberProfile.value!.name : AppStrings.guest,
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        if (_hive.isSignIn)
                          CustomText(_hive.memberProfile.value!.memberCode, color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                      ],
                    ),
                  ),
                ],
              ),
              if (_hive.isSignIn) _buildBarcode(_hive.memberProfile.value!.memberCode),
            ],
          ),
        ),
      ),
    ),
    title: Text(AppStrings.home),
  );

  Widget _buildUserInfo() => SliverToBoxAdapter(
    child: CustomBackgroundCard(
      child: Column(
        spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
        children: <Widget>[
          Row(
            spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
            children: <Widget>[
              GestureDetector(
                onTap: () => Get.toNamed(_hive.isSignIn ? AppRoutes.profileDetail : AppRoutes.authentication),
                child: CustomAvatar(defaultSize: kProfileImgSizeM, desktopSize: kProfileImgSizeM, networkImage: ""),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    CustomText(
                      _hive.isSignIn ? _hive.memberProfile.value!.name : AppStrings.guest,
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    if (_hive.isSignIn)
                      CustomText(_hive.memberProfile.value!.memberCode, color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                  ],
                ),
              ),
            ],
          ),
          if (_hive.isSignIn) _buildBarcode(_hive.memberProfile.value!.memberCode),
        ],
      ),
    ),
  );

  Widget _buildBarcode(String memberCode) => Center(
    child: Code(
      drawText: false,
      codeType: CodeType.code39(),
      backgroundColor: Colors.white,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusS), color: Colors.white),
      height: kProfileBarcodeHeight,
      width: kProfileBarcodeWidth,
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
      data: memberCode,
    ),
  );

  Widget _buildSection(String header, List<Widget> children, {bool? isPrimaryContainer = false, VoidCallback? onTap}) => SliverToBoxAdapter(
    child: Container(
      color: isPrimaryContainer! ? Theme.of(context).colorScheme.primaryContainer : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
              children: <Widget>[
                Expanded(child: CustomText(header, fontSize: 16.0, fontWeight: FontWeight.w600)),
                if (onTap != null)
                  GestureDetector(
                    onTap: onTap,
                    child: CustomText("${AppStrings.more} >", color: Colors.blue, fontSize: 14.0, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    ),
  );

  Widget _buildQuickAccess() => Obx(() {
    int memberCount = _memberController.members.length;
    int voucherCount = _memberController.members.fold(0, (sum, item) => sum + (item.normalVoucherCount) + (item.specialVoucherCount));

    return SliverPadding(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: kQuickAccessRatio,
          crossAxisSpacing: ResponsiveHelper.getSpacing(context, SizeType.m),
          mainAxisSpacing: ResponsiveHelper.getSpacing(context, SizeType.m),
          crossAxisCount: ResponsiveHelper.getHomeQuickAccessCount(context),
        ),
        delegate: SliverChildListDelegate([
          CustomImageTextButton(
            isCountVisible: true,
            count: voucherCount,
            assetName: AppStrings.tmpIconMyVoucher,
            label: AppStrings.myVouchers,
            onTap: () async {
              await Get.toNamed(AppRoutes.voucherList, arguments: {"check_start": 0, "member_code": _hive.memberProfile.value!.memberCode});

              _onRefresh();
            },
          ),
          CustomImageTextButton(
            isCountVisible: true,
            count: memberCount,
            assetName: AppStrings.tmpIconMyMember,
            label: AppStrings.myCards,
            onTap: () async {
              await Get.toNamed(AppRoutes.memberList, arguments: {"member_code": _hive.memberProfile.value!.memberCode});

              _onRefresh();
            },
          ),
          CustomImageTextButton(
            assetName: AppStrings.tmpIconHistory,
            label: AppStrings.history,
            onTap: () async {
              await Get.toNamed(AppRoutes.history, arguments: {"member_code": _hive.memberProfile.value!.memberCode});

              _onRefresh();
            },
          ),
          CustomImageTextButton(assetName: AppStrings.tmpIconReferralProgram, label: AppStrings.referralProgram, onTap: () {}),
          CustomImageTextButton(assetName: AppStrings.tmpIconInvoice, label: AppStrings.eInvoice, onTap: () {}),
        ]),
      ),
    );
  });

  List<Widget> _buildVouchers() => [
    Obx(() {
      if (_voucherController.isLoading.value) {
        return SizedBox(
          height: ResponsiveHelper.getVoucherHeight(context),
          child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
        );
      }

      if (_voucherController.collectableVouchers.isEmpty) {
        return SizedBox(
          height: ResponsiveHelper.getVoucherHeight(context),
          child: Center(child: CustomText(AppStrings.msgNoAvailableVoucher, fontSize: 16.0, maxLines: 2)),
        );
      }

      final vouchers = _voucherController.collectableVouchers;

      return SizedBox(
        height: ResponsiveHelper.getVoucherHeight(context) + ResponsiveHelper.getSpacing(context, SizeType.s),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: vouchers.length,
          separatorBuilder: (_, _) => SizedBox(width: ResponsiveHelper.getSpacing(context, SizeType.m)),
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(
              bottom: ResponsiveHelper.getSpacing(context, SizeType.l),
              left: index == 0 ? ResponsiveHelper.getSpacing(context, SizeType.m) : 0.0,
              right: index == vouchers.length - 1 ? ResponsiveHelper.getSpacing(context, SizeType.m) : 0.0,
            ),
            child: CustomCollectableVoucher(
              onTapCollect: () async {
                await _voucherController.collectVoucher(
                  vouchers[index].batchCode,
                  vouchers[index].companyID,
                  _hive.memberProfile.value!.memberCode,
                  _hive.memberProfile.value!.token,
                );

                _voucherController.loadCollectableVouchers(_hive.memberProfile.value!.memberCode);
              },
              voucher: vouchers[index],
            ),
          ),
        ),
      );
    }),
  ];

  List<Widget> _buildNearby() => [
    Obx(() {
      if (_branchController.isLoading.value || _memberController.isLoading.value) {
        return SizedBox(
          height: ResponsiveHelper.getNearbyHeight(context),
          child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
        );
      }

      if (_branchController.branches.isEmpty) {
        return SizedBox(
          height: ResponsiveHelper.getNearbyHeight(context),
          child: Center(child: CustomText(AppStrings.msgNoAvailableNearby, fontSize: 16.0, maxLines: 2)),
        );
      }

      return SizedBox(
        height: ResponsiveHelper.getNearbyHeight(context) + ResponsiveHelper.getSpacing(context, SizeType.s),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _branchController.branches.length,
          separatorBuilder: (_, _) => SizedBox(width: ResponsiveHelper.getSpacing(context, SizeType.m)),
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(
              bottom: ResponsiveHelper.getSpacing(context, SizeType.l),
              left: index == 0 ? ResponsiveHelper.getSpacing(context, SizeType.m) : 0.0,
              right: index == _branchController.branches.length - 1 ? ResponsiveHelper.getSpacing(context, SizeType.m) : 0.0,
            ),
            child: GestureDetector(
              onTap: () async {
                await Get.toNamed(AppRoutes.branchDetail, arguments: {"branch": _branchController.branches[index]});

                _onRefresh();
              },
              child: CustomNearbyCard(branch: _branchController.branches[index], members: _memberController.membersCheckStart),
            ),
          ),
        ),
      );
    }),
  ];

  List<Widget> _buildPromotions() => [
    Obx(() {
      if (_promoController.isLoading.value) {
        return SizedBox(
          height: ResponsiveHelper.getPromoAdsHeight(context),
          child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
        );
      }

      if (_promoController.promotions.isEmpty) {
        return SizedBox(
          height: ResponsiveHelper.getPromoAdsHeight(context),
          child: Center(child: CustomText(AppStrings.msgNoAvailablePromo, fontSize: 16.0, maxLines: 2)),
        );
      }

      return SizedBox(
        height: ResponsiveHelper.getPromoAdsHeight(context),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _promoController.promotions.length,
          separatorBuilder: (_, _) => SizedBox(width: ResponsiveHelper.getSpacing(context, SizeType.m)),
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(
              bottom: ResponsiveHelper.getSpacing(context, SizeType.l),
              left: index == 0 ? ResponsiveHelper.getSpacing(context, SizeType.m) : 0.0,
              right: index == _promoController.promotions.length - 1 ? ResponsiveHelper.getSpacing(context, SizeType.m) : 0.0,
            ),
            child: CustomPromotionCard(promotion: _promoController.promotions[index]),
          ),
        ),
      );
    }),
  ];

  List<Widget> _buildAdvertisements() => [
    Obx(() {
      if (_adsController.isLoading.value) {
        return SizedBox(
          height: ResponsiveHelper.getPromoAdsHeight(context),
          child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
        );
      }

      if (_adsController.advertisements.isEmpty) {
        return SizedBox(
          height: ResponsiveHelper.getPromoAdsHeight(context),
          child: Center(child: CustomText(AppStrings.msgNoAvailableAds, fontSize: 16.0, maxLines: 2)),
        );
      }

      return SizedBox(
        height: ResponsiveHelper.getPromoAdsHeight(context),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _adsController.advertisements.length,
          separatorBuilder: (_, _) => SizedBox(width: ResponsiveHelper.getSpacing(context, SizeType.m)),
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(
              bottom: ResponsiveHelper.getSpacing(context, SizeType.l),
              left: index == 0 ? ResponsiveHelper.getSpacing(context, SizeType.m) : 0.0,
              right: index == _adsController.advertisements.length - 1 ? ResponsiveHelper.getSpacing(context, SizeType.m) : 0.0,
            ),
            child: CustomAdvertisementCard(advertisement: _adsController.advertisements[index]),
          ),
        ),
      );
    }),
  ];

  Widget _buildTimeline() => Obx(() {
    if (_timelineController.isLoading.value) {
      return SliverFillRemaining(
        child: SizedBox(
          child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
        ),
      );
    }

    if (_timelineController.timelines.isEmpty) {
      return SliverFillRemaining(
        child: SizedBox(child: Center(child: CustomText(AppStrings.msgNoAvailableTimeline, fontSize: 16.0, maxLines: 2))),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context, SizeType.l)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getSpacing(context, SizeType.m),
                vertical: ResponsiveHelper.getSpacing(context, SizeType.l),
              ),
              child: CustomText(AppStrings.whatNew, color: Theme.of(context).colorScheme.primary, fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _timelineController.timelines.length,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (_, _) => Divider(color: Colors.grey.withAlpha((0.7 * 255).round()), height: 30.0, thickness: 5.0),
              itemBuilder: (context, index) => CustomTimeline(branch: _branchController.branches[0], timeline: _timelineController.timelines[index]),
            ),
          ],
        ),
      ),
    );
  });
}
