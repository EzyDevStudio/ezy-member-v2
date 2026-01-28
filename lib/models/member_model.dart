import 'package:ezymember/models/branch_model.dart';
import 'package:ezymember/models/member_card_model.dart';
import 'package:ezymember/models/voucher_model.dart';

const String fieldCompanyID = "company_id";
const String fieldIsMember = "is_member";
const String fieldIsExpired = "is_expired";
const String fieldCredit = "credit";
const String fieldPoint = "point";
const String fieldReferralCode = "referral_code";
const String fieldCompanyName = "company_name";
const String fieldCompanyLogo = "company_logo";

class MemberModel {
  static const String keyMember = "members";

  final String companyID;
  final bool isMember;
  final bool isExpired;
  final double credit;
  final int point;
  final String referralCode;
  final String companyName;
  final String companyLogo;
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
    this.referralCode = "",
    this.companyName = "",
    this.companyLogo = "",
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
    isExpired: data[fieldIsExpired] ?? true,
    credit: (data[fieldCredit] ?? 0).toDouble(),
    point: data[fieldPoint] ?? 0,
    referralCode: data[fieldReferralCode] ?? "",
    companyName: data[fieldCompanyName] ?? "",
    companyLogo: data[fieldCompanyLogo] ?? "",
    normalVoucherCount: data[VoucherModel.keyNormalVoucher] ?? 0,
    specialVoucherCount: data[VoucherModel.keySpecialVoucher] ?? 0,
    memberCard: data[MemberCardModel.keyMemberCard] != null
        ? MemberCardModel.fromJson(Map<String, dynamic>.from(data[MemberCardModel.keyMemberCard]))
        : MemberCardModel.empty(),
    branch: data[BranchModel.keyBranch] != null ? BranchModel.fromJson(Map<String, dynamic>.from(data[BranchModel.keyBranch])) : BranchModel.empty(),
  );

  String toCompare() => "$companyName ${memberCard.memberCardNumber} ${memberCard.cardDesc}";

  @override
  String toString() =>
      "MemberDetailModel(companyID: $companyID, isMember: $isMember, isExpired: $isExpired, credit: $credit, point: $point, referralCode: $referralCode, companyName: $companyName, companyLogo: $companyLogo, normalVoucherCount: $normalVoucherCount, specialVoucherCount: $specialVoucherCount)"
      "\nmemberCard: ${memberCard.toString()}"
      "\nbranch: ${branch.toString()})\n";
}
