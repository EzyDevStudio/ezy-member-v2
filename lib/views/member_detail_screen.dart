import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/controllers/company_controller.dart';
import 'package:ezy_member_v2/controllers/history_controller.dart';
import 'package:ezy_member_v2/controllers/member_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/helpers/formatter_helper.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/models/company_model.dart';
import 'package:ezy_member_v2/models/member_model.dart';
import 'package:ezy_member_v2/widgets/custom_app_bar.dart';
import 'package:ezy_member_v2/widgets/custom_button.dart';
import 'package:ezy_member_v2/widgets/custom_list_tile.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberDetailScreen extends StatefulWidget {
  const MemberDetailScreen({super.key});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  final _hive = Get.find<MemberHiveController>();
  final _companyController = Get.put(CompanyController(), tag: "memberDetail");
  final _historyController = Get.put(HistoryController(), tag: "memberDetail");
  final _memberController = Get.put(MemberController(), tag: "memberDetail");
  final _scrollController = ScrollController();

  late MemberModel _member;
  late String _companyID;

  bool _showFab = false;
  HistoryType _selectedType = HistoryType.all;

  @override
  void initState() {
    super.initState();

    _companyID = Get.arguments["company_id"];

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
    _historyController.loadHistories(_hive.memberProfile.value!.memberCode, companyID: _companyID);
    _memberController.loadMembers(_hive.memberProfile.value!.memberCode, companyID: _companyID);
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
      child: Obx(() {
        _member = _memberController.members.isNotEmpty ? _memberController.members.first : MemberModel.empty();

        return CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[_buildAppBar(), _buildBenefits(), _buildBranchesInfo(), _buildHistory()],
        );
      }),
    ),
    floatingActionButton: _showFab
        ? FloatingActionButton(
            onPressed: () => _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut),
            child: const Icon(Icons.keyboard_arrow_up_rounded),
          )
        : null,
  );

  Widget _buildAppBar() => CustomAppBar(
    avatarImage: _hive.image,
    backgroundImage: _memberController.members.isNotEmpty ? _memberController.members.first.memberCard.cardImage : "",
    child: Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomText(_member.memberCard.memberCode, color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
          CustomText(
            "${_member.memberCard.cardDesc} · ${FormatterHelper.timestampToString(_member.memberCard.expiredDate)}",
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    ),
  );

  Widget _buildBenefits() => Obx(() {
    MemberModel member = _memberController.members.firstWhere((m) => m.companyID == _member.companyID, orElse: () => MemberModel.empty());

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getSpacing(context, 16.0), vertical: ResponsiveHelper.getSpacing(context, 24.0)),
        child: SizedBox(
          height: ResponsiveHelper.isDesktop(context) ? 150.0 : 100.0,
          child: Row(
            children: <Widget>[
              Expanded(
                child: CustomImageTextButton(
                  assetName: "assets/icons/my_points.png",
                  label: "my_points".tr,
                  content: member.point.toString(),
                  onTap: () => Get.toNamed(
                    AppRoutes.payment,
                    arguments: {"benefit_type": BenefitType.point, "scan_type": ScanType.barcode, "company_id": _member.companyID},
                  ),
                ),
              ),
              Expanded(
                child: CustomImageTextButton(
                  assetName: "assets/icons/my_vouchers.png",
                  label: "my_vouchers".tr,
                  content: (member.normalVoucherCount + member.specialVoucherCount).toString(),
                  onTap: () => Get.toNamed(AppRoutes.voucherList, arguments: {"check_start": 1, "company_id": _member.companyID}),
                ),
              ),
              Expanded(
                child: CustomImageTextButton(
                  assetName: "assets/icons/my_credits.png",
                  label: "my_credits".tr,
                  content: member.credit.toStringAsFixed(1),
                  onTap: () => Get.toNamed(
                    AppRoutes.payment,
                    arguments: {"benefit_type": BenefitType.credit, "scan_type": ScanType.barcode, "company_id": _member.companyID},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });

  Widget _buildBranchesInfo() => SliverToBoxAdapter(
    child: Obx(() {
      CompanyModel company = _companyController.company.value ?? CompanyModel.empty();

      return CustomBranchExpansion(company: company);
    }),
  );

  Widget _buildHistory() => Obx(() {
    if (_historyController.histories.isEmpty) return SliverToBoxAdapter();

    final filteredHistories = _selectedType == HistoryType.all
        ? _historyController.histories
        : _historyController.histories.where((h) => h.type == _selectedType).toList();

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Column(
          children: <Widget>[
            if (index == 0)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.withValues(alpha: 0.7), width: ResponsiveHelper.getSpacing(context, 5.0)),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getSpacing(context, 16.0),
                  vertical: ResponsiveHelper.getSpacing(context, 16.0),
                ),
                child: Row(
                  spacing: ResponsiveHelper.getSpacing(context, 16.0),
                  children: <Widget>[
                    Expanded(child: CustomText("history".tr, fontSize: 18.0, fontWeight: FontWeight.bold)),
                    PopupMenuButton<HistoryType>(
                      onSelected: (value) => setState(() => _selectedType = value),
                      itemBuilder: (context) => AppStrings().historyTypes.entries
                          .map((entry) => PopupMenuItem<HistoryType>(value: entry.key, child: CustomText(entry.value, fontSize: 14.0)))
                          .toList(),
                      child: Row(
                        spacing: ResponsiveHelper.getSpacing(context, 4.0),
                        children: <Widget>[
                          CustomText(AppStrings().historyTypes[_selectedType]!, color: Colors.grey, fontSize: 16.0),
                          Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            CustomHistoryListTile(history: filteredHistories[index]),
            if (index + 1 != filteredHistories.length)
              Divider(
                color: Colors.grey.shade200,
                endIndent: ResponsiveHelper.getSpacing(context, 16.0),
                indent: ResponsiveHelper.getSpacing(context, 16.0),
                height: 1.0,
              ),
          ],
        ),
        childCount: filteredHistories.length,
      ),
    );
  });
}
