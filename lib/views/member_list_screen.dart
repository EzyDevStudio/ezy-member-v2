import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/controllers/member_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/widgets/custom_card.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:ezy_member_v2/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _hive = Get.find<MemberHiveController>();
  final _memberController = Get.put(MemberController(), tag: "memberList");
  final _searchController = TextEditingController();

  List<dynamic> _filteredMembers = [];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    _memberController.loadMembers(_hive.memberProfile.value!.memberCode, getBranch: true);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() => _filteredMembers = _memberController.members.where((member) => member.branch.companyName.toLowerCase().contains(query)).toList());
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text("my_cards".tr)),
    backgroundColor: Theme.of(context).colorScheme.surface,
    body: RefreshIndicator(onRefresh: _onRefresh, child: _buildContent()),
  );

  Widget _buildContent() => Obx(() {
    if (_memberController.isLoading.value) {
      return Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    if (_memberController.members.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
        child: Center(child: CustomText("msg_no_available".trParams({"label": "member".tr.toLowerCase()}), fontSize: 16.0, maxLines: 2)),
      );
    }

    final members = List.from(_memberController.members);

    members.sort((a, b) {
      final d1 = a.branch.distanceKm ?? double.infinity;
      final d2 = b.branch.distanceKm ?? double.infinity;

      return d1.compareTo(d2);
    });

    final displayMembers = _searchController.text.isEmpty ? members : _filteredMembers;

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
          child: CustomSearchTextField(controller: _searchController, onChanged: (String value) => _onSearchChanged()),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: displayMembers.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsetsGeometry.only(
                bottom: index == displayMembers.length - 1 ? ResponsiveHelper.getSpacing(context, 16.0) : 0.0,
                left: ResponsiveHelper.getSpacing(context, 16.0),
                right: ResponsiveHelper.getSpacing(context, 16.0),
                top: ResponsiveHelper.getSpacing(context, 16.0),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint * 0.7),
                  child: CustomMemberCard(
                    member: displayMembers[index],
                    onTap: () => Get.toNamed(AppRoutes.memberDetail, arguments: {"company_id": displayMembers[index].companyID}),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  });
}
