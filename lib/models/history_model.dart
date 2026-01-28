import 'package:ezymember/constants/enum.dart';
import 'package:ezymember/models/credit_model.dart';
import 'package:ezymember/models/point_model.dart';
import 'package:ezymember/models/voucher_model.dart';

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
