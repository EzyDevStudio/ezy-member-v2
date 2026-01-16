import 'package:ezy_member_v2/constants/app_constants.dart';
import 'package:ezy_member_v2/constants/app_routes.dart';
import 'package:ezy_member_v2/controllers/branch_controller.dart';
import 'package:ezy_member_v2/controllers/category_controller.dart';
import 'package:ezy_member_v2/helpers/responsive_helper.dart';
import 'package:ezy_member_v2/language/globalization.dart';
import 'package:ezy_member_v2/models/category_model.dart';
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
  final _categoryController = Get.put(CategoryController(), tag: "branchList");
  final _searchController = TextEditingController();
  final CategoryModel allCategory = CategoryModel(id: 0, categoryID: "", categoryTitle: "All", categoryImage: "");

  late CategoryModel _selectedCategory;

  List<dynamic> _filteredBranches = [];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_applyFilters);

    ever(_branchController.branches, (_) => _applyFilters());

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    _searchController.clear();
    _selectedCategory = allCategory;
    _branchController.loadBranches(false);
    _categoryController.loadCategories();
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredBranches = _branchController.branches.where((branch) {
        final matchesSearch = query.isEmpty ? true : branch.toCompare().toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == allCategory ? true : branch.categories.contains(_selectedCategory.categoryTitle);

        return matchesSearch && matchesCategory;
      }).toList();
    });
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
      appBar: AppBar(title: Text(Globalization.shops.tr)),
      body: RefreshIndicator(onRefresh: _onRefresh, child: _buildContent()),
    );
  }

  Widget _buildContent() => Obx(() {
    if (_branchController.isLoading.value) {
      return Padding(
        padding: EdgeInsets.all(16.dp),
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    if (_branchController.branches.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.dp),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomText(Globalization.msgNoAvailable.trParams({"label": Globalization.shops.tr.toLowerCase()}), fontSize: 16.0, maxLines: 2),
              InkWell(
                onTap: _onRefresh,
                child: CustomText(Globalization.refresh.tr, color: Colors.blue, fontSize: 16.0),
              ),
            ],
          ),
        ),
      );
    }

    final displayBranches = _filteredBranches;
    displayBranches.sort((a, b) => a.branchName.compareTo(b.branchName));

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16.dp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 32.dp,
            children: <Widget>[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16.dp,
                  children: <Widget>[
                    Expanded(
                      child: CustomSearchTextField(controller: _searchController, onChanged: (String value) => _applyFilters()),
                    ),
                    AspectRatio(
                      aspectRatio: kSquareRatio,
                      child: Material(
                        borderRadius: BorderRadius.circular(kBorderRadiusS),
                        elevation: kElevation,
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(kBorderRadiusS), color: Colors.white),
                          padding: EdgeInsets.all(8.dp),
                          child: PopupMenuButton<CategoryModel>(
                            itemBuilder: (context) => [
                              PopupMenuItem(value: allCategory, child: Text(allCategory.categoryTitle)),
                              ..._categoryController.categories.map((c) => PopupMenuItem(value: c, child: Text(c.categoryTitle))),
                            ],
                            onSelected: (category) {
                              setState(() => _selectedCategory = category);
                              _applyFilters();
                            },
                            child: Center(child: Icon(Icons.filter_alt_rounded, color: Colors.blue)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedCategory != allCategory)
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategory = allCategory;
                    _applyFilters();
                  }),
                  child: CustomText(
                    "${Globalization.filter.tr}: ${_selectedCategory.categoryTitle} (${Globalization.clear.tr})",
                    color: Colors.lightBlue,
                    fontSize: 16.0,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: displayBranches.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsetsGeometry.only(bottom: index == displayBranches.length - 1 ? 16.dp : 0.0, left: 16.dp, right: 16.dp, top: 16.dp),
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
