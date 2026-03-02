const String fieldID = "id";
const String fieldMemberCode = "member_code";
const String fieldDocNo = "doc_no";
const String fieldDocAmount = "doc_amount";
const String fieldCreditDescription = "credit_description";
const String fieldCredit = "credit";
const String fieldRemainingCredit = "remaining_credit";
const String fieldBranchName = "branch_name";
const String fieldCounterName = "counter_name";
const String fieldUserID = "user_id";
const String fieldCompanyID = "company_id";
const String fieldTransactionDate = "transaction_date";

class CreditModel {
  static const String keyCredit = "credits";

  final int id;
  final String memberCode;
  final String docNo;
  final double docAmount;
  final String creditDescription;
  final double credit;
  final double remainingCredit;
  final String branchName;
  final String counterName;
  final String userID;
  final String companyID;
  final int transactionDate;

  CreditModel({
    this.id = 0,
    this.memberCode = "",
    this.docNo = "",
    this.docAmount = 0.0,
    this.creditDescription = "",
    this.credit = 0.0,
    this.remainingCredit = 0.0,
    this.branchName = "",
    this.counterName = "",
    this.userID = "",
    this.companyID = "",
    this.transactionDate = 0,
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
    branchName: data[fieldBranchName] ?? "",
    counterName: data[fieldCounterName] ?? "",
    userID: data[fieldUserID] ?? "",
    companyID: data[fieldCompanyID] ?? "",
    transactionDate: data[fieldTransactionDate] != null ? DateTime.tryParse(data[fieldTransactionDate])?.millisecondsSinceEpoch ?? 0 : 0,
  );

  @override
  String toString() =>
      "CreditModel(id: $id, memberCode: $memberCode, docNo: $docNo, docAmount: $docAmount, creditDescription: $creditDescription, credit: $credit, remainingCredit: $remainingCredit, branchName: $branchName, counterName: $counterName, userID: $userID, companyID: $companyID, transactionDate: $transactionDate)\n";
}
