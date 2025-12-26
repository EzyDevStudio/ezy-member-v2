const String fieldID = "id";
const String fieldMemberCode = "member_code";
const String fieldPin = "pin";
const String fieldExpiredDate = "expired_date";
const String fieldVoucherCode = "voucher_code";

class PinModel {
  static const String keyPin = "pin";

  final int id;
  final String memberCode;
  final String pin;
  final DateTime expiredDate;
  final String voucherCode;

  PinModel({this.id = 0, this.memberCode = "", this.pin = "", DateTime? expiredDate, this.voucherCode = ""})
    : expiredDate = expiredDate ?? DateTime.now();

  PinModel.empty() : this();

  factory PinModel.fromJson(Map<String, dynamic> data) => PinModel(
    id: data[fieldID] ?? 0,
    memberCode: data[fieldMemberCode] ?? "",
    pin: data[fieldPin] ?? "",
    expiredDate: data[fieldExpiredDate] != null ? DateTime.tryParse(data[fieldExpiredDate]) : DateTime.now(),
    voucherCode: data[fieldVoucherCode] ?? "",
  );

  @override
  String toString() => "PinModel(id: $id, memberCode: $memberCode, pin: $pin, expiredDate: $expiredDate, voucherCode: $voucherCode)\n";
}
