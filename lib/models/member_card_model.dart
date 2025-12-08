const String fieldID = "id";
const String fieldMemberCode = "member_code";
const String fieldCardCode = "card_code";
const String fieldExpiredDate = "expired_date";

class MemberCardModel {
  static const String keyMemberCard = "member_card";

  final int id;
  final String memberCode;
  final String cardCode;
  final int expiredDate;

  MemberCardModel({this.id = 0, this.memberCode = "", this.cardCode = "", this.expiredDate = 0});

  MemberCardModel.empty() : this();

  factory MemberCardModel.fromJson(Map<String, dynamic> data) => MemberCardModel(
    id: data[fieldID] ?? 0,
    memberCode: data[fieldMemberCode] ?? "",
    cardCode: data[fieldCardCode] ?? "",
    expiredDate: data[fieldExpiredDate] != null ? DateTime.tryParse(data[fieldExpiredDate])?.millisecondsSinceEpoch ?? 0 : 0,
  );

  @override
  String toString() => "MemberCardModel(id: $id, memberCode: $memberCode, cardCode: $cardCode, expiredDate: $expiredDate)\n";
}
