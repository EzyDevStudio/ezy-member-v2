import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/controllers/branch_controller.dart';
import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/controllers/company_controller.dart';
import 'package:ezy_member_v2/controllers/member_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/controllers/timeline_controller.dart';
import 'package:ezy_member_v2/helpers/code_generator_helper.dart';
import 'package:ezy_member_v2/helpers/message_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/models/company_model.dart';
import 'package:ezy_member_v2/models/member_model.dart';
import 'package:ezy_member_v2/widgets/custom_app_bar.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:ezy_member_v2/widgets/custom_chip.dart';
import 'package:ezy_member_v2/widgets/custom_fab.dart';
import 'package:ezy_member_v2/widgets/custom_list_tile.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:ezy_member_v2/widgets/custom_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class CompanyDetailScreen extends StatefulWidget {
  const CompanyDetailScreen({super.key});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  final _hive = Get.find<MemberHiveController>();
  final _branchController = Get.put(BranchController(), tag: "branchDetail");
  final _companyController = Get.put(CompanyController(), tag: "branchDetail");
  final _memberController = Get.put(MemberController(), tag: "branchDetail");
  final _timelineController = Get.put(TimelineController(), tag: "branchDetail");
  final _scrollController = ScrollController();

  late CompanyModel _company;
  late String _companyID, _referralCode;

  bool _showFab = false;

  @override
  void initState() {
    super.initState();

    _companyID = Get.arguments["company_id"];
    _referralCode = Get.arguments["referral_code"] ?? "";

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
    _branchController.loadBranches(companyID: _companyID);
    _companyController.loadCompany(_companyID);
    _timelineController.loadTimelines(companyID: _companyID);

    if (_hive.isSignIn) _memberController.loadMembers(_hive.memberProfile.value!.memberCode, companyID: _companyID);
  }

  bool _isExpired(MemberModel member) {
    if (!member.isExpired) return false;
    MessageHelper.show(Globalization.msgMemberExpired.tr, backgroundColor: Colors.red, icon: Icons.error_rounded);
    return true;
  }

  void _shareContent(BuildContext context) async {
    MemberModel member = _memberController.members.firstWhere((m) => m.companyID == _companyID, orElse: () => MemberModel.empty());

    final box = context.findRenderObject() as RenderBox?;

    // TODO: 1. Deep Linking
    SharePlus.instance.share(
      ShareParams(
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        text: Globalization.msgReferralProgram.trParams({
          "company": _company.companyName,
          "member": member.referralCode,
          "url": "${AppStrings.deepLinkUrl}/company_detail/${_company.companyID}/${member.referralCode}",
        }),
      ),
    );
  }

  void _joinMember() async {
    if (_hive.memberProfile.value == null) {
      MessageHelper.show(Globalization.msgNoAccount.tr, icon: Icons.info_rounded);
      return;
    }

    if (_company.memberFee > 0) {
      Get.toNamed(AppRoutes.payment, arguments: {"company_id": _companyID, "referral_code": _referralCode});
    } else {
      final result = await _companyController.registerMember(_companyID, _hive.memberProfile.value!.memberCode, _referralCode);

      if (result) _memberController.loadMembers(_hive.memberProfile.value!.memberCode, companyID: _companyID);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper().init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Obx(() {
          _company = _companyController.company.value ?? CompanyModel.empty();

          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[_buildAppBar(), _buildBenefits(), _buildCompanyInfo(), _buildBranchesInfo(), _buildTimeline()],
          );
        }),
      ),
      floatingActionButton: _showFab ? CustomFab(controller: _scrollController) : null,
    );
  }

  Widget _buildAppBar() => CustomAppBar(
    avatarImage: _company.aboutUs.companyLogo,
    backgroundImage: _company.categories.isNotEmpty ? _company.categories.first.categoryImage : "",
    child: Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomText(_company.companyName, color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
          CustomText(_company.companyNumber, color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
        ],
      ),
    ),
  );

  Widget _buildBenefits() => Obx(() {
    MemberModel member = _memberController.members.firstWhere((m) => m.companyID == _company.companyID, orElse: () => MemberModel.empty());

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 24.dp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16.dp,
          children: <Widget>[
            if (!_hive.isSignIn)
              CustomText(Globalization.memberBenefits.tr, color: Theme.of(context).colorScheme.primary, fontSize: 16.0, fontWeight: FontWeight.bold),
            if (!_hive.isSignIn || member.isMember)
              SizedBox(
                height: ResponsiveHelper().quickAccessHeight(),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomImageTextButton(
                        assetName: "assets/icons/my_points.png",
                        label: member.isMember ? Globalization.myPoints.tr : Globalization.earnPoints.tr,
                        content: member.isMember ? member.point.toString() : null,
                        onTap: member.isMember
                            ? () {
                                if (_isExpired(member)) return;
                                Get.toNamed(AppRoutes.scan, arguments: {"scan_type": ScanType.redeemPoints, "company_id": _company.companyID});
                              }
                            : null,
                      ),
                    ),
                    Expanded(
                      child: CustomImageTextButton(
                        assetName: "assets/icons/my_vouchers.png",
                        label: member.isMember ? Globalization.myVouchers.tr : Globalization.collectVouchers.tr,
                        content: member.isMember ? (member.normalVoucherCount + member.specialVoucherCount).toString() : null,
                        onTap: member.isMember && _hive.memberProfile.value != null
                            ? () {
                                if (_isExpired(member)) return;
                                Get.toNamed(AppRoutes.voucherList, arguments: {"check_start": 1, "company_id": _company.companyID});
                              }
                            : null,
                      ),
                    ),
                    Expanded(
                      child: CustomImageTextButton(
                        assetName: "assets/icons/my_credits.png",
                        label: member.isMember ? Globalization.myCredits.tr : Globalization.redeemByCredits.tr,
                        content: member.isMember ? member.credit.toStringAsFixed(1) : null,
                        onTap: member.isMember
                            ? () {
                                if (_isExpired(member)) return;
                                Get.toNamed(AppRoutes.scan, arguments: {"scan_type": ScanType.redeemCredits, "company_id": _company.companyID});
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            if (member.isMember)
              CodeGeneratorHelper.barcode(
                _hive.memberProfile.value!.memberCode,
                padding: EdgeInsets.only(bottom: 8.dp, left: 32.dp, right: 32.dp),
              ),
            if (_hive.isSignIn && !member.isMember && !_company.isExpired) CustomFilledButton(label: Globalization.joinUsNow.tr, onTap: _joinMember),
            if (member.isMember && !_company.isExpired)
              CustomFilledButton(backgroundColor: Colors.green, label: Globalization.share.tr, onTap: () => _shareContent(context)),
          ],
        ),
      ),
    );
  });

  Widget _buildCompanyInfo() => SliverToBoxAdapter(
    child: Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.7), width: 5.dp),
        ),
      ),
      child: Material(
        elevation: 1.0,
        child: ExpansionTile(
          childrenPadding: EdgeInsets.only(bottom: 16.dp),
          tilePadding: EdgeInsets.all(16.dp),
          title: CustomText(Globalization.aboutUs.tr, fontSize: 18.0, fontWeight: FontWeight.bold),
          children: <Widget>[
            CustomInfoListTile(
              icon: Icons.category_rounded,
              title: Globalization.categories.tr,
              subWidget: Padding(
                padding: EdgeInsets.only(top: 4.dp),
                child: Wrap(
                  runSpacing: 8.dp,
                  spacing: 8.dp,
                  children: _company.getCategoryTitles().split(", ").map((category) {
                    return CustomLabelChip(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      foregroundSize: 12.0,
                      label: category,
                    );
                  }).toList(),
                ),
              ),
            ),
            CustomInfoListTile(icon: Icons.account_box_rounded, title: Globalization.aboutUs.tr, subtitle: _company.aboutUs.companyDescription2),
            CustomInfoListTile(icon: Icons.email_rounded, title: Globalization.email.tr, subtitle: _company.companyEmail),
            CustomInfoListTile(icon: Icons.phone_rounded, title: Globalization.phone.tr, subtitle: _company.companyNumber),
          ],
        ),
      ),
    ),
  );

  Widget _buildBranchesInfo() => SliverToBoxAdapter(
    child: Obx(() {
      if (_branchController.branches.isEmpty) return SizedBox();

      return CustomBranchExpansion(branches: _branchController.branches);
    }),
  );

  Widget _buildTimeline() => Obx(() {
    if (_timelineController.isLoading.value) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    if (_timelineController.timelines.isEmpty) return SliverToBoxAdapter();

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.withValues(alpha: 0.7), width: 5.dp),
              ),
              color: Colors.white,
            ),
            padding: EdgeInsets.only(left: 16.dp, right: 16.dp, top: 24.dp),
            child: CustomText(Globalization.whatNew.tr, color: Theme.of(context).colorScheme.primary, fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _timelineController.timelines.length,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => Container(color: Colors.grey.withValues(alpha: 0.7), height: 5.dp),
            itemBuilder: (context, index) => CustomTimeline(timeline: _timelineController.timelines[index], isNavigateTimeline: true),
          ),
        ],
      ),
    );
  });
}
