import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/constants/app_strings.dart';
import 'package:ezy_member_v2/controllers/member_controller.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/widgets/custom_card.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _memberController = Get.put(MemberController(), tag: "memberList");

  late String? _memberCode;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments ?? {};

    _memberCode = args["member_code"];

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    if (_memberCode != null) _memberController.loadMembers(_memberCode!, getBranch: true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(slivers: <Widget>[_buildAppBar(), _buildContent()]),
    ),
  );

  Widget _buildAppBar() => SliverAppBar(floating: true, pinned: true, title: Text(AppStrings.myCards));

  Widget _buildContent() => SliverPadding(
    padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, SizeType.m)),
    sliver: Obx(() {
      if (_memberController.isLoading.value) {
        return SliverFillRemaining(
          child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
        );
      }

      if (_memberController.members.isEmpty) {
        return SliverFillRemaining(child: Center(child: CustomText(AppStrings.msgNoAvailableMember, fontSize: 16.0, maxLines: 2)));
      }

      _memberController.members.sort((a, b) {
        final d1 = a.branch.distanceKm ?? double.infinity;
        final d2 = b.branch.distanceKm ?? double.infinity;

        return d1.compareTo(d2);
      });

      return SliverToBoxAdapter(
        child: Wrap(
          runSpacing: ResponsiveHelper.getSpacing(context, SizeType.m),
          spacing: ResponsiveHelper.getSpacing(context, SizeType.m),
          alignment: WrapAlignment.center,
          children: _memberController.members.map((member) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint * 0.7),
              child: CustomMemberCard(
                member: member,
                onTap: () async {
                  await Get.toNamed(AppRoutes.branchDetail, arguments: {"branch": member.branch});

                  _onRefresh();
                },
              ),
            );
          }).toList(),
        ),
      );
    }),
  );
}
