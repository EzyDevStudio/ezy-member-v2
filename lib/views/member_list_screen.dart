import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/controllers/member_controller.dart';
import 'package:ezy_member_v2/controllers/member_hive_controller.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
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
    _memberController.loadMembers(_hive.memberProfile.value!.memberCode);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() => _filteredMembers = _memberController.members.where((member) => member.toCompare().toLowerCase().contains(query)).toList());
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveHelper().init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        title: Text(Globalization.myCards.tr),
      ),
      body: RefreshIndicator(onRefresh: _onRefresh, child: _buildContent()),
    );
  }

  Widget _buildContent() => Obx(() {
    if (_memberController.isLoading.value) {
      return Padding(
        padding: EdgeInsets.all(16.dp),
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    if (_memberController.members.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.dp),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomText(Globalization.msgNoAvailable.trParams({"label": Globalization.member.tr.toLowerCase()}), fontSize: 16.0, maxLines: 2),
              InkWell(
                onTap: _onRefresh,
                child: CustomText(Globalization.refresh.tr, color: Colors.blue, fontSize: 16.0),
              ),
            ],
          ),
        ),
      );
    }

    final members = List.from(_memberController.members);
    final displayMembers = _searchController.text.isEmpty ? members : _filteredMembers;

    displayMembers.sort((a, b) => (b.memberCard.isFavorite == true ? 1 : 0).compareTo(a.memberCard.isFavorite == true ? 1 : 0));

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16.dp),
          child: CustomSearchTextField(controller: _searchController, onChanged: (String value) => _onSearchChanged()),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: displayMembers.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsetsGeometry.only(bottom: index == displayMembers.length - 1 ? 16.dp : 0.0, left: 16.dp, right: 16.dp, top: 16.dp),
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
