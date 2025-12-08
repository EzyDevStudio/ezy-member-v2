const String fieldID = "id";
const String fieldCompanyKey = "company_key";
const String fieldCompanyName = "company_name";
const String fieldCompanyEmail = "company_email";
const String fieldCompanyNumber = "contact_number";
const String fieldCompanyNumber2 = "contact_number2";

class SubCompanyModel {
  static const String keySubCompanies = "sub_companies";

  final int id;
  final String companyKey;
  final String companyName;
  final String companyEmail;
  final String companyNumber;
  final String companyNumber2;

  SubCompanyModel({
    this.id = 0,
    this.companyKey = "",
    this.companyName = "",
    this.companyEmail = "",
    this.companyNumber = "",
    this.companyNumber2 = "",
  });

  SubCompanyModel.empty() : this();

  factory SubCompanyModel.fromJson(Map<String, dynamic> data) => SubCompanyModel(
    id: data[fieldID] ?? 0,
    companyKey: data[fieldCompanyKey] ?? "",
    companyName: data[fieldCompanyName] ?? "",
    companyEmail: data[fieldCompanyEmail] ?? "",
    companyNumber: data[fieldCompanyNumber] ?? "",
    companyNumber2: data[fieldCompanyNumber2] ?? "",
  );

  @override
  String toString() =>
      "SubCompanyModel(id: $id, companyKey: $companyKey, companyName: $companyName, companyEmail: $companyEmail, companyNumber: $companyNumber, companyNumber2: $companyNumber2)\n";
}
