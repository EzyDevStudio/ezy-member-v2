const String fieldID = "id";
const String fieldMemberCode = "member_code";
const String fieldDocNo = "doc_no";
const String fieldDocAmount = "doc_amount";
const String fieldPointDescription = "point_description";
const String fieldPoint = "point";
const String fieldRemainingPoint = "remaining_point";
const String fieldBranchCode = "branch_code";
const String fieldCounterCode = "counter_code";
const String fieldAdminID = "admin_id";
const String fieldCompanyKey = "company_key";
const String fieldTransactionDate = "transaction_date";
const String fieldBranchName = "branch_name";
const String fieldCounterDesc = "counter_desc";

class PointModel {
  static const String keyPoint = "points";

  final int id;
  final String memberCode;
  final String docNo;
  final double docAmount;
  final String pointDescription;
  final double point;
  final double remainingPoint;
  final String branchCode;
  final String counterCode;
  final String adminID;
  final String companyKey;
  final int transactionDate;
  final String branchName;
  final String counterDesc;

  PointModel({
    this.id = 0,
    this.memberCode = "",
    this.docNo = "",
    this.docAmount = 0.0,
    this.pointDescription = "",
    this.point = 0.0,
    this.remainingPoint = 0.0,
    this.branchCode = "",
    this.counterCode = "",
    this.adminID = "",
    this.companyKey = "",
    this.transactionDate = 0,
    this.branchName = "",
    this.counterDesc = "",
  });

  PointModel.empty() : this();

  factory PointModel.fromJson(Map<String, dynamic> data) => PointModel(
    id: data[fieldID] ?? 0,
    memberCode: data[fieldMemberCode] ?? "",
    docNo: data[fieldDocNo] ?? "",
    docAmount: (data[fieldDocAmount] ?? 0).toDouble(),
    pointDescription: data[fieldPointDescription] ?? "",
    point: (data[fieldPoint] ?? 0).toDouble(),
    remainingPoint: (data[fieldRemainingPoint] ?? 0).toDouble(),
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
      "PointModel(id: $id, memberCode: $memberCode, docNo: $docNo, docAmount: $docAmount, pointDescription: $pointDescription, point: $point, remainingPoint: $remainingPoint, branchCode: $branchCode, counterCode: $counterCode, adminID: $adminID, companyKey: $companyKey, transactionDate: $transactionDate, branchName: $branchName, counterDesc: $counterDesc)\n";
}
