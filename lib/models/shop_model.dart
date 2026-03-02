import 'package:ezymember/constants/app_strings.dart';
import 'package:ezymember/models/branch_model.dart';
import 'package:ezymember/models/company_model.dart';

class ShopModel {
  final String companyID;
  final String name;
  final String logo;
  final String address;
  final String categories;
  final String databaseName;

  ShopModel({
    required this.companyID,
    required this.name,
    required this.logo,
    required this.address,
    required this.categories,
    required this.databaseName,
  });

  factory ShopModel.combination(BranchModel? branch, CompanyModel? company) => ShopModel(
    companyID: branch != null ? branch.customerID : (company != null ? company.companyID : ""),
    name: branch != null ? branch.branchName : (company != null ? company.companyName : ""),
    logo: company != null ? company.companyLogo : "",
    address: branch != null ? branch.fullAddress : (company != null ? company.fullAddress : ""),
    categories: company != null ? company.categories : "",
    databaseName: company != null ? company.databaseName : "",
  );

  List<String> get categoryTitle {
    if (categories.isEmpty) return [];

    final codes = categories.split(",").map((e) => e.trim()).toList();
    final selectedCategories = AppStrings.categories.where((c) => codes.contains(c.code)).toList();

    return selectedCategories.map((c) => c.title).toList();
  }

  String toCompare() => "$name $address";
}
