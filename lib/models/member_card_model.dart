const String fieldID = "id";
const String fieldMemberCode = "member_code";
const String fieldCardCode = "card_code";
const String fieldMemberCardNumber = "member_card_number";
const String fieldExpiredDate = "expired_date";
const String fieldCardDesc = "card_desc";
const String fieldCardMagnification = "card_magnification";
const String fieldCardImage = "card_image";
const String fieldIsDefault = "isDefault";
const String fieldCreatedAt = "created_at";

class MemberCardModel {
  static const String keyMemberCard = "member_card";

  final int id;
  final String memberCode;
  final String cardCode;
  final String memberCardNumber;
  final int expiredDate;
  final String cardDesc;
  final double cardMagnification;
  final String cardImage;
  final bool isDefault;
  final int createdAt;

  MemberCardModel({
    this.id = 0,
    this.memberCode = "",
    this.cardCode = "",
    this.memberCardNumber = "",
    this.expiredDate = 0,
    this.cardDesc = "",
    this.cardMagnification = 1.0,
    this.cardImage = "",
    this.isDefault = false,
    this.createdAt = 0,
  });

  MemberCardModel.empty() : this();

  factory MemberCardModel.fromJson(Map<String, dynamic> data) => MemberCardModel(
    id: data[fieldID] ?? 0,
    memberCode: data[fieldMemberCode] ?? "",
    cardCode: data[fieldCardCode] ?? "",
    memberCardNumber: data[fieldMemberCardNumber] ?? "",
    expiredDate: data[fieldExpiredDate] != null ? DateTime.tryParse(data[fieldExpiredDate])?.millisecondsSinceEpoch ?? 0 : 0,
    cardDesc: data[fieldCardDesc] ?? "",
    cardMagnification: (data[fieldCardMagnification] ?? 0).toDouble(),
    cardImage: data[fieldCardImage] ?? "",
    isDefault: data[fieldIsDefault] != null ? (data[fieldIsDefault] == 1 ? true : false) : false,
    createdAt: data[fieldCreatedAt] != null ? DateTime.tryParse(data[fieldCreatedAt])?.millisecondsSinceEpoch ?? 0 : 0,
  );

  @override
  String toString() =>
      "MemberCardModel(id: $id, memberCode: $memberCode, cardCode: $cardCode, memberCardNumber: $memberCardNumber, expiredDate: $expiredDate, cardDesc: $cardDesc, cardMagnification: $cardMagnification, cardImage: $cardImage, isDefault: $isDefault, createdAt: $createdAt)\n";
}
