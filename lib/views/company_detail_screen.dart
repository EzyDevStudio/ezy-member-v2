import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/constants/app_strings.dart';
import 'package:ezymember/controllers/branch_controller.dart';
import 'package:ezymember/constants/enum.dart';
import 'package:ezymember/controllers/company_controller.dart';
import 'package:ezymember/controllers/member_controller.dart';
import 'package:ezymember/controllers/member_hive_controller.dart';
import 'package:ezymember/controllers/timeline_controller.dart';
import 'package:ezymember/helpers/code_generator_helper.dart';
import 'package:ezymember/helpers/formatter_helper.dart';
import 'package:ezymember/helpers/location_helper.dart';
import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/branch_model.dart';
import 'package:ezymember/models/company_model.dart';
import 'package:ezymember/models/member_model.dart';
import 'package:ezymember/services/local/connection_service.dart';
import 'package:ezymember/widgets/custom_app_bar.dart';
import 'package:ezymember/widgets/custom_button.dart';
import 'package:ezymember/widgets/custom_chip.dart';
import 'package:ezymember/widgets/custom_fab.dart';
import 'package:ezymember/widgets/custom_list_tile.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:ezymember/widgets/custom_timeline.dart';
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
    _companyController.loadCompany(_companyID);
    _branchController.loadBranches(companyID: _companyID);
    _timelineController.loadTimelines(companyID: _companyID);
    if (_hive.isSignIn) _memberController.loadMemberDetail(_hive.memberProfile.value!.memberCode, companyID: _companyID);
  }

  void _isExpired(MemberModel member, String page, Map<String, dynamic> arguments) {
    if (member.memberCard.expiredDate.isExpiredMsg) return;
    arguments.addAll({"company_id": _company.companyID});
    Get.toNamed(page, arguments: arguments);
  }

  void _shareContent(BuildContext context, MemberModel member) async {
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
      MessageHelper.warning(message: Globalization.msgNoAccount.tr);
      return;
    }

    final result = await _companyController.registerMember(_companyID, _hive.memberProfile.value!.memberCode, _referralCode);

    if (result) _memberController.loadMemberDetail(_hive.memberProfile.value!.memberCode, companyID: _companyID);

    // if (_company.memberFee > 0) {
    //   Get.toNamed(AppRoutes.payment, arguments: {"company_id": _companyID, "referral_code": _referralCode});
    // } else {
    //   final result = await _companyController.registerMember(_companyID, _hive.memberProfile.value!.memberCode, _referralCode);
    //
    //   if (result) _memberController.loadMembers(_hive.memberProfile.value!.memberCode, companyID: _companyID);
    // }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    rsp.init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Obx(() {
          _company = _companyController.company.value;

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
    avatarImage: _company.companyLogo,
    backgroundImage: _company.categoryImage,
    child: Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomText(_company.companyName, color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
          CustomText(_company.contactNumber, color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
        ],
      ),
    ),
  );

  Widget _buildBenefits() => SliverToBoxAdapter(
    child: Obx(() {
      if (_companyController.isLoading.value || _memberController.isLoading.value) return SizedBox();
      if (_companyController.company.value.databaseName.isEmpty) return SizedBox();

      MemberModel member = _memberController.members.isNotEmpty ? _memberController.members.first : MemberModel.empty();

      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.7), width: 5.dp),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 24.dp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16.dp,
          children: <Widget>[
            if (!_hive.isSignIn)
              CustomText(Globalization.memberBenefits.tr, color: Theme.of(context).colorScheme.primary, fontSize: 16.0, fontWeight: FontWeight.bold),
            if (!_hive.isSignIn || member.isMember) _buildBenefitGrid(member),
            ..._buildBenefitContent(member),
          ],
        ),
      );
    }),
  );

  Widget _buildBenefitGrid(MemberModel member) => GridView(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisSpacing: 16.dp,
      mainAxisExtent: rsp.quickHeight(),
      mainAxisSpacing: 16.dp,
      crossAxisCount: 3,
    ),
    children: <Widget>[
      CustomImageTextButton(
        assetName: "assets/icons/my_points.png",
        label: member.isMember ? Globalization.myPoints.tr : Globalization.earnPoints.tr,
        content: member.isMember ? member.point.toString() : null,
        onTap: member.isMember ? () => _isExpired(member, AppRoutes.scan, {"scan_type": ScanType.redeemPoints}) : null,
      ),
      CustomImageTextButton(
        assetName: "assets/icons/my_vouchers.png",
        label: member.isMember ? Globalization.myVouchers.tr : Globalization.collectVouchers.tr,
        content: member.isMember ? (member.normalCount + member.specialCount).toString() : null,
        onTap: member.isMember && _hive.memberProfile.value != null ? () => _isExpired(member, AppRoutes.voucherList, {"check_start": 1}) : null,
      ),
      CustomImageTextButton(
        assetName: "assets/icons/my_credits.png",
        label: member.isMember ? Globalization.myCredits.tr : Globalization.redeemByCredits.tr,
        content: member.isMember ? member.credit.toStringAsFixed(2) : null,
        onTap: member.isMember ? () => _isExpired(member, AppRoutes.scan, {"scan_type": ScanType.redeemCredits}) : null,
      ),
    ],
  );

  List<Widget> _buildBenefitContent(MemberModel member) {
    if (member.isMember) {
      return [
        CodeGeneratorHelper.barcode(
          _hive.memberProfile.value!.memberCode,
          padding: EdgeInsets.only(bottom: 8.dp, left: 32.dp, right: 32.dp),
        ),
        CustomFilledButton(backgroundColor: Colors.green, label: Globalization.share.tr, onTap: () => _shareContent(context, member)),
      ];
    } else {
      return [CustomFilledButton(label: Globalization.joinUsNow.tr, onTap: _joinMember)];
    }
  }

  Widget _buildCompanyInfo() => SliverToBoxAdapter(
    child: ExpansionTile(
      childrenPadding: EdgeInsets.only(bottom: 16.dp),
      tilePadding: EdgeInsets.all(16.dp),
      collapsedShape: const Border(),
      shape: const Border(),
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
              children: _company.categoryTitle.map((category) {
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
        CustomInfoListTile(icon: Icons.location_on_rounded, title: Globalization.address.tr, subtitle: _company.fullAddress),
        CustomInfoListTile(icon: Icons.email_rounded, title: Globalization.email.tr, subtitle: _company.email),
        CustomInfoListTile(icon: Icons.phone_rounded, title: Globalization.phone.tr, subtitle: _company.contactNumber),
        CustomInfoListTile(icon: Icons.account_box_rounded, title: Globalization.aboutUs.tr, subtitle: _company.companyDescription),
      ],
    ),
  );

  Widget _buildBranchesInfo() => SliverToBoxAdapter(
    child: Obx(() {
      if (_branchController.branches.isEmpty) return SizedBox();

      List<BranchModel> branches = _branchController.branches;

      return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.withValues(alpha: 0.7), width: 5.dp),
          ),
        ),
        child: ExpansionTile(
          childrenPadding: EdgeInsets.only(bottom: 16.dp),
          tilePadding: EdgeInsets.all(16.dp),
          collapsedShape: const Border(),
          shape: const Border(),
          title: CustomText("${Globalization.branches.tr} (${branches.length})", fontSize: 18.0, fontWeight: FontWeight.bold),
          children: branches.map((branch) {
            return CustomInfoListTile(
              title: branch.branchName,
              emoji: "\u{1F4CD}",
              subtitle: "${branch.fullAddress}\n(${branch.contactNumber})",
              onTapCopy: () async {
                if (!await ConnectionService.checkConnection()) return;

                LocationHelper.redirectGoogleMap(branch.fullAddress);
              },
            );
          }).toList(),
        ),
      );
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
