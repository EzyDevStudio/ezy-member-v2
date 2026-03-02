const String fieldID = "id";
const String fieldMemberCode = "member_code";
const String fieldDocNo = "doc_no";
const String fieldDocAmount = "doc_amount";
const String fieldPointDescription = "point_description";
const String fieldPoint = "point";
const String fieldRemainingPoint = "remaining_point";
const String fieldBranchName = "branch_name";
const String fieldCounterName = "counter_name";
const String fieldUserID = "user_id";
const String fieldCompanyID = "company_id";
const String fieldTransactionDate = "transaction_date";

class PointModel {
  static const String keyPoint = "points";

  final int id;
  final String memberCode;
  final String docNo;
  final double docAmount;
  final String pointDescription;
  final int point;
  final int remainingPoint;
  final String branchName;
  final String counterName;
  final String userID;
  final String companyID;
  final int transactionDate;

  PointModel({
    this.id = 0,
    this.memberCode = "",
    this.docNo = "",
    this.docAmount = 0.0,
    this.pointDescription = "",
    this.point = 0,
    this.remainingPoint = 0,
    this.branchName = "",
    this.counterName = "",
    this.userID = "",
    this.companyID = "",
    this.transactionDate = 0,
  });

  PointModel.empty() : this();

  factory PointModel.fromJson(Map<String, dynamic> data) => PointModel(
    id: data[fieldID] ?? 0,
    memberCode: data[fieldMemberCode] ?? "",
    docNo: data[fieldDocNo] ?? "",
    docAmount: (data[fieldDocAmount] ?? 0).toDouble(),
    pointDescription: data[fieldPointDescription] ?? "",
    point: data[fieldPoint] ?? 0,
    remainingPoint: data[fieldRemainingPoint] ?? 0,
    branchName: data[fieldBranchName] ?? "",
    counterName: data[fieldCounterName] ?? "",
    userID: data[fieldUserID] ?? "",
    companyID: data[fieldCompanyID] ?? "",
    transactionDate: data[fieldTransactionDate] != null ? DateTime.tryParse(data[fieldTransactionDate])?.millisecondsSinceEpoch ?? 0 : 0,
  );

  @override
  String toString() =>
      "PointModel(id: $id, memberCode: $memberCode, docNo: $docNo, docAmount: $docAmount, pointDescription: $pointDescription, point: $point, remainingPoint: $remainingPoint, branchName: $branchName, counterName: $counterName, userID: $userID, companyID: $companyID, transactionDate: $transactionDate)\n";
}
