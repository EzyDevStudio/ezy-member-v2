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
import 'package:ezy_member_v2/widgets/custom_image.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:ezy_member_v2/widgets/custom_chip.dart';
import 'package:ezy_member_v2/widgets/custom_list_tile.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:ezy_member_v2/widgets/custom_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _scrollController = ScrollController();

  late BranchModel _branch;

  bool _isExpanded = false;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();

    _branch = Get.arguments["branch"];

    _scrollController.addListener(() {
      if (_scrollController.offset > kBackToTop && !_showFab) {
        setState(() => _showFab = true);
      } else if (_scrollController.offset <= kBackToTop && _showFab) {
        setState(() => _showFab = false);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    _timelineController.loadTimelines(companyID: _branch.company.companyID);

    if (_hive.isSignIn) _memberController.loadMembers(_hive.memberProfile.value!.memberCode);
  }

  void _shareContent(BuildContext context) async {
    MemberModel member = _memberController.members.firstWhere((m) => m.companyID == _branch.company.companyID, orElse: () => MemberModel.empty());

    final box = context.findRenderObject() as RenderBox?;
    final result = await SharePlus.instance.share(
      ShareParams(
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        text: "msg_referral_program".trParams({
          "company": _branch.subCompany.companyName,
          "member": member.referralCode,
          "url": "${AppStrings.serverUrl}/${_branch.subCompany.companyName}/${member.referralCode}",
        }),
      ),
    );

    if (result.status == ShareResultStatus.success) {
    } else if (result.status == ShareResultStatus.dismissed) {}
  }

  Future<void> _redirectGoogleMap(String fullAddress) async {
    MessageHelper.showDialog(type: DialogType.loading, title: "redirecting".tr, message: "msg_google_maps_redirecting".tr);

    Coordinate? c = await LocationHelper.getCurrentCoordinate();
    Coordinate? t = await LocationHelper.getCoordinate(fullAddress);

    if (c == null || t == null) return;

    await LocationHelper.navigateToGoogleMap(targetLat: t.latitude, targetLong: t.longitude, originLat: c.latitude, originLong: c.longitude);

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[_buildAppBar(), _buildBenefits(), _buildBranchInfo(), _buildTimeline()],
      ),
    ),
    floatingActionButton: _showFab
        ? FloatingActionButton(
            onPressed: () => _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut),
            child: const Icon(Icons.keyboard_arrow_up_rounded),
          )
        : null,
  );

  Widget _buildAppBar() => SliverAppBar(
    floating: true,
    pinned: true,
    snap: false,
    actions: [
      Obx(() {
        if (_memberController.members.isEmpty) return const SizedBox.shrink();

        return IconButton(onPressed: () => _shareContent(context), icon: Icon(Icons.share_rounded));
      }),
    ],
    bottom: _buildAppBarBottom(),
    flexibleSpace: FlexibleSpaceBar(background: CustomBackgroundImage(backgroundImage: _branch.company.categories[0].categoryImage)),
  );

  PreferredSize _buildAppBarBottom() => PreferredSize(
    preferredSize: Size.fromHeight(kProfileImgSizeM + ResponsiveHelper.getSpacing(context, 32.0)),
    child: Padding(
      padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
      child: SafeArea(
        child: Row(
          spacing: ResponsiveHelper.getSpacing(context, 16.0),
          children: <Widget>[
            CustomAvatarImage(size: kProfileImgSizeM, networkImage: _branch.aboutUs.companyLogo),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomText(_branch.branchName, color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
                  CustomText(_branch.contactNumber, color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                ],
              ),
            ),
            InkWell(
              onTap: () => _redirectGoogleMap(_branch.fullAddress),
              child: Icon(Icons.map_rounded, color: Colors.white, size: 40.0),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildBenefits() => Obx(() {
    MemberModel member = _memberController.members.firstWhere((m) => m.companyID == _branch.company.companyID, orElse: () => MemberModel.empty());

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, 16.0), vertical: ResponsiveHelper.getSpacing(context, 24.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: ResponsiveHelper.getSpacing(context, 16.0),
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
                                arguments: {
                                  "benefit_type": BenefitType.point,
                                  "scan_type": ScanType.barcode,
                                  "company_id": _branch.company.companyID,
                                },
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
                                arguments: {
                                  "benefit_type": BenefitType.credit,
                                  "scan_type": ScanType.barcode,
                                  "company_id": _branch.company.companyID,
                                },
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
      ),
    );
  });

  Widget _buildBranchInfo() => SliverToBoxAdapter(
    child: Column(
      children: <Widget>[
        Container(color: Colors.grey.withValues(alpha: 0.7), height: ResponsiveHelper.getSpacing(context, 5.0)),
        Material(
          elevation: 1.0,
          child: ExpansionTile(
            childrenPadding: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context, 16.0)),
            tilePadding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
            onExpansionChanged: (isExpanded) => setState(() => _isExpanded = isExpanded),
            title: CustomText("about_us".tr, fontSize: 18.0, fontWeight: FontWeight.bold),
            trailing: CustomText(_isExpanded ? "less".tr : "more".tr, color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 16.0),
            children: <Widget>[
              CustomInfoListTile(
                icon: Icons.location_on_rounded,
                trailing: Icons.content_copy_rounded,
                title: "address".tr,
                subtitle: _branch.fullAddress,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _branch.fullAddress));
                  MessageHelper.show("msg_address_copied".tr, icon: Icons.content_copy_rounded);
                },
              ),
              CustomInfoListTile(
                icon: Icons.category_rounded,
                title: "categories".tr,
                subWidget: Padding(
                  padding: EdgeInsets.only(top: ResponsiveHelper.getSpacing(context, 4.0)),
                  child: Wrap(
                    runSpacing: ResponsiveHelper.getSpacing(context, 8.0),
                    spacing: ResponsiveHelper.getSpacing(context, 8.0),
                    children: _branch.company.categories.map((category) {
                      return CustomLabelChip(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
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
      ],
    ),
  );

  Widget _buildTimeline() => Obx(() {
    if (_timelineController.isLoading.value) {
      return SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    if (_timelineController.timelines.isEmpty) return SliverToBoxAdapter();

    final timelines = List.from(_timelineController.timelines)..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(color: Colors.grey.withValues(alpha: 0.7), height: ResponsiveHelper.getSpacing(context, 5.0)),
          Padding(
            padding: EdgeInsets.only(
              left: ResponsiveHelper.getSpacing(context, 16.0),
              right: ResponsiveHelper.getSpacing(context, 16.0),
              top: ResponsiveHelper.getSpacing(context, 24.0),
            ),
            child: CustomText("what_new".tr, color: Theme.of(context).colorScheme.primary, fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: timelines.length,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => Container(color: Colors.grey.withValues(alpha: 0.7), height: ResponsiveHelper.getSpacing(context, 5.0)),
            itemBuilder: (context, index) => CustomTimeline(branch: _branch, timeline: timelines[index]),
          ),
        ],
      ),
    );
  });
}
