import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/controllers/advertisement_controller.dart';
import 'package:ezy_member_v2/controllers/member_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/promotion_controller.dart';
import 'package:ezy_member_v2/helpers/location_helper.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/branch_model.dart';
import 'package:ezy_member_v2/models/member_model.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:ezy_member_v2/widgets/custom_carousel.dart';
import 'package:ezy_member_v2/widgets/custom_chip.dart';
import 'package:ezy_member_v2/widgets/custom_list_tile.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BranchDetailScreen extends StatefulWidget {
  const BranchDetailScreen({super.key});

  @override
  State<BranchDetailScreen> createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends State<BranchDetailScreen> {
  final _adsController = Get.find<AdvertisementController>();
  final _memberController = Get.find<MemberController>();
  final _memberHiveController = Get.find<MemberHiveController>();
  final _promoController = Get.find<PromotionController>();

  late BranchModel _branch;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _branch = Get.arguments["branch"];

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    _adsController.loadAdvertisements(company: _branch.company);
    _promoController.loadPromotions(company: _branch.company);
    await _memberHiveController.loadMemberHive();
    if (_memberHiveController.isSignIn) {
      _memberController.loadMembersCheckStart(_memberHiveController.memberProfile.value!.memberCode);
    }
  }

  Future<void> _redirectGoogleMap(String fullAddress) async {
    MessageHelper.showDialog(type: DialogType.loading, title: AppStrings.redirecting, message: AppStrings.msgGoogleMapRedirecting);

    Coordinate? current = await LocationHelper.getCurrentCoordinate();
    Coordinate? target = await LocationHelper.getCoordinate(fullAddress);

    if (current == null || target == null) return;

    await LocationHelper.navigateToGoogleMap(
      targetLat: target.latitude,
      targetLong: target.longitude,
      originLat: current.latitude,
      originLong: current.longitude,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: <Widget>[
        _buildAppBar(),
        _buildBranchInfo(),
        _buildBenefits(),
        SliverToBoxAdapter(child: _buildPromotions()),
        SliverToBoxAdapter(child: _buildTimeline()),
        SliverToBoxAdapter(child: _buildAdvertisements()),
      ],
    ),
  );

  Widget _buildAppBar() => SliverAppBar(
    floating: true,
    pinned: true,
    actions: <IconButton>[IconButton(onPressed: () => {}, icon: Icon(Icons.share_rounded))],
    title: SizedBox(
      height: kToolbarHeight * kAppBarLogoRatio,
      child: Image.asset(AppStrings.tmpImgAppLogo, fit: BoxFit.fitHeight, color: Colors.white),
    ),
  );

  Widget _buildBranchInfo() => SliverToBoxAdapter(
    child: Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.25 * 255).round()),
        image: DecorationImage(
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withAlpha((0.25 * 255).round()), BlendMode.darken),
          image: AssetImage(AppStrings.tmpImgBackground),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getSpacing(context, SizeType.m),
            vertical: ResponsiveHelper.getSpacing(context, SizeType.xl),
          ),
          onExpansionChanged: (isExpanded) => setState(() => _isExpanded = isExpanded),
          leading: ClipOval(
            child: Image.network(
              _branch.aboutUs.companyLogo,
              fit: BoxFit.cover,
              height: ResponsiveHelper.getVoucherImgSize(context),
              width: ResponsiveHelper.getVoucherImgSize(context),
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return Center(
                  child: Icon(Icons.broken_image_rounded, color: Colors.grey, size: ResponsiveHelper.getVoucherImgSize(context)),
                );
              },
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;

                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              },
            ),
          ),
          title: CustomText(_branch.branchName, color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
          trailing: CustomText(_isExpanded ? AppStrings.less : AppStrings.more, color: Colors.blue, fontSize: 18.0, fontWeight: FontWeight.bold),
          children: <Widget>[
            CustomInfoListTile(
              icon: Icons.location_on_rounded,
              title: _branch.fullAddress,
              subtitle: AppStrings.msgGoogleMapTap,
              onTap: () => _redirectGoogleMap(_branch.fullAddress),
            ),
            CustomInfoListTile(
              icon: Icons.category_rounded,
              title: AppStrings.categories,
              subWidget: Padding(
                padding: EdgeInsets.only(top: ResponsiveHelper.getSpacing(context, SizeType.xs)),
                child: Wrap(
                  runSpacing: ResponsiveHelper.getSpacing(context, SizeType.s),
                  spacing: ResponsiveHelper.getSpacing(context, SizeType.s),
                  children: _branch.company.categories.map((category) {
                    return CustomLabelChip(
                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((0.2 * 255).round()),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      foregroundSize: 12.0,
                      label: category.categoryTitle,
                    );
                  }).toList(),
                ),
              ),
            ),
            CustomInfoListTile(icon: Icons.account_box_rounded, title: AppStrings.aboutUs, subtitle: _branch.branchDescription),
            CustomInfoListTile(icon: Icons.email_rounded, title: AppStrings.email, subtitle: _branch.subCompany.companyEmail),
            CustomInfoListTile(icon: Icons.phone_rounded, title: AppStrings.phone, subtitle: _branch.contactNumber),
          ],
        ),
      ),
    ),
  );

  Widget _buildBenefits() => Obx(() {
    MemberModel member = _memberController.membersCheckStart[0];

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.l)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
          children: <Widget>[
            CustomText(AppStrings.memberBenefits, color: Theme.of(context).colorScheme.primary, fontSize: 16.0, fontWeight: FontWeight.bold),
            SizedBox(
              height: 100.0,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: CustomImageTextButton(
                      isCountVisible: member.isMember,
                      count: member.point,
                      assetName: AppStrings.tmpIconMyPoints,
                      label: member.isMember ? AppStrings.myPoints : AppStrings.earnPoints,
                      onTap: member.isMember ? () {} : null,
                    ),
                  ),
                  Expanded(
                    child: CustomImageTextButton(
                      isCountVisible: member.isMember,
                      count: (member.normalVoucherCount + member.specialVoucherCount),
                      assetName: AppStrings.tmpIconMyVoucher,
                      label: member.isMember ? AppStrings.myVouchers : AppStrings.collectVouchers,
                      onTap: member.isMember && _memberHiveController.memberProfile.value != null
                          ? () async {
                              await Get.toNamed(
                                AppRoutes.voucherList,
                                arguments: {
                                  "getAll": false,
                                  "companies": [_branch.company],
                                  "memberCode": _memberHiveController.memberProfile.value!.memberCode,
                                },
                              );

                              _onRefresh();
                            }
                          : null,
                    ),
                  ),
                  Expanded(
                    child: CustomImageTextButton(
                      isCountVisible: member.isMember,
                      count: member.credit.round(),
                      assetName: AppStrings.tmpIconMyCredits,
                      label: member.isMember ? AppStrings.myCredits : AppStrings.redeemByCredits,
                      onTap: member.isMember ? () {} : null,
                    ),
                  ),
                ],
              ),
            ),
            if (!member.isMember) CustomFilledButton(label: AppStrings.joinNow, onTap: () {}),
          ],
        ),
      ),
    );
  });

  Widget _buildPromotions() => Obx(() {
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
      child: CustomPromoCarousel(promotions: _promoController.promotions),
    );
  });

  Widget _buildTimeline() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: ResponsiveHelper.getSpacing(context, SizeType.l)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, SizeType.s)),
            child: CustomText("What's New", color: Theme.of(context).colorScheme.primary, fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: ResponsiveHelper.getSpacing(context, SizeType.m)),
            itemCount: 5,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => Divider(color: Colors.grey.withAlpha((0.3 * 255).round()), thickness: kBorderWidth),
            itemBuilder: (context, index) => _buildTimelineItem(index),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertisements() => Obx(() {
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
      child: CustomAdsCarousel(advertisements: _adsController.advertisements),
    );
  });

  Widget _buildTimelineItem(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6.0,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, SizeType.s)),
          child: CustomText("Branch Update #${index + 1}", fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, SizeType.s)),
          child: CustomText("This is a sample update description for the timeline item number ${index + 1}.", fontSize: 14.0, maxLines: 3),
        ),
        const SizedBox(),
        Image.asset(
          (index % 2 == 0) ? AppStrings.tmpImgBackground : AppStrings.tmpImgAppLogo,
          fit: (index % 2 == 0) ? BoxFit.cover : BoxFit.contain,
          height: 300.0,
          width: double.infinity,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, SizeType.s)),
          child: CustomText("${index + 1} hours ago", fontSize: 12.0, color: Colors.grey),
        ),
      ],
    );
  }
}
