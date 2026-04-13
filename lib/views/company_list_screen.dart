import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/constants/app_strings.dart';
import 'package:ezymember/controllers/company_controller.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/category_model.dart';
import 'package:ezymember/models/company_model.dart';
import 'package:ezymember/widgets/custom_card.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:ezymember/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen> {
  final _companyController = Get.put(CompanyController(), tag: "branchList");
  final _searchController = TextEditingController();
  final List<CategoryModel> _categories = AppStrings.categories;
  final CategoryModel _allCategory = CategoryModel(title: "All", description: "", image: "");

  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _onRefresh());
  }

  Future<void> _onRefresh() async {
    _selectedCategory = _allCategory;
    _searchController.clear();
    _companyController.loadCompanies(isLocation: true);
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
      body: _buildMobile(),
    );
  }

  Widget _buildMobile() => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: ResponsiveHelper.mobileBreakpoint),
      child: RefreshIndicator(onRefresh: _onRefresh, child: _buildContent()),
    ),
  );

  Widget _buildContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Padding(
        padding: EdgeInsets.all(16.dp),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16.dp,
            children: <Widget>[
              Expanded(
                child: CustomSearchTextField(
                  controller: _searchController,
                  onSubmit: (value) => _companyController.loadCompanies(search: value),
                  onClear: () => _onRefresh(),
                ),
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
                        _companyController.loadCompanies(category: category.code);
                      },
                      child: Center(child: Icon(Icons.filter_alt_rounded, color: Colors.blue)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (_selectedCategory != null && _selectedCategory != _allCategory)
        Padding(
          padding: EdgeInsets.fromLTRB(16.dp, 0.0, 16.dp, 8.dp),
          child: InkWell(
            onTap: () => setState(() {
              _selectedCategory = _allCategory;
              _onRefresh();
            }),
            child: CustomText(
              "${Globalization.filter.tr}: ${_selectedCategory!.title} (${Globalization.clear.tr})",
              color: Colors.lightBlue,
              fontSize: 16.0,
            ),
          ),
        ),
      Expanded(
        child: Obx(() {
          if (_companyController.isLoading.value) {
            return Padding(
              padding: EdgeInsets.all(16.dp),
              child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
            );
          }

          List<CompanyModel> companies = _companyController.companies;

          if (_companyController.companies.isEmpty) {
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

          final Map<String, List<CompanyModel>> grouped = {};

          for (var company in companies) {
            for (var code in company.categoryCodes) {
              final categoryTitle = AppStrings.categories.firstWhere((c) => c.code == code, orElse: () => AppStrings.categories.last).title;

              grouped.putIfAbsent(categoryTitle, () => []).add(company);
            }
          }

          final sorted = grouped.keys.toList()..sort((a, b) => a.compareTo(b));

          return ListView(
            children: <Widget>[
              for (var category in sorted) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 8.dp),
                  child: CustomText(category, fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kBorderRadiusM),
                    color: Colors.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Theme.of(context).colorScheme.surfaceContainerHigh,
                        blurRadius: kBlurRadius,
                        offset: Offset(kOffsetX, kOffsetY),
                      ),
                    ],
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 8.dp),
                  padding: EdgeInsets.all(12.dp),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: grouped[category]!.length,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, _) => Divider(color: Theme.of(context).colorScheme.surfaceContainerLow, height: 16.dp),
                    itemBuilder: (context, index) {
                      final company = grouped[category]![index];

                      return InkWell(
                        onTap: () => Get.toNamed(AppRoutes.companyDetail, arguments: {"company_id": company.companyID}),
                        child: CustomShopCard(company: company),
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    ],
  );
}
