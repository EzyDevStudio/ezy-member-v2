import 'dart:async';

import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/controllers/advertisement_controller.dart';
import 'package:ezy_member_v2/controllers/branch_controller.dart';
import 'package:ezy_member_v2/controllers/settings_controller.dart';
import 'package:ezy_member_v2/controllers/member_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/promotion_controller.dart';
import 'package:ezy_member_v2/controllers/timeline_controller.dart';
import 'package:ezy_member_v2/controllers/voucher_controller.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/helpers/permission_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/branch_model.dart';
import 'package:ezy_member_v2/services/local/connection_service.dart';
import 'package:ezy_member_v2/services/local/notification_service.dart';
import 'package:ezy_member_v2/translations/translations.dart';
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
  final _timelineController = Get.put(TimelineController(), tag: "home");
  final _voucherController = Get.put(VoucherController(), tag: "home");

  final _settingsController = Get.find<SettingsController>();
  final _hive = Get.find<MemberHiveController>();

  late StreamSubscription<bool> _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = ConnectionService.instance.stream.listen((connected) {
      if (!connected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          MessageHelper.show(
            "msg_connection_off".tr,
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: Duration(seconds: 10),
            icon: Icons.wifi_off_rounded,
          );
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    await PermissionHelper.checkAndRequestLocation();

    if (await PermissionHelper.checkAndRequestNotification()) {
      await NotificationService.show(id: 0, title: "EzyMember", body: "2 vouchers will be expired by today.");
    }

    _adsController.loadAdvertisements();
    _branchController.loadBranches(true);
    _promoController.loadPromotions();
    _timelineController.loadTimelines();

    if (_hive.isSignIn) {
      _voucherController.loadCollectableVouchers(_hive.memberProfile.value!.memberCode);
      _memberController.loadMembers(_hive.memberProfile.value!.memberCode);
      _memberController.loadMembersCheckStart(_hive.memberProfile.value!.memberCode);
    }
  }

  void _signOut() async {
    final bool? result = await CustomConfirmationDialog.show(
      context,
      backgroundColor: Colors.red,
      icon: Icons.warning_rounded,
      message: "msg_sign_out_confirmation".tr,
      title: "sign_out".tr,
    );

    if (result == true) {
      _hive.signOut();
      _memberController.membersCheckStart.value = [];
    }
  }

  double _calculateAppBarHeight() {
    if (_hive.isSignIn) return kToolbarHeight + ResponsiveHelper.getSpacing(context, SizeType.m) * 3 + kProfileImgSizeM + kProfileBarcodeHeight;

    return kToolbarHeight + ResponsiveHelper.getSpacing(context, SizeType.m) * 2 + kProfileImgSizeM;
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
            _buildAppBar(),
            if (_hive.isSignIn) ...[_buildVouchers(), _buildQuickAccess()],
            _buildSection("shops_nearby".tr, _buildNearby(), onTap: () {}, isPrimaryContainer: true),
            // _buildSection("promotions".tr, _buildPromotions(), isPrimaryContainer: true),
            // _buildSection("advertisements".tr, _buildAdvertisements()),
            _buildTimeline(),
          ],
        ),
      ),
    ),
  );

  Widget _buildAppBar() => SliverAppBar(
    floating: true,
    pinned: true,
    snap: false,
    actions: _buildAppBarAction(),
    expandedHeight: _calculateAppBarHeight(),
    bottom: _hive.isSignIn
        ? PreferredSize(
            preferredSize: Size.fromHeight(ResponsiveHelper.getSpacing(context, SizeType.m) * 2 + kProfileBarcodeHeight),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
              child: _hive.isSignIn ? _buildBarcode(_hive.memberProfile.value!.memberCode) : SizedBox.shrink(),
            ),
          )
        : null,
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
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, SizeType.m)),
          child: SafeArea(
            child: Column(
              spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
              children: <Widget>[
                Container(height: kToolbarHeight),
                Row(
                  spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => Get.toNamed(_hive.isSignIn ? AppRoutes.profileDetail : AppRoutes.authentication),
                      child: CustomAvatar(size: kProfileImgSizeM, networkImage: ""),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CustomText(
                            _hive.isSignIn ? _hive.memberProfile.value!.name : "guest".tr,
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
              ],
            ),
          ),
        ),
      ),
    ),
    title: Text("home".tr),
  );

  List<Widget> _buildAppBarAction() => [
    PopupMenuButton<String>(
      onSelected: (value) => _settingsController.changeLanguage(value),
      itemBuilder: (context) => AppTranslations.languages.keys.map((langCode) {
        String languageName = AppTranslations.languages[langCode] ?? "";

        return PopupMenuItem<String>(value: langCode, child: CustomText(languageName, fontSize: 14.0));
      }).toList(),
      icon: const Icon(Icons.language_rounded, color: Colors.white),
    ),
    if (_hive.isSignIn) IconButton(onPressed: _signOut, icon: Icon(Icons.logout_rounded)),
  ];

  Widget _buildBarcode(String memberCode) => ConstrainedBox(
    constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
    child: Code(
      drawText: false,
      codeType: CodeType.code39(),
      backgroundColor: Colors.white,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusS), color: Colors.white),
      height: kProfileBarcodeHeight,
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
                    child: CustomText("${"more".tr} >", color: Colors.blue, fontSize: 14.0, fontWeight: FontWeight.bold),
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
          crossAxisSpacing: ResponsiveHelper.getSpacing(context, SizeType.m),
          mainAxisExtent: 100.0,
          mainAxisSpacing: ResponsiveHelper.getSpacing(context, SizeType.m),
          crossAxisCount: ResponsiveHelper.getQuickAccessCount(context),
        ),
        delegate: SliverChildListDelegate([
          CustomImageTextButton(
            isCountVisible: true,
            count: voucherCount,
            assetName: AppStrings.tmpIconMyVoucher,
            label: "my_vouchers".tr,
            onTap: () async {
              await Get.toNamed(AppRoutes.voucherList, arguments: {"check_start": 0, "member_code": _hive.memberProfile.value!.memberCode});

              _onRefresh();
            },
          ),
          CustomImageTextButton(
            isCountVisible: true,
            count: memberCount,
            assetName: AppStrings.tmpIconMyMember,
            label: "my_cards".tr,
            onTap: () async {
              await Get.toNamed(AppRoutes.memberList, arguments: {"member_code": _hive.memberProfile.value!.memberCode});

              _onRefresh();
            },
          ),
          CustomImageTextButton(
            assetName: AppStrings.tmpIconHistory,
            label: "history".tr,
            onTap: () async {
              await Get.toNamed(AppRoutes.history, arguments: {"member_code": _hive.memberProfile.value!.memberCode});

              _onRefresh();
            },
          ),
          CustomImageTextButton(assetName: AppStrings.tmpIconReferralProgram, label: "referral_program".tr, onTap: () {}),
          CustomImageTextButton(assetName: AppStrings.tmpIconInvoice, label: "e_invoice".tr, onTap: () {}),
        ]),
      ),
    );
  });

  Widget _buildVouchers() => Obx(() {
    if (_voucherController.collectableVouchers.isEmpty) {
      return SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final vouchers = _voucherController.collectableVouchers;

    return _buildSection("vouchers".tr, [
      SizedBox(
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
            child: CustomVoucher(
              voucher: vouchers[index],
              type: VoucherType.collectable,
              onTapCollect: () async {
                await _voucherController.collectVoucher(
                  vouchers[index].batchCode,
                  vouchers[index].companyID,
                  _hive.memberProfile.value!.memberCode,
                  _hive.memberProfile.value!.token,
                );

                _voucherController.loadCollectableVouchers(_hive.memberProfile.value!.memberCode);
              },
            ),
          ),
        ),
      ),
    ], isPrimaryContainer: true);
  });

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
          child: Center(child: CustomText("msg_no_available".trParams({"label": "shops_nearby".tr.toLowerCase()}), fontSize: 16.0, maxLines: 2)),
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
          child: Center(child: CustomText("msg_no_available".trParams({"label": "promotions".tr.toLowerCase()}), fontSize: 16.0, maxLines: 2)),
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
          child: Center(child: CustomText("msg_no_available".trParams({"label": "advertisements".tr.toLowerCase()}), fontSize: 16.0, maxLines: 2)),
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
    if (_branchController.branches.isEmpty || _timelineController.timelines.isEmpty) {
      return SliverToBoxAdapter(child: SizedBox.shrink());
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
              child: CustomText("what_new".tr, color: Theme.of(context).colorScheme.primary, fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _timelineController.timelines.length,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (_, _) => Divider(color: Colors.grey.withAlpha((0.7 * 255).round()), height: 30.0, thickness: 5.0),
              itemBuilder: (context, index) {
                BranchModel branch = _branchController.branches.firstWhere(
                  (b) => b.company.companyID == _timelineController.timelines[index].companyID,
                  orElse: () => BranchModel.empty(),
                );

                return CustomTimeline(branch: branch, timeline: _timelineController.timelines[index]);
              },
            ),
          ],
        ),
      ),
    );
  });
}
