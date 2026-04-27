import 'package:ezymember/constants/app_strings.dart';
import 'package:ezymember/controllers/company_controller.dart';
import 'package:ezymember/controllers/member_hive_controller.dart';
import 'package:ezymember/helpers/responsive_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/category_model.dart';
import 'package:ezymember/widgets/custom_button.dart';
import 'package:ezymember/widgets/custom_image.dart';
import 'package:ezymember/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final _hive = Get.find<MemberHiveController>();
  final _companyController = Get.find<CompanyController>(tag: "branchList");
  final List<CategoryModel> _categories = AppStrings.categories;

  late final ValueNotifier<List<String>> _codes;

  @override
  void initState() {
    super.initState();

    _codes = ValueNotifier<List<String>>(List.from(_companyController.codes));
  }

  @override
  void dispose() {
    _codes.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: ListView(shrinkWrap: false, children: <Widget>[_buildAppBar(), _buildContent()]));

  Widget _buildAppBar() => SizedBox(
    height: kToolbarHeight + 15.dp,
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
              title: Image.asset("assets/images/app_logo.png", height: kToolbarHeight * 0.5),
            ),
            Container(
              height: 15.dp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15.dp)),
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildContent() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 15.dp),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15.dp,
      children: <Widget>[
        CustomText(Globalization.businessCategories.tr, color: Theme.of(context).colorScheme.primary, fontSize: 18.0, fontWeight: FontWeight.bold),
        ValueListenableBuilder(
          valueListenable: _codes,
          builder: (_, codes, _) => GridView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 10.dp,
              mainAxisExtent: 110.0,
              mainAxisSpacing: 10.dp,
              crossAxisCount: 3,
            ),
            children: _categories.map((category) {
              final isToggled = codes.contains(category.code);

              return CustomToggleButton(
                isToggled: isToggled,
                assetName: category.icon,
                label: category.title,
                onTap: () {
                  final list = List<String>.from(_codes.value);

                  list.contains(category.code) ? list.remove(category.code) : list.add(category.code);
                  _codes.value = list;
                },
              );
            }).toList(),
          ),
        ),
        CustomFilledButton(
          label: Globalization.apply.tr,
          onTap: () {
            _companyController.codes.assignAll(_codes.value);
            Get.back(result: true);
          },
        ),
      ],
    ),
  );
}
