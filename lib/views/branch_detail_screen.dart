import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/controllers/member_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/timeline_controller.dart';
import 'package:ezy_member_v2/helpers/location_helper.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/branch_model.dart';
import 'package:ezy_member_v2/models/member_model.dart';
import 'package:ezy_member_v2/widgets/custom_image.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:ezy_member_v2/widgets/custom_card.dart';
import 'package:ezy_member_v2/widgets/custom_chip.dart';
import 'package:ezy_member_v2/widgets/custom_list_tile.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:ezy_member_v2/widgets/custom_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class BranchDetailScreen extends StatefulWidget {
  const BranchDetailScreen({super.key});

  @override
  State<BranchDetailScreen> createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends State<BranchDetailScreen> {
  final _hive = Get.find<MemberHiveController>();
  final _memberController = Get.put(MemberController(), tag: "branchDetail");
  final _timelineController = Get.put(TimelineController(), tag: "branchDetail");

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

    if (_hive.isSignIn) _memberController.loadMembers(_hive.memberProfile.value!.memberCode);
  }

  void _shareContent(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    final result = await SharePlus.instance.share(
      ShareParams(
        text:
            "Hey! Join [COMPANY-NAME] as a member using my code [REFERRAL-CODE] and enjoy all the exclusive benefits. https://ezymember.com/COMPANY-NAME/REFERRAL-CODE",
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      ),
    );

    if (result.status == ShareResultStatus.success) {
    } else if (result.status == ShareResultStatus.dismissed) {}
  }

  Future<void> _redirectGoogleMap(String fullAddress) async {
    MessageHelper.showDialog(type: DialogType.loading, title: "redirecting".tr, message: "msg_google_maps_redirecting".tr);

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
  Widget build(BuildContext context) => Scaffold(body: CustomScrollView(slivers: <Widget>[_buildAppBar(), _buildBranchInfo(), _buildTimeline()]));

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: false,
      pinned: true,
      expandedHeight: 300.0,
      actions: [IconButton(onPressed: () => _shareContent(context), icon: Icon(Icons.share_rounded))],
      flexibleSpace: FlexibleSpaceBar(background: CustomBackgroundImage(backgroundImage: _branch.company.categories[0].categoryImage)),
      // flexibleSpace: FlexibleSpaceBar(
      //   background: Container(
      //     decoration: BoxDecoration(
      //       color: Theme.of(context).colorScheme.primary,
      //       image: DecorationImage(
      //         fit: BoxFit.cover,
      //         colorFilter: ColorFilter.mode(Colors.black.withAlpha((0.25 * 255).round()), BlendMode.darken),
      //         image: AssetImage("assets/images/cat_groceries.png"),
      //       ),
      //     ),
      //   ),
      // ),
      bottom: PreferredSize(preferredSize: Size.fromHeight(200.0), child: _buildBenefits()),
    );
  }

  Widget _buildBranchHeader() => Row(
    spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
    children: <Widget>[
      CustomAvatarImage(size: kProfileImgSizeM, networkImage: _branch.aboutUs.companyLogo),
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
  );

  Widget _buildBenefits() => Obx(() {
    MemberModel member = _memberController.members.firstWhere((m) => m.companyID == _branch.company.companyID, orElse: () => MemberModel.empty());

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(kBorderRadiusM)), color: Colors.white),
      margin: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.l)),
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
        children: <Widget>[
          CustomText("member_benefits".tr, color: Theme.of(context).colorScheme.primary, fontSize: 16.0, fontWeight: FontWeight.bold),
          SizedBox(
            height: ResponsiveHelper.isDesktop(context) ? 150.0 : 100.0,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: CustomImageTextButton(
                    assetName: "assets/icons/my_points.png",
                    label: member.isMember ? "my_points".tr : "earn_points".tr,
                    content: member.isMember ? member.point.toString() : null,
                    onTap: member.isMember
                        ? () async {
                            await Get.toNamed(
                              AppRoutes.payment,
                              arguments: {"scan_type": ScanType.point, "value": _hive.memberProfile.value!.memberCode},
                            );
                          }
                        : null,
                  ),
                ),
                Expanded(
                  child: CustomImageTextButton(
                    assetName: "assets/icons/my_vouchers.png",
                    label: member.isMember ? "my_vouchers".tr : "collect_vouchers".tr,
                    content: member.isMember ? (member.normalVoucherCount + member.specialVoucherCount).toString() : null,
                    onTap: member.isMember && _hive.memberProfile.value != null
                        ? () async {
                            await Get.toNamed(AppRoutes.voucherList, arguments: {"check_start": 1, "company_id": _branch.company.companyID});
                          }
                        : null,
                  ),
                ),
                Expanded(
                  child: CustomImageTextButton(
                    assetName: "assets/icons/my_credits.png",
                    label: member.isMember ? "my_credits".tr : "redeem_by_credits".tr,
                    content: member.isMember ? member.credit.toStringAsFixed(1) : null,
                    onTap: member.isMember
                        ? () async {
                            await Get.toNamed(
                              AppRoutes.payment,
                              arguments: {"scan_type": ScanType.credit, "value": _hive.memberProfile.value!.memberCode},
                            );
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
          if (!member.isMember) CustomFilledButton(label: "join_now".tr, onTap: () {}),
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
        title: CustomText("about_us".tr, fontSize: 18.0, fontWeight: FontWeight.bold),
        trailing: CustomText(_isExpanded ? "less".tr : "more".tr, color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 16.0),
        children: <Widget>[
          CustomInfoListTile(
            icon: Icons.location_on_rounded,
            title: _branch.fullAddress,
            subtitle: "msg_google_maps_tap".tr,
            onTap: () => _redirectGoogleMap(_branch.fullAddress),
          ),
          CustomInfoListTile(
            icon: Icons.category_rounded,
            title: "categories".tr,
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
          CustomInfoListTile(icon: Icons.account_box_rounded, title: "about_us".tr, subtitle: _branch.branchDescription),
          CustomInfoListTile(icon: Icons.email_rounded, title: "email".tr, subtitle: _branch.subCompany.companyEmail),
          CustomInfoListTile(icon: Icons.phone_rounded, title: "phone".tr, subtitle: _branch.contactNumber),
        ],
      ),
    ),
  );

  Widget _buildTimeline() => Obx(() {
    if (_timelineController.isLoading.value) {
      return SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    if (_timelineController.timelines.isEmpty) return SliverToBoxAdapter();

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
              itemBuilder: (context, index) => CustomTimeline(branch: _branch, timeline: _timelineController.timelines[index]),
            ),
          ],
        ),
      ),
    );
  });
}
