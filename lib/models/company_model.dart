import 'package:ezymember/constants/app_strings.dart';

const String fieldID = "id";
const String fieldCompanyID = "company_id";
const String fieldCustomerID = "customer_id";
const String fieldCompanyName = "company_name";
const String fieldCompanyLogo = "company_logo";
const String fieldCompanyDescription = "company_description";
const String fieldCompanyVision = "company_vision";
const String fieldCompanyMission = "company_mission";
const String fieldCompanyValue = "company_value";
const String fieldStatus = "status";
const String fieldContactNumber = "contact_number";
const String fieldEmail = "email";
const String fieldAddress1 = "address1";
const String fieldAddress2 = "address2";
const String fieldAddress3 = "address3";
const String fieldAddress4 = "address4";
const String fieldPostcode = "postcode";
const String fieldCity = "city";
const String fieldState = "state";
const String fieldCategories = "business_category";
const String fieldDatabaseName = "database_name";
const String fieldDomainName = "domain_name";
const String fieldExpiredDate = "ezymember_expired_date";

class CompanyModel {
  static const String keyCompany = "companies";

  final int id;
  final String companyID;
  final String companyName;
  final String companyLogo;
  final String companyDescription;
  final String companyVision;
  final String companyMission;
  final String companyValue;
  final int status;
  final String contactNumber;
  final String email;
  final String address1;
  final String address2;
  final String address3;
  final String address4;
  final String postcode;
  final String city;
  final String state;
  final String categories;
  final String databaseName;
  final String domainName;
  final int expiredDate;

  CompanyModel({
    this.id = 0,
    this.companyID = "",
    this.companyName = "",
    this.companyLogo = "",
    this.companyDescription = "",
    this.companyVision = "",
    this.companyMission = "",
    this.companyValue = "",
    this.status = 0,
    this.contactNumber = "",
    this.email = "",
    this.address1 = "",
    this.address2 = "",
    this.address3 = "",
    this.address4 = "",
    this.postcode = "",
    this.city = "",
    this.state = "",
    this.categories = "",
    this.databaseName = "",
    this.domainName = "",
    this.expiredDate = 0,
  });

  CompanyModel.empty() : this();

  factory CompanyModel.fromJson(Map<String, dynamic> data1, Map<String, dynamic> data2) => CompanyModel(
    id: data2[fieldID] ?? 0,
    companyID: data2[fieldCompanyID] ?? (data1[fieldCustomerID] ?? ""),
    companyName: data2[fieldCompanyName] ?? (data1[fieldCompanyName] ?? ""),
    companyLogo: data2[fieldCompanyLogo] ?? (data1[fieldCompanyLogo] ?? ""),
    companyDescription: data2[fieldCompanyDescription] ?? "",
    companyVision: data2[fieldCompanyVision] ?? "",
    companyMission: data2[fieldCompanyMission] ?? "",
    companyValue: data2[fieldCompanyValue] ?? "",
    status: data2[fieldStatus] ?? 0,
    contactNumber: data1[fieldContactNumber] ?? "",
    email: data1[fieldEmail] ?? "",
    address1: data1[fieldAddress1] ?? "",
    address2: data1[fieldAddress2] ?? "",
    address3: data1[fieldAddress3] ?? "",
    address4: data1[fieldAddress4] ?? "",
    postcode: data1[fieldPostcode] ?? "",
    city: data1[fieldCity] ?? "",
    state: data1[fieldState] ?? "",
    categories: data1[fieldCategories] ?? "",
    databaseName: data1[fieldDatabaseName] ?? "",
    domainName: data1[fieldDomainName] ?? "",
    expiredDate: data1[fieldExpiredDate] != null ? DateTime.tryParse(data1[fieldExpiredDate])?.millisecondsSinceEpoch ?? 0 : 0,
  );

  String get fullAddress => [address1, address2, address3, address4, postcode, city, state].where((e) => e.isNotEmpty).join(", ");

  String get categoryImage {
    if (categories.isEmpty) return AppStrings.categories.last.image;

    final code = categories.split(", ").first.trim();
    final selectedCategory = AppStrings.categories.firstWhere((c) => c.code == code, orElse: () => AppStrings.categories.last);

    return selectedCategory.image;
  }

  List<String> get categoryCodes {
    if (categories.isEmpty) return [];

    return categories.split(",").map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  List<String> get categoryTitle {
    if (categories.isEmpty) return [];

    final codes = categories.split(",").map((e) => e.trim()).toList();
    final selectedCategories = AppStrings.categories.where((c) => codes.contains(c.code)).toList();

    return selectedCategories.map((c) => c.title).toList();
  }

  @override
  String toString() =>
      "CompanyModel(id: $id, companyID: $companyID, companyName: $companyName, companyLogo: $companyLogo, companyDescription: $companyDescription, companyVision: $companyVision, companyMission: $companyMission, companyValue: $companyValue, status: $status, contactNumber: $contactNumber, email: $email, address1: $address1, address2: $address2, address3: $address3, address4: $address4, postcode: $postcode, city: $city, state: $state, categories: $categories, databaseName: $databaseName, domainName: $domainName, expiredDate: $expiredDate)\n";
}
