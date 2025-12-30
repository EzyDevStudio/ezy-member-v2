import 'package:ezy_member_v2/models/about_us_model.dart';
import 'package:ezy_member_v2/models/branch_model.dart';
import 'package:ezy_member_v2/models/category_model.dart';

const String fieldID = "id";
const String fieldCompanyID = "company_id";
const String fieldCompanyName = "company_name";
const String fieldDatabaseName = "database_name";
const String fieldBranchQuantity = "branch_quantity";
const String fieldCounterQuantity = "counter_quantity";
const String fieldAccessKey = "access_key";
const String fieldExpiredDate = "expired_date";
const String fieldCompanyKey = "company_key";
const String fieldCompanyEmail = "company_email";
const String fieldCompanyNumber = "contact_number";
const String fieldCompanyNumber2 = "contact_number2";

class CompanyModel {
  static const String keyCompany = "companies";

  final int id;
  final String companyID;
  final String companyName;
  final String databaseName;
  final String branchQuantity;
  final String counterQuantity;
  final int expiredDate;
  final String companyKey;
  final String companyEmail;
  final String companyNumber;
  final String companyNumber2;
  final List<CategoryModel> categories;
  final List<BranchModel> branches;
  final AboutUsModel aboutUs;

  CompanyModel({
    this.id = 0,
    this.companyID = "",
    this.companyName = "",
    this.databaseName = "",
    this.branchQuantity = "",
    this.counterQuantity = "",
    this.expiredDate = 0,
    this.companyKey = "",
    this.companyEmail = "",
    this.companyNumber = "",
    this.companyNumber2 = "",
    this.branches = const [],
    this.categories = const [],
    AboutUsModel? aboutUs,
  }) : aboutUs = aboutUs ?? AboutUsModel.empty();

  CompanyModel.empty() : this();

  factory CompanyModel.fromJson(Map<String, dynamic> data) => CompanyModel(
    id: data[fieldID] ?? 0,
    companyID: data[fieldCompanyID] ?? "",
    companyName: data[fieldCompanyName] ?? "",
    databaseName: data[fieldDatabaseName] ?? "",
    branchQuantity: data[fieldBranchQuantity] ?? "",
    counterQuantity: data[fieldCounterQuantity] ?? "",
    expiredDate: data[fieldExpiredDate] != null ? DateTime.tryParse(data[fieldExpiredDate])?.millisecondsSinceEpoch ?? 0 : 0,
    companyKey: data[fieldCompanyKey] ?? "",
    companyEmail: data[fieldCompanyEmail] ?? "",
    companyNumber: data[fieldCompanyNumber] ?? "",
    companyNumber2: data[fieldCompanyNumber2] ?? "",
    branches: data[BranchModel.keyBranch] != null
        ? (data[BranchModel.keyBranch] as List).map((json) => BranchModel.fromJson(Map<String, dynamic>.from(json))).toList()
        : [],
    categories: data[CategoryModel.keyCategory] != null
        ? (data[CategoryModel.keyCategory] as List).map((json) => CategoryModel.fromJson(Map<String, dynamic>.from(json))).toList()
        : [],
    aboutUs: data[AboutUsModel.keyAboutUs] != null
        ? AboutUsModel.fromJson(Map<String, dynamic>.from(data[AboutUsModel.keyAboutUs]))
        : AboutUsModel.empty(),
  );

  String getCategoryTitles() => categories.map((c) => c.categoryTitle).join(", ");

  @override
  String toString() =>
      "CompanyModel(id: $id, companyID: $companyID, companyName: $companyName, databaseName: $databaseName, branchQuantity: $branchQuantity, counterQuantity: $counterQuantity, expiredDate: $expiredDate, companyKey: $companyKey, companyEmail: $companyEmail, companyNumber: $companyNumber, companyNumber2: $companyNumber2"
      "\naboutUs: ${aboutUs.toString()}"
      "\nbranches: ${branches.toString()}"
      "\ncategories: ${categories.toString()})\n";
}
