import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/controllers/branch_controller.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/widgets/custom_card.dart';
import 'package:ezy_member_v2/widgets/custom_text.dart';
import 'package:ezy_member_v2/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BranchListScreen extends StatefulWidget {
  const BranchListScreen({super.key});

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
  final _branchController = Get.put(BranchController(), tag: "branchList");
  final _searchController = TextEditingController();

  List<dynamic> _filteredBranches = [];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    _branchController.loadBranches(false);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(
      () => _filteredBranches = _branchController.branches
          .where(
            (branch) =>
                branch.branchName.toLowerCase().contains(query) ||
                branch.companyName.toLowerCase().contains(query) ||
                branch.fullAddress.toLowerCase().contains(query) ||
                branch.categories.toLowerCase().contains(query),
          )
          .toList(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    appBar: AppBar(title: Text(Globalization.shops.tr)),
    body: RefreshIndicator(onRefresh: _onRefresh, child: _buildContent()),
  );

  Widget _buildContent() => Obx(() {
    if (_branchController.isLoading.value) {
      return Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    if (_branchController.branches.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
        child: Center(
          child: CustomText(Globalization.msgNoAvailable.trParams({"label": Globalization.shops.tr.toLowerCase()}), fontSize: 16.0, maxLines: 2),
        ),
      );
    }

    final displayBranches = _searchController.text.isEmpty ? _branchController.branches : _filteredBranches;
    displayBranches.sort((a, b) => a.branchName.compareTo(b.branchName));

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context, 16.0)),
          child: CustomSearchTextField(controller: _searchController, onChanged: (String value) => _onSearchChanged()),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: displayBranches.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsetsGeometry.only(
                bottom: index == displayBranches.length - 1 ? ResponsiveHelper.getSpacing(context, 16.0) : 0.0,
                left: ResponsiveHelper.getSpacing(context, 16.0),
                right: ResponsiveHelper.getSpacing(context, 16.0),
                top: ResponsiveHelper.getSpacing(context, 16.0),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
                  child: GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.companyDetail, arguments: {"company_id": displayBranches[index].companyID}),
                    child: CustomShopCard(branch: displayBranches[index]),
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
