import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/models/credit_model.dart';
import 'package:ezy_member_v2/models/point_model.dart';
import 'package:ezy_member_v2/models/voucher_model.dart';

class HistoryModel {
  final HistoryType type;
  final int transactionDate;
  final CreditModel? credit;
  final PointModel? point;
  final VoucherModel? voucher;

  HistoryModel({this.type = HistoryType.all, this.transactionDate = 0, this.credit, this.point, this.voucher});

  HistoryModel.empty() : this();

  @override
  String toString() =>
      "HistoryModel(type: $type, transactionDate: $transactionDate"
      "\ncredit: ${credit.toString()}"
      "\npoint: ${point.toString()}"
      "\nvoucher: ${voucher.toString()})\n";
}
