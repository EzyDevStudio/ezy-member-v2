import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/constants/app_strings.dart';
import 'package:ezymember/controllers/branch_controller.dart';
import 'package:ezymember/controllers/company_controller.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/category_model.dart';
import 'package:ezymember/models/company_model.dart';
import 'package:ezymember/models/shop_model.dart';
import 'package:ezymember/widgets/custom_card.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:ezymember/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BranchListScreen extends StatefulWidget {
  const BranchListScreen({super.key});

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
  final _branchController = Get.put(BranchController(), tag: "branchList");
  final _companyController = Get.put(CompanyController(), tag: "branchList");
  final _searchController = TextEditingController();
  final List<CategoryModel> _categories = AppStrings.categories;
  final CategoryModel _allCategory = CategoryModel(title: "All", description: "", image: "");

  late CategoryModel _selectedCategory;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh({String? category}) async {
    if (category == null) _selectedCategory = _allCategory;
    _searchController.clear();
    _branchController.loadBranches(filterLocation: true);
    _companyController.loadCompanies(category: category);
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    rsp.init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        title: Image.asset("assets/images/app_logo.png", height: kToolbarHeight * 0.5),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
          child: RefreshIndicator(onRefresh: _onRefresh, child: _buildContent()),
        ),
      ),
    );
  }

  Widget _buildContent() => Obx(() {
    if (_branchController.isLoading.value || _companyController.isLoading.value) {
      return Padding(
        padding: EdgeInsets.all(16.dp),
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    List<ShopModel> displayShops = [];

    for (var company in _companyController.companies) {
      displayShops.add(ShopModel.combination(null, company));
    }

    for (var branch in _branchController.branches) {
      displayShops.add(
        ShopModel.combination(
          branch,
          _companyController.companies.firstWhere((c) => c.companyID == branch.customerID, orElse: () => CompanyModel.empty()),
        ),
      );
    }

    displayShops = displayShops.where((s) => s.categories.isNotEmpty).toList();
    displayShops.sort((a, b) => a.name.compareTo(b.name));

    final query = _searchController.text.trim().toLowerCase();
    final filteredShops = displayShops.where((s) => query.isEmpty || s.toCompare().toLowerCase().contains(query)).toList();

    if (displayShops.isEmpty) {
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
                      child: CustomSearchTextField(controller: _searchController, onChanged: (_) => setState(() {})),
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
                              PopupMenuItem(value: _allCategory, child: Text(_allCategory.title)),
                              ..._categories.map((c) => PopupMenuItem(value: c, child: Text(c.title))),
                            ],
                            onSelected: (category) {
                              setState(() => _selectedCategory = category);
                              category.title == "All" ? _onRefresh() : _onRefresh(category: category.code);
                            },
                            child: Center(child: Icon(Icons.filter_alt_rounded, color: Colors.blue)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedCategory != _allCategory)
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategory = _allCategory;
                    _onRefresh();
                  }),
                  child: CustomText(
                    "${Globalization.filter.tr}: ${_selectedCategory.title} (${Globalization.clear.tr})",
                    color: Colors.lightBlue,
                    fontSize: 16.0,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredShops.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(bottom: index == filteredShops.length - 1 ? 16.dp : 0.0, left: 16.dp, right: 16.dp, top: 16.dp),
              child: GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.companyDetail, arguments: {"company_id": filteredShops[index].companyID}),
                child: CustomShopCard(shop: filteredShops[index]),
              ),
            ),
          ),
        ),
      ],
    );
  });
}
