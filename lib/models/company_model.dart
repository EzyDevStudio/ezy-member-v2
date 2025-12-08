import 'package:ezy_member_v2/models/category_model.dart';

const String fieldID = "id";
const String fieldCompanyID = "company_id";
const String fieldCompanyName = "company_name";
const String fieldDatabaseName = "database_name";
const String fieldBranchQuantity = "branch_quantity";
const String fieldCounterQuantity = "counter_quantity";
const String fieldAccessKey = "access_key";
const String fieldExpiredDate = "expired_date";

class CompanyModel {
  static const String keyCompany = "companies";

  final int id;
  final String companyID;
  final String companyName;
  final String databaseName;
  final String branchQuantity;
  final String counterQuantity;
  final int expiredDate;
  final List<CategoryModel> categories;

  CompanyModel({
    this.id = 0,
    this.companyID = "",
    this.companyName = "",
    this.databaseName = "",
    this.branchQuantity = "",
    this.counterQuantity = "",
    this.expiredDate = 0,
    this.categories = const [],
  });

  CompanyModel.empty() : this();

  factory CompanyModel.fromJson(Map<String, dynamic> data) => CompanyModel(
    id: data[fieldID] ?? 0,
    companyID: data[fieldCompanyID] ?? "",
    companyName: data[fieldCompanyName] ?? "",
    databaseName: data[fieldDatabaseName] ?? "",
    branchQuantity: data[fieldBranchQuantity] ?? "",
    counterQuantity: data[fieldCounterQuantity] ?? "",
    expiredDate: data[fieldExpiredDate] != null ? DateTime.tryParse(data[fieldExpiredDate])?.millisecondsSinceEpoch ?? 0 : 0,
    categories: data[CategoryModel.keyCategory] != null
        ? (data[CategoryModel.keyCategory] as List).map((json) => CategoryModel.fromJson(Map<String, dynamic>.from(json))).toList()
        : [],
  );

  @override
  String toString() =>
      "CompanyModel(id: $id, companyID: $companyID, companyName: $companyName, databaseName: $databaseName, branchQuantity: $branchQuantity, counterQuantity: $counterQuantity, expiredDate: $expiredDate)\n";
}
