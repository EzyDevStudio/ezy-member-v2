const String fieldID = "id";
const String fieldMemberCode = "member_code";
const String fieldDocNo = "doc_no";
const String fieldDocAmount = "doc_amount";
const String fieldCreditDescription = "credit_description";
const String fieldCredit = "credit";
const String fieldRemainingCredit = "remaining_credit";
const String fieldBranchCode = "branch_code";
const String fieldCounterCode = "counter_code";
const String fieldAdminID = "admin_id";
const String fieldCompanyKey = "company_key";
const String fieldTransactionDate = "transaction_date";
const String fieldBranchName = "branch_name";
const String fieldCounterDesc = "counter_desc";

class CreditModel {
  static const String keyCredit = "credits";

  final int id;
  final String memberCode;
  final String docNo;
  final double docAmount;
  final String creditDescription;
  final double credit;
  final double remainingCredit;
  final String branchCode;
  final String counterCode;
  final String adminID;
  final String companyKey;
  final int transactionDate;
  final String branchName;
  final String counterDesc;

  CreditModel({
    this.id = 0,
    this.memberCode = "",
    this.docNo = "",
    this.docAmount = 0.0,
    this.creditDescription = "",
    this.credit = 0.0,
    this.remainingCredit = 0.0,
    this.branchCode = "",
    this.counterCode = "",
    this.adminID = "",
    this.companyKey = "",
    this.transactionDate = 0,
    this.branchName = "",
    this.counterDesc = "",
  });

  CreditModel.empty() : this();

  factory CreditModel.fromJson(Map<String, dynamic> data) => CreditModel(
    id: data[fieldID] ?? 0,
    memberCode: data[fieldMemberCode] ?? "",
    docNo: data[fieldDocNo] ?? "",
    docAmount: (data[fieldDocAmount] ?? 0).toDouble(),
    creditDescription: data[fieldCreditDescription] ?? "",
    credit: (data[fieldCredit] ?? 0).toDouble(),
    remainingCredit: (data[fieldRemainingCredit] ?? 0).toDouble(),
    branchCode: data[fieldBranchCode] ?? "",
    counterCode: data[fieldCounterCode] ?? "",
    adminID: data[fieldAdminID] ?? "",
    companyKey: data[fieldCompanyKey] ?? "",
    transactionDate: data[fieldTransactionDate] != null ? DateTime.tryParse(data[fieldTransactionDate])?.millisecondsSinceEpoch ?? 0 : 0,
    branchName: data[fieldBranchName] ?? "",
    counterDesc: data[fieldCounterDesc] ?? "",
  );

  @override
  String toString() =>
      "CreditModel(id: $id, memberCode: $memberCode, docNo: $docNo, docAmount: $docAmount, creditDescription: $creditDescription, credit: $credit, remainingCredit: $remainingCredit, branchCode: $branchCode, counterCode: $counterCode, adminID: $adminID, companyKey: $companyKey, transactionDate: $transactionDate, branchName: $branchName, counterDesc: $counterDesc)\n";
}
