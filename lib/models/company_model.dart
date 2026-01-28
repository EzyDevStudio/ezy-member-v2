import 'package:ezymember/models/about_us_model.dart';
import 'package:ezymember/models/category_model.dart';

const String fieldID = "id";
const String fieldCompanyID = "company_id";
const String fieldCompanyName = "company_name";
const String fieldDatabaseName = "database_name";
const String fieldBranchQuantity = "branch_quantity";
const String fieldCounterQuantity = "counter_quantity";
const String fieldAccessKey = "access_key";
const String fieldExpiredDate = "expired_date";
const String fieldIsExpired = "is_expired";
const String fieldMemberFee = "member_fee";
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
  final bool isExpired;
  final double memberFee;
  final String companyKey;
  final String companyEmail;
  final String companyNumber;
  final String companyNumber2;
  final List<CategoryModel> categories;
  final AboutUsModel aboutUs;

  CompanyModel({
    this.id = 0,
    this.companyID = "",
    this.companyName = "",
    this.databaseName = "",
    this.branchQuantity = "",
    this.counterQuantity = "",
    this.expiredDate = 0,
    this.isExpired = true,
    this.memberFee = 0.00,
    this.companyKey = "",
    this.companyEmail = "",
    this.companyNumber = "",
    this.companyNumber2 = "",
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
    isExpired: data[fieldIsExpired] ?? true,
    memberFee: (data[fieldMemberFee] ?? 0).toDouble(),
    companyKey: data[fieldCompanyKey] ?? "",
    companyEmail: data[fieldCompanyEmail] ?? "",
    companyNumber: data[fieldCompanyNumber] ?? "",
    companyNumber2: data[fieldCompanyNumber2] ?? "",
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
      "CompanyModel(id: $id, companyID: $companyID, companyName: $companyName, databaseName: $databaseName, branchQuantity: $branchQuantity, counterQuantity: $counterQuantity, expiredDate: $expiredDate, isExpired: $isExpired, memberFee: $memberFee, companyKey: $companyKey, companyEmail: $companyEmail, companyNumber: $companyNumber, companyNumber2: $companyNumber2"
      "\naboutUs: ${aboutUs.toString()}"
      "\ncategories: ${categories.toString()})\n";
}
