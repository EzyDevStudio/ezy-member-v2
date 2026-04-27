import 'package:ezymember/constants/app_constants.dart';
import 'package:ezymember/constants/app_routes.dart';
import 'package:ezymember/constants/app_strings.dart';
import 'package:ezymember/controllers/company_controller.dart';
import 'package:ezymember/controllers/member_hive_controller.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/company_model.dart';
import 'package:ezymember/widgets/custom_card.dart';
import 'package:ezymember/widgets/custom_chip.dart';
import 'package:ezymember/widgets/custom_container.dart';
import 'package:ezymember/widgets/custom_fab.dart';
import 'package:ezymember/widgets/custom_image.dart';
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
  final _hive = Get.find<MemberHiveController>();
  final _companyController = Get.put(CompanyController(), tag: "branchList");
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final ValueNotifier<bool> _showFab = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() => _showFab.value = _scrollController.offset > kBackToTop);
  }

  Future<void> _onSearch(String search) async {
    if (search.isEmpty) {
      _searchController.clear();
      _companyController.codes.clear();
      _companyController.companies.clear();
    } else {
      _companyController.codes.clear();
      _companyController.loadCompanies(search: search);
    }
  }

  Future<void> _onFilter() async {
    if (_companyController.codes.isEmpty) {
      _searchController.clear();
      _companyController.codes.clear();
      _companyController.companies.clear();
    } else {
      _searchController.clear();
      _companyController.loadCompanies(isLocation: true);
    }
  }

  Future<void> _onRefresh() async {
    _searchController.clear();
    _companyController.codes.clear();
    _companyController.companies.clear();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _showFab.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    rsp.init(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(controller: _scrollController, children: _buildMobile()),
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _showFab,
        builder: (_, show, _) => show ? CustomFab(controller: _scrollController) : const SizedBox.shrink(),
      ),
    );
  }

  List<Widget> _buildMobile() => [_buildAppBar(), _buildContent()];

  Widget _buildAppBar() => SizedBox(
    height: 270.0 + 15.dp,
    child: Stack(
      children: <Widget>[
        Positioned.fill(child: CustomBackgroundImage(cacheImage: _hive.backgroundImage)),
        Column(
          children: <Widget>[
            AppBar(
              backgroundColor: Colors.transparent,
              scrolledUnderElevation: 0.0,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.dp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10.dp,
                  children: <Widget>[
                    CustomText(Globalization.msgCompanyList.tr, color: Colors.white, fontSize: 16.0, maxLines: 2),
                    CustomSearchTextField(
                      controller: _searchController,
                      onSubmit: (value) => _onSearch(value),
                      onClear: () => _searchController.clear(),
                    ),
                    _filterSection(),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.dp)),
                color: Theme.of(context).colorScheme.surface,
              ),
              height: 15.dp,
            ),
          ],
        ),
      ],
    ),
  );

  Widget _filterSection() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 10.dp,
    children: <Widget>[
      Expanded(
        child: Obx(
          () => Wrap(
            runSpacing: 5.dp,
            spacing: 5.dp,
            children: _companyController.codes
                .map(
                  (filter) => CustomLabelChip(
                    backgroundColor: Colors.black.withValues(alpha: 0.3),
                    chipRadius: 50.0,
                    foregroundSize: 12.0,
                    padding: EdgeInsets.symmetric(horizontal: 12.dp, vertical: 4.dp),
                    label: filter,
                  ),
                )
                .toList(),
          ),
        ),
      ),
      TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          padding: EdgeInsets.symmetric(horizontal: 12.dp, vertical: 4.dp),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: Size.zero,
        ),
        onPressed: () async {
          final result = await Get.toNamed(AppRoutes.categoryList);
          if (result != null && result) _onFilter();
        },
        child: CustomText("${Globalization.filterOptions.tr} >", color: Colors.white, fontSize: 12.0),
      ),
    ],
  );

  Widget _buildContent() => Obx(() {
    if (_companyController.isLoading.value) {
      return Padding(
        padding: EdgeInsets.all(15.dp),
        child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
      );
    }

    List<CompanyModel> companies = _companyController.companies;

    if (companies.isEmpty) return _buildNearbyCard();

    final Map<String, List<CompanyModel>> grouped = {};

    for (var company in companies) {
      for (var code in company.categoryCodes) {
        final categoryTitle = AppStrings.categories.firstWhere((c) => c.code == code, orElse: () => AppStrings.categories.last).title;

        grouped.putIfAbsent(categoryTitle, () => []).add(company);
      }
    }

    final sorted = grouped.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10.dp,
      children: <Widget>[
        for (var category in sorted) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.dp),
            child: CustomText(category, fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20.dp, vertical: 10.dp),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: grouped[category]!.length,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (_, _) => SizedBox(height: 20.dp),
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
  });

  Widget _buildNearbyCard() => CustomContainer(
    height: 150.0,
    margin: EdgeInsets.symmetric(horizontal: 20.dp),
    padding: EdgeInsets.symmetric(horizontal: 10.dp, vertical: 5.dp),
    child: Row(
      children: <Widget>[
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scaleByDouble(-1.0, 1.0, 1.0, 1.0),
          child: Image.asset("assets/images/find_shop.png", scale: kSquareRatio),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CustomText(
                Globalization.msgCompanyListCard.tr,
                fontSize: 24.0,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                maxLines: null,
                textAlign: TextAlign.end,
              ),
              CustomLabelChip(
                backgroundColor: Colors.orange.withValues(alpha: 0.2),
                foregroundColor: Colors.black,
                label: "${Globalization.search.tr.toUpperCase()} >>",
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
