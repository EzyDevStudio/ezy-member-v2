import 'package:ezymember/models/company_model.dart';
import 'package:ezymember/models/member_card_model.dart';

const String fieldIsMember = "is_member";
const String fieldCredit = "credit";
const String fieldPoint = "point";
const String fieldNormalCount = "normal_count";
const String fieldSpecialCount = "special_count";
const String fieldReferralCode = "referral_code";

class MemberModel {
  static const String keyMember = "members";

  final bool isMember;
  final double credit;
  final int point;
  final int normalCount;
  final int specialCount;
  final String referralCode;
  CompanyModel company;
  MemberCardModel memberCard;

  MemberModel({
    this.credit = 0.0,
    this.isMember = false,
    this.point = 0,
    this.normalCount = 0,
    this.specialCount = 0,
    this.referralCode = "",
    CompanyModel? company,
    MemberCardModel? memberCard,
  }) : company = company ?? CompanyModel.empty(),
       memberCard = memberCard ?? MemberCardModel.empty();

  MemberModel.empty() : this();

  factory MemberModel.fromJson(Map<String, dynamic> data) => MemberModel(
    isMember: data[fieldIsMember] ?? false,
    credit: (data[fieldCredit] ?? 0).toDouble(),
    point: data[fieldPoint] ?? 0,
    normalCount: data[fieldNormalCount] ?? 0,
    specialCount: data[fieldSpecialCount] ?? 0,
    referralCode: data[fieldReferralCode] ?? "",
    company: data[CompanyModel.keyCompany] != null
        ? CompanyModel.fromJson({}, Map<String, dynamic>.from(data[CompanyModel.keyCompany]))
        : CompanyModel.empty(),
    memberCard: data[MemberCardModel.keyMemberCard] != null
        ? MemberCardModel.fromJson(Map<String, dynamic>.from(data[MemberCardModel.keyMemberCard]))
        : MemberCardModel.empty(),
  );

  String toCompare() => "${company.companyName} ${memberCard.memberCardNumber} ${memberCard.cardDesc}";

  @override
  String toString() =>
      "MemberDetailModel(isMember: $isMember, credit: $credit, point: $point, normalCount: $normalCount, specialCount: $specialCount, referralCode: $referralCode)"
      "\ncompany: ${company.toString()})"
      "\nmemberCard: ${memberCard.toString()})\n";
}
