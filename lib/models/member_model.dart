import 'package:ezy_member_v2/models/branch_model.dart';
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
  MemberCardModel memberCard;
  BranchModel branch;

  MemberModel({
    this.companyID = "",
    this.isMember = false,
    this.isExpired = true,
    this.credit = 0.0,
    this.point = 0,
    this.normalVoucherCount = 0,
    this.specialVoucherCount = 0,
    MemberCardModel? memberCard,
    BranchModel? branch,
  }) : memberCard = memberCard ?? MemberCardModel.empty(),
       branch = branch ?? BranchModel.empty();

  MemberModel.empty() : this();

  factory MemberModel.fromJson(Map<String, dynamic> data) => MemberModel(
    companyID: data[fieldCompanyID] ?? "",
    isMember: data[fieldIsMember] ?? false,
    isExpired: data[fieldIsExpired] ?? false,
    credit: (data[fieldCredit] ?? 0).toDouble(),
    point: data[fieldPoint] ?? 0,
    normalVoucherCount: data[VoucherModel.keyNormalVoucher] ?? 0,
    specialVoucherCount: data[VoucherModel.keySpecialVoucher] ?? 0,
    memberCard: data[MemberCardModel.keyMemberCard] != null
        ? MemberCardModel.fromJson(Map<String, dynamic>.from(data[MemberCardModel.keyMemberCard]))
        : MemberCardModel.empty(),
    branch: data[BranchModel.keyBranch] != null ? BranchModel.fromJson(Map<String, dynamic>.from(data[BranchModel.keyBranch])) : BranchModel.empty(),
  );

  @override
  String toString() =>
      "MemberDetailModel(companyID: $companyID, isMember: $isMember, isExpired: $isExpired, credit: $credit, point: $point, normalVoucherCount: $normalVoucherCount, specialVoucherCount: $specialVoucherCount)"
      "\nmemberCard: ${memberCard.toString()}"
      "\nbranch: ${branch.toString()})\n";
}
