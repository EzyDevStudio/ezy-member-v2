const String fieldID = "id";
const String fieldBatchCode = "batch_code";
const String fieldVoucherCode = "voucher_code";
const String fieldHolder = "holder";
const String fieldStatus = "status";
const String fieldRedeemMember = "redeem_member";
const String fieldRedeemDate = "redeem_date";
const String fieldRedeemCounter = "redeem_counter";
const String fieldDocNo = "doc_no";
const String fieldCreatedAt = "created_at";
const String fieldUsePointRedeem = "use_point_redeem";
const String fieldBatchDescription = "batch_description";
const String fieldDiscountValue = "discount_value";
const String fieldMinimumSpend = "minimum_spend";
const String fieldStartDate = "start_date";
const String fieldExpiredDate = "expired_date";
const String fieldEndCollectDate = "end_collect_date";
const String fieldQuantity = "quantity";
const String fieldTermsCondition = "terms_condition";
const String fieldCompanyID = "company_id";
const String fieldCompanyName = "company_name";
const String fieldCompanyLogo = "company_logo";
const String fieldBranchName = "branch_name";
const String fieldCounterDesc = "counter_desc";

class VoucherModel {
  static const String keyNormalVoucher = "normal_voucher";
  static const String keySpecialVoucher = "special_voucher";

  final int id;
  final String batchCode;
  final String voucherCode;
  final String holder;
  final String status;
  final String redeemMember;
  final int redeemDate;
  final String redeemCounter;
  final String docNo;
  final int createdAt;
  final int usePointRedeem;
  final String batchDescription;
  final int discountValue;
  final double minimumSpend;
  final int startDate;
  final int expiredDate;
  final int endCollectDate;
  final int quantity;
  final String termsCondition;
  final String companyID;
  final String companyName;
  final String companyLogo;
  final String branchName;
  final String counterDesc;

  VoucherModel({
    this.id = 0,
    this.batchCode = "",
    this.voucherCode = "",
    this.holder = "",
    this.status = "",
    this.redeemMember = "",
    this.redeemDate = 0,
    this.redeemCounter = "",
    this.docNo = "",
    this.createdAt = 0,
    this.usePointRedeem = 0,
    this.batchDescription = "",
    this.discountValue = 0,
    this.minimumSpend = 0.0,
    this.startDate = 0,
    this.expiredDate = 0,
    this.endCollectDate = 0,
    this.quantity = 0,
    this.termsCondition = "",
    this.companyID = "",
    this.companyName = "",
    this.companyLogo = "",
    this.branchName = "",
    this.counterDesc = "",
  });

  VoucherModel.empty() : this();

  factory VoucherModel.fromJson(Map<String, dynamic> data) => VoucherModel(
    id: data[fieldID] ?? 0,
    batchCode: data[fieldBatchCode] ?? "",
    voucherCode: data[fieldVoucherCode] ?? "",
    holder: data[fieldHolder] ?? "",
    status: data[fieldStatus] ?? "",
    redeemMember: data[fieldRedeemMember] ?? "",
    redeemDate: data[fieldRedeemDate] != null ? DateTime.tryParse(data[fieldRedeemDate])?.millisecondsSinceEpoch ?? 0 : 0,
    redeemCounter: data[fieldRedeemCounter] ?? "",
    docNo: data[fieldDocNo] ?? "",
    createdAt: data[fieldCreatedAt] != null ? DateTime.tryParse(data[fieldCreatedAt])?.millisecondsSinceEpoch ?? 0 : 0,
    usePointRedeem: data[fieldUsePointRedeem] ?? 0,
    batchDescription: data[fieldBatchDescription] ?? "",
    discountValue: data[fieldDiscountValue] ?? 0,
    minimumSpend: (data[fieldMinimumSpend] ?? 0).toDouble(),
    startDate: data[fieldStartDate] != null ? DateTime.tryParse(data[fieldStartDate])?.millisecondsSinceEpoch ?? 0 : 0,
    expiredDate: data[fieldExpiredDate] != null ? DateTime.tryParse(data[fieldExpiredDate])?.millisecondsSinceEpoch ?? 0 : 0,
    endCollectDate: data[fieldEndCollectDate] != null ? DateTime.tryParse(data[fieldEndCollectDate])?.millisecondsSinceEpoch ?? 0 : 0,
    quantity: data[fieldQuantity] ?? 0,
    termsCondition: data[fieldTermsCondition] ?? "",
    companyID: data[fieldCompanyID] ?? "",
    companyName: data[fieldCompanyName] ?? "",
    companyLogo: data[fieldCompanyLogo] ?? "",
    branchName: data[fieldBranchName] ?? "",
    counterDesc: data[fieldCounterDesc] ?? "",
  );

  @override
  String toString() =>
      "VoucherModel(id: $id, batchCode: $batchCode, voucherCode: $voucherCode, holder: $holder, status: $status, redeemMember: $redeemMember, redeemDate: $redeemDate, redeemCounter: $redeemCounter, docNo: $docNo, createdAt: $createdAt, usePointRedeem: $usePointRedeem, batchDescription: $batchDescription, discountValue: $discountValue, minimumSpend: $minimumSpend, startDate: $startDate, expiredDate: $expiredDate, endCollectDate: $endCollectDate, quantity: $quantity, termsCondition: $termsCondition, companyID: $companyID, companyName: $companyName, companyLogo: $companyLogo, branchName: $branchName, counterDesc: $counterDesc)\n";
}
