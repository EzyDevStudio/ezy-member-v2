const String fieldID = "id";
const String fieldAdsID = "ads_id";
const String fieldAdsTitle = "ads_title";
const String fieldAdsImage = "ads_image";
const String fieldStartDate = "start_date";
const String fieldExpiredDate = "expired_date";
const String fieldCompanyID = "company_id";

class AdvertisementModel {
  static const String keyAdvertisement = "advertisements";

  final int id;
  final String adsID;
  final String adsTitle;
  final String adsImage;
  final int startDate;
  final int expiredDate;
  final String companyID;

  AdvertisementModel({
    this.id = 0,
    this.adsID = "",
    this.adsTitle = "",
    this.adsImage = "",
    this.startDate = 0,
    this.expiredDate = 0,
    this.companyID = "",
  });

  AdvertisementModel.empty() : this();

  factory AdvertisementModel.fromJson(Map<String, dynamic> data) => AdvertisementModel(
    id: data[fieldID] ?? 0,
    adsID: data[fieldAdsID] ?? "",
    adsTitle: data[fieldAdsTitle] ?? "",
    adsImage: data[fieldAdsImage] ?? "",
    startDate: data[fieldStartDate] != null ? DateTime.tryParse(data[fieldStartDate])?.millisecondsSinceEpoch ?? 0 : 0,
    expiredDate: data[fieldExpiredDate] != null ? DateTime.tryParse(data[fieldExpiredDate])?.millisecondsSinceEpoch ?? 0 : 0,
    companyID: data[fieldCompanyID] ?? "",
  );

  @override
  String toString() =>
      "AdvertisementModel(id: $id, adsID: $adsID, adsTitle: $adsTitle, adsImage: $adsImage, startDate: $startDate, expiredDate: $expiredDate, companyID: $companyID)\n";
}
