import 'package:ezy_member_v2/models/member_card_model.dart';
import 'package:ezy_member_v2/models/voucher_model.dart';

const String fieldCompanyID = "company_id";
const String fieldIsMember = "is_member";
const String fieldIsExpired = "is_expired";
const String fieldCredit = "credit";
const String fieldPoint = "point";

class MemberModel {
  static const String keyMember = "members";

  final String companyID;
  final bool isMember;
  final bool isExpired;
  final double credit;
  final int point;
  final int normalVoucherCount;
  final int specialVoucherCount;
  MemberCardModel? memberCard;

  MemberModel({
    this.companyID = "",
    this.isMember = false,
    this.isExpired = true,
    this.credit = 0.0,
    this.point = 0,
    this.normalVoucherCount = 0,
    this.specialVoucherCount = 0,
    MemberCardModel? memberCard,
  }) : memberCard = memberCard ?? MemberCardModel.empty();

  MemberModel.empty() : this();

  factory MemberModel.fromJson(Map<String, dynamic> data) => MemberModel(
    companyID: data[fieldCompanyID] ?? "",
    isMember: data[fieldIsMember] ?? false,
    isExpired: data[fieldIsExpired] ?? false,
    credit: data[fieldCredit] != null ? (data[fieldCredit] is int ? (data[fieldCredit] as int).toDouble() : data[fieldCredit] as double) : 0.0,
    point: data[fieldPoint] ?? 0,
    normalVoucherCount: data[VoucherModel.keyNormalVoucher] ?? 0,
    specialVoucherCount: data[VoucherModel.keySpecialVoucher] ?? 0,
  );

  @override
  String toString() =>
      "MemberDetailModel(companyID: $companyID, isMember: $isMember, isExpired: $isExpired, credit: $credit, point: $point, normalVoucherCount: $normalVoucherCount, specialVoucherCount: $specialVoucherCount)"
      "\nmemberCard: ${memberCard.toString()})\n";
}
