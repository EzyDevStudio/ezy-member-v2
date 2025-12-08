const String fieldID = "id";
const String fieldPromotionID = "promotion_id";
const String fieldPromotionTitle = "promotion_title";
const String fieldPromotionImage = "promotion_image";
const String fieldStartDate = "start_date";
const String fieldExpiredDate = "expired_date";
const String fieldCompanyID = "company_id";

class PromotionModel {
  static const String keyPromotion = "promotions";

  final int id;
  final String promotionID;
  final String promotionTitle;
  final String promotionImage;
  final int startDate;
  final int expiredDate;
  final String companyID;

  PromotionModel({
    this.id = 0,
    this.promotionID = "",
    this.promotionTitle = "",
    this.promotionImage = "",
    this.startDate = 0,
    this.expiredDate = 0,
    this.companyID = "",
  });

  PromotionModel.empty() : this();

  factory PromotionModel.fromJson(Map<String, dynamic> data) => PromotionModel(
    id: data[fieldID] ?? 0,
    promotionID: data[fieldPromotionID] ?? "",
    promotionTitle: data[fieldPromotionTitle] ?? "",
    promotionImage: data[fieldPromotionImage] ?? "",
    startDate: data[fieldStartDate] != null ? DateTime.tryParse(data[fieldStartDate])?.millisecondsSinceEpoch ?? 0 : 0,
    expiredDate: data[fieldExpiredDate] != null ? DateTime.tryParse(data[fieldExpiredDate])?.millisecondsSinceEpoch ?? 0 : 0,
    companyID: data[fieldCompanyID] ?? "",
  );

  @override
  String toString() =>
      "PromotionModel(id: $id, promotionID: $promotionID, promotionTitle: $promotionTitle, promotionImage: $promotionImage, startDate: $startDate, expiredDate: $expiredDate, companyID: $companyID)\n";
}
