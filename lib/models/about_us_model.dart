const String fieldID = "id";
const String fieldCompanyLogo = "company_logo";
const String fieldCompanyDescription = "company_description";
const String fieldCompanyDescription2 = "company_description2";
const String fieldCompanyVision = "company_vision";
const String fieldCompanyMission = "company_mission";
const String fieldCompanyValue = "company_value";

class AboutUsModel {
  static const String keyAboutUs = "about_us";

  final int id;
  final String companyLogo;
  final String companyDescription;
  final String companyDescription2;
  final String companyVision;
  final String companyMission;
  final String companyValue;

  AboutUsModel({
    this.id = 0,
    this.companyLogo = "",
    this.companyDescription = "",
    this.companyDescription2 = "",
    this.companyVision = "",
    this.companyMission = "",
    this.companyValue = "",
  });

  AboutUsModel.empty() : this();

  factory AboutUsModel.fromJson(Map<String, dynamic> data) => AboutUsModel(
    id: data[fieldID] ?? 0,
    companyLogo: data[fieldCompanyLogo] ?? "",
    companyDescription: data[fieldCompanyDescription] ?? "",
    companyDescription2: data[fieldCompanyDescription2] ?? "",
    companyVision: data[fieldCompanyVision] ?? "",
    companyMission: data[fieldCompanyMission] ?? "",
    companyValue: data[fieldCompanyValue] ?? "",
  );

  @override
  String toString() =>
      "AboutUsModel(id: $id, companyLogo: $companyLogo, companyDescription: $companyDescription, companyDescription2: $companyDescription2, companyVision: $companyVision, companyMission: $companyMission, companyValue: $companyValue)\n";
}
