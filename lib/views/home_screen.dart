import 'dart:async';

import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/controllers/authentication_controller.dart';
import 'package:ezymember/controllers/settings_controller.dart';
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
import 'package:ezymember/widgets/custom_chip.dart';
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
  final _authController = Get.put(AuthenticationController());
  final _timelineController = Get.put(TimelineController(), tag: "home");
  final _voucherController = Get.put(VoucherController(), tag: "home");
  final _scrollController = ScrollController();

  // late StreamSubscription<bool> _subscription;

  bool _showFab = false;
  double _appBarHeight = 300.0;
  double _serviceHeight = 80.0;

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
            CustomText(Globalization.myCode.tr, fontSize: 22.0, fontWeight: FontWeight.bold),
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
                          CustomText(_hive.memberProfile.value!.memberCode, color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
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

  Widget _buildMobile() => ListView(
    children: <Widget>[
      Column(spacing: 10.0, children: <Widget>[_buildAppBar(), _buildVoucherCard(), _buildTimeline()]),
    ],
  );

  Widget _buildAppBar() => SizedBox(
    height: _appBarHeight,
    child: Stack(
      children: <Widget>[
        CustomBackgroundImage(backgroundImage: "", cacheImage: _hive.backgroundImage),
        Column(
          children: <Widget>[
            Expanded(child: SizedBox()),
            SizedBox(
              height: _serviceHeight,
              child: Column(
                children: <Widget>[
                  Expanded(child: SizedBox()),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15.dp)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
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
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(15.dp),
                    child: Row(
                      spacing: 15.dp,
                      children: <Widget>[
                        CustomAvatarImage(
                          showEdit: _hive.isSignIn,
                          size: kProfileImgSizeM,
                          cacheImage: _hive.image,
                          onTap: () => Get.toNamed(_hive.isSignIn ? AppRoutes.profileDetail : AppRoutes.signIn),
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
                  ),
                ],
              ),
            ),
            SizedBox(
              height: _serviceHeight,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.dp),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.dp),
                  boxShadow: <BoxShadow>[BoxShadow(color: Color(0x0D000000), blurRadius: 10.0, offset: Offset(0.0, 0.4))],
                ),
                child: GridView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(5.dp),
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 10.dp,
                    mainAxisExtent: _serviceHeight - (5.dp * 2),
                    mainAxisSpacing: 10.dp,
                    crossAxisCount: 4,
                  ),
                  children: <Widget>[
                    if (_hive.isSignIn) ...[
                      _buildServiceButton(
                        "assets/icons/my_vouchers.png",
                        Globalization.myVouchers.tr,
                        () => Get.toNamed(AppRoutes.voucherList, arguments: {"check_start": 0}),
                      ),
                      _buildServiceButton("assets/icons/my_members.png", Globalization.myCards.tr, () => Get.toNamed(AppRoutes.memberList)),
                      _buildServiceButton("assets/icons/invoice.png", Globalization.eInvoice.tr, () => Get.toNamed(AppRoutes.invoice)),
                    ],
                    _buildServiceButton("assets/icons/find_shops.png", "Business Nearby", () => Get.toNamed(AppRoutes.companyList)),
                    // CustomImageTextButton(
                    //   isCountVisible: true,
                    //   count: _voucherController.redeemedCount.value,
                    //   assetName: "assets/icons/my_vouchers.png",
                    //   label: Globalization.myVouchers.tr,
                    //   onTap: () => Get.toNamed(AppRoutes.voucherList, arguments: {"check_start": 0}),
                    // ),
                    // CustomImageTextButton(
                    //   isCountVisible: true,
                    //   count: _voucherController.memberCount.value,
                    //   assetName: "assets/icons/my_members.png",
                    //   label: Globalization.myCards.tr,
                    //   onTap: () => Get.toNamed(AppRoutes.memberList),
                    // ),
                    // CustomImageTextButton(
                    //   assetName: "assets/icons/invoice.png",
                    //   label: Globalization.eInvoice.tr,
                    //   onTap: () => Get.toNamed(AppRoutes.invoice),
                    // ),
                    // CustomImageTextButton(
                    //   assetName: "assets/icons/find_shops.png",
                    //   label: Globalization.findShop.tr,
                    //   onTap: () => Get.toNamed(AppRoutes.companyList),
                    // ),
                    // if (_hive.isSignIn)
                    // CustomImageTextButton(assetName: "assets/icons/scan.png", label: Globalization.myCode.tr, onTap: _showMemberCode),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildServiceButton(String assetName, String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Column(
      spacing: 5.0,
      children: <Widget>[
        Expanded(child: Image.asset(assetName, scale: kSquareRatio)),
        CustomText(label, fontSize: 12.0),
      ],
    ),
  );

  Widget _buildVoucherCard() => Container(
    height: 150.0,
    margin: EdgeInsets.symmetric(horizontal: 20.dp),
    padding: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 5.dp),
    decoration: BoxDecoration(
      color: Color(0xFFFAD117),
      borderRadius: BorderRadius.circular(10.dp),
      boxShadow: <BoxShadow>[BoxShadow(color: Color(0x0D000000), blurRadius: 10.0, offset: Offset(0.0, 0.4))],
    ),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CustomText("There are vouchers for you", fontSize: 24.0, maxLines: null, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
              CustomLabelChip(backgroundColor: Colors.white.withValues(alpha: 0.6), foregroundColor: Colors.black, label: "COLLECT >>"),
              // CustomText("COLLECT >>", fontSize: 16.0, maxLines: null),
            ],
          ),
        ),
        Image.asset("assets/images/collect_voucher.png", scale: kSquareRatio),
      ],
    ),
  );

  // Widget _buildMobile() => Obx(
  //   () => CustomScrollView(
  //     controller: _scrollController,
  //     physics: const AlwaysScrollableScrollPhysics(),
  //     slivers: <Widget>[
  //       _buildAppBar(),
  //       _buildQuickAccess(),
  //       SliverToBoxAdapter(child: _buildVouchers()),
  //       SliverToBoxAdapter(child: _buildTimeline()),
  //     ],
  //   ),
  // );
  //
  // Widget _buildAppBar() => CustomAppBar(
  //   isLeading: false,
  //   cacheAvatar: _hive.image,
  //   cacheBackground: _hive.backgroundImage,
  //   actions: _buildAppBarAction(),
  //   onTap: () => Get.toNamed(_hive.isSignIn ? AppRoutes.profileDetail : AppRoutes.signIn),
  //   child: Expanded(
  //     child: Row(
  //       spacing: 16.dp,
  //       children: <Widget>[
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: <Widget>[
  //               CustomText(
  //                 _hive.isSignIn ? _hive.memberProfile.value!.name : Globalization.guest.tr,
  //                 color: Colors.white,
  //                 fontSize: 24.0,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //               if (_hive.isSignIn)
  //                 CustomText(_hive.memberProfile.value!.memberCode, color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
  //             ],
  //           ),
  //         ),
  //         Obx(() {
  //           int totalCount = _voucherController.redeemableCount.value + _voucherController.todayCount.value;
  //
  //           if (!_hive.isSignIn || totalCount <= 0) return SizedBox.shrink();
  //
  //           return IconButton(
  //             onPressed: () => Get.toNamed(AppRoutes.notification),
  //             icon: Badge.count(
  //               count: totalCount,
  //               child: Icon(Icons.notifications_rounded, color: Colors.white, size: 40.0),
  //             ),
  //           );
  //         }),
  //       ],
  //     ),
  //   ),
  // );
  //
  // List<Widget> _buildAppBarAction() => [
  //   PopupMenuButton<Locale>(
  //     onSelected: (locale) => _settingsController.changeLanguage(locale),
  //     itemBuilder: (context) => Globalization.languages.entries
  //         .map((entry) => PopupMenuItem<Locale>(value: entry.value, child: CustomText(entry.key, fontSize: 14.0)))
  //         .toList(),
  //     icon: Icon(Icons.language_rounded, color: Colors.white),
  //   ),
  //   if (_hive.isSignIn)
  //     IconButton(
  //       onPressed: _signOut,
  //       icon: Icon(Icons.logout_rounded, color: Colors.white),
  //     ),
  // ];
  //
  // Widget _buildQuickAccess() => Obx(
  //   () => SliverToBoxAdapter(
  //     child: Container(
  //       color: Colors.white,
  //       child: Column(
  //         children: <Widget>[
  //           GridView(
  //             shrinkWrap: true,
  //             padding: EdgeInsets.symmetric(horizontal: 8.dp, vertical: 8.dp),
  //             physics: const NeverScrollableScrollPhysics(),
  //             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //               crossAxisSpacing: 16.dp,
  //               mainAxisExtent: rsp.quickHeight(),
  //               mainAxisSpacing: 16.dp,
  //               crossAxisCount: 4,
  //             ),
  //             children: <Widget>[
  //               // if (_hive.isSignIn)
  //               //   CustomImageTextButton(
  //               //     isCountVisible: true,
  //               //     count: _voucherController.redeemedCount.value,
  //               //     assetName: "assets/icons/my_vouchers.png",
  //               //     label: Globalization.myVouchers.tr,
  //               //     onTap: () => Get.toNamed(AppRoutes.voucherList, arguments: {"check_start": 0}),
  //               //   ),
  //               if (_hive.isSignIn)
  //                 CustomImageTextButton(
  //                   isCountVisible: true,
  //                   count: _voucherController.memberCount.value,
  //                   assetName: "assets/icons/my_members.png",
  //                   label: Globalization.myCards.tr,
  //                   onTap: () => Get.toNamed(AppRoutes.memberList),
  //                 ),
  //               if (_hive.isSignIn)
  //                 CustomImageTextButton(
  //                   assetName: "assets/icons/invoice.png",
  //                   label: Globalization.eInvoice.tr,
  //                   onTap: () => Get.toNamed(AppRoutes.invoice),
  //                 ),
  //               CustomImageTextButton(
  //                 assetName: "assets/icons/find_shops.png",
  //                 label: Globalization.findShop.tr,
  //                 onTap: () => Get.toNamed(AppRoutes.companyList),
  //               ),
  //               if (_hive.isSignIn) CustomImageTextButton(assetName: "assets/icons/scan.png", label: Globalization.myCode.tr, onTap: _showMemberCode),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   ),
  // );
  //
  // Widget _buildVouchers() => Obx(() {
  //   if (_voucherController.vouchers.isEmpty) {
  //     // return Divider(color: Colors.grey.withValues(alpha: 0.7), thickness: 5.dp);
  //     return SizedBox(height: 5.dp,);
  //   }
  //
  //   final vouchers = _voucherController.vouchers;
  //
  //   return ClipRRect(
  //     borderRadius: BorderRadius.zero,
  //     child: Column(
  //       children: <Widget>[
  //         // Container(
  //         //   decoration: BoxDecoration(
  //         //     boxShadow: <BoxShadow>[
  //         //       BoxShadow(color: Colors.black12, blurRadius: 2.0, spreadRadius: 6.0),
  //         //       BoxShadow(color: Colors.black12, blurRadius: 5.0, spreadRadius: 12.0),
  //         //     ],
  //         //   ),
  //         // ),
  //         Container(
  //           color: Theme.of(context).colorScheme.surface,
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: <Widget>[
  //               Padding(
  //                 padding: EdgeInsets.fromLTRB(16.dp, 8.dp, 16.dp, 8.dp),
  //                 child: CustomText(Globalization.vouchers.tr, fontSize: 16.0, fontWeight: FontWeight.w600),
  //               ),
  //               SizedBox(
  //                 height: rsp.voucherHeight(),
  //                 child: ListView.separated(
  //                   scrollDirection: Axis.horizontal,
  //                   itemCount: vouchers.length,
  //                   separatorBuilder: (_, _) => SizedBox(width: 16.dp),
  //                   itemBuilder: (context, index) => Padding(
  //                     padding: EdgeInsets.only(bottom: 16.dp, left: index == 0 ? 16.dp : 0.0, right: index == vouchers.length - 1 ? 16.dp : 0.0),
  //                     child: CustomVoucher(
  //                       shadowColor: Colors.black54,
  //                       voucher: vouchers[index],
  //                       type: VoucherType.collectable,
  //                       onTapCollect: () async => _voucherController.collectVoucher(
  //                         vouchers[index].batchCode,
  //                         vouchers[index].companyID,
  //                         _hive.memberProfile.value!.memberCode,
  //                         _hive.memberProfile.value!.token,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         // Container(
  //         //   decoration: BoxDecoration(
  //         //     boxShadow: <BoxShadow>[
  //         //       BoxShadow(color: Colors.black12, blurRadius: 2.0, spreadRadius: 6.0),
  //         //       BoxShadow(color: Colors.black12, blurRadius: 5.0, spreadRadius: 12.0),
  //         //     ],
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // });
  //
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
      separatorBuilder: (context, index) => SizedBox(height: 5.dp),
      itemBuilder: (context, index) {
        if (index == timelines.length - 1 && _timelineController.hasMore && !_timelineController.isLoading.value) {
          _timelineController.loadTimelines(isLoadMore: true);
        }

        return Container(
          color: Colors.white,
          child: CustomTimeline(timeline: timelines[index], isNavigateCompany: true, isNavigateTimeline: true),
        );
      },
    );
  });
}
