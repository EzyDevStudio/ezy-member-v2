import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/controllers/member_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/timeline_controller.dart';
import 'package:ezy_member_v2/helpers/location_helper.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/branch_model.dart';
import 'package:ezy_member_v2/models/member_model.dart';
import 'package:ezy_member_v2/widgets/custom_avatar.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:ezy_member_v2/widgets/custom_card.dart';
import 'package:ezy_member_v2/widgets/custom_chip.dart';
import 'package:ezy_member_v2/widgets/custom_list_tile.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:ezy_member_v2/widgets/custom_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BranchDetailScreen extends StatefulWidget {
  const BranchDetailScreen({super.key});

  @override
  State<BranchDetailScreen> createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends State<BranchDetailScreen> {
  final _memberController = Get.put(MemberController(), tag: "branchDetail");
  final _timelineController = Get.put(TimelineController(), tag: "branchDetail");
  final _hive = Get.find<MemberHiveController>();

  late BranchModel _branch;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    _branch = Get.arguments["branch"];

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    _timelineController.loadTimelines(companyID: _branch.company.companyID);

    await _hive.loadMemberHive();

    if (_hive.isSignIn) _memberController.loadMembersCheckStart(_hive.memberProfile.value!.memberCode);
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
  Widget build(BuildContext context) =>
      Scaffold(body: CustomScrollView(slivers: <Widget>[_buildAppBar(), _buildBranchHeader(), _buildBranchInfo(), _buildTimeline()]));

  Widget _buildAppBar() => SliverAppBar(
    floating: true,
    pinned: true,
    actions: <IconButton>[IconButton(onPressed: () {}, icon: Icon(Icons.share_rounded))],
    title: SizedBox(
      height: kToolbarHeight * kAppBarLogoRatio,
      child: Image.asset(AppStrings.tmpImgAppLogo, fit: BoxFit.fitHeight, color: Colors.white),
    ),
  );

  Widget _buildBranchHeader() => SliverToBoxAdapter(
    child: CustomBackgroundCard(
      child: Column(
        spacing: ResponsiveHelper.getSpacing(context, SizeType.l),
        children: <Widget>[
          Row(
            spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
            children: <Widget>[
              CustomAvatar(defaultSize: kProfileImgSizeM, desktopSize: kProfileImgSizeM, networkImage: _branch.aboutUs.companyLogo),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    CustomText(_branch.branchName, color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
                    CustomText(_branch.contactNumber, color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                  ],
                ),
              ),
            ],
          ),
          _buildBenefits(),
        ],
      ),
    ),
  );

  Widget _buildBenefits() => Obx(() {
    MemberModel member = _memberController.membersCheckStart.isNotEmpty ? _memberController.membersCheckStart[0] : MemberModel.empty();

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusM)), color: Colors.white),
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
        children: <Widget>[
          CustomText(AppStrings.memberBenefits, color: Theme.of(context).colorScheme.primary, fontSize: 16.0, fontWeight: FontWeight.bold),
          SizedBox(
            height: ResponsiveHelper.isDesktop(context) ? 150.0 : 100.0,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CustomImageTextButton(
                    assetName: AppStrings.tmpIconMyPoints,
                    label: member.isMember ? AppStrings.myPoints : AppStrings.earnPoints,
                    content: member.isMember ? member.point.toString() : null,
                    onTap: member.isMember
                        ? () async {
                            await Get.toNamed(
                              AppRoutes.payment,
                              arguments: {"scan_type": ScanType.point, "value": _hive.memberProfile.value!.memberCode},
                            );

                            _onRefresh();
                          }
                        : null,
                  ),
                ),
                Expanded(
                  child: CustomImageTextButton(
                    assetName: AppStrings.tmpIconMyVoucher,
                    label: member.isMember ? AppStrings.myVouchers : AppStrings.collectVouchers,
                    content: member.isMember ? (member.normalVoucherCount + member.specialVoucherCount).toString() : null,
                    onTap: member.isMember && _hive.memberProfile.value != null
                        ? () async {
                            await Get.toNamed(
                              AppRoutes.voucherList,
                              arguments: {
                                "check_start": 1,
                                "company_id": _branch.company.companyID,
                                "member_code": _hive.memberProfile.value!.memberCode,
                              },
                            );

                            _onRefresh();
                          }
                        : null,
                  ),
                ),
                Expanded(
                  child: CustomImageTextButton(
                    assetName: AppStrings.tmpIconMyCredits,
                    label: member.isMember ? AppStrings.myCredits : AppStrings.redeemByCredits,
                    content: member.isMember ? member.credit.toStringAsFixed(1) : null,
                    onTap: member.isMember
                        ? () async {
                            await Get.toNamed(
                              AppRoutes.payment,
                              arguments: {"scan_type": ScanType.credit, "value": _hive.memberProfile.value!.memberCode},
                            );

                            _onRefresh();
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
          if (!member.isMember) CustomFilledButton(label: AppStrings.joinNow, onTap: () {}),
        ],
      ),
    );
  });

  Widget _buildBranchInfo() => SliverToBoxAdapter(
    child: Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 1.0,
      child: ExpansionTile(
        tilePadding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
        onExpansionChanged: (isExpanded) => setState(() => _isExpanded = isExpanded),
        title: CustomText(AppStrings.aboutUs, fontSize: 18.0, fontWeight: FontWeight.bold),
        trailing: CustomText(
          _isExpanded ? AppStrings.less : AppStrings.more,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: 16.0,
        ),
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
  );

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
              itemBuilder: (context, index) => CustomTimeline(branch: _branch, timeline: _timelineController.timelines[index]),
            ),
          ],
        ),
      ),
    );
  });
}
