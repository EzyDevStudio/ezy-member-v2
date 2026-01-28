import 'package:ezymember/constants/enum.dart';
import 'package:ezymember/models/credit_model.dart';
import 'package:ezymember/models/history_model.dart';
import 'package:ezymember/models/point_model.dart';
import 'package:ezymember/models/voucher_model.dart';
import 'package:ezymember/services/remote/api_service.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var credits = <CreditModel>[].obs;
  var points = <PointModel>[].obs;
  var vouchers = <VoucherModel>[].obs;
  var histories = <HistoryModel>[].obs;

  Future<void> loadHistories(String memberCode, {String? companyID}) async {
    isLoading.value = true;

    final Map<String, dynamic> data = {"member_code": memberCode, "company_id": companyID};
    final response = await _api.get(endPoint: "get-all-history", module: "HistoryController - loadHistories", data: data);

    if (response == null) {
      isLoading.value = false;
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> creditList = response.data[CreditModel.keyCredit] ?? [];
      final List<dynamic> pointList = response.data[PointModel.keyPoint] ?? [];
      final List<dynamic> normalList = response.data[VoucherModel.keyNormalVoucher] ?? [];
      final List<dynamic> specialList = response.data[VoucherModel.keySpecialVoucher] ?? [];

      credits.value = creditList.map((e) => CreditModel.fromJson(Map<String, dynamic>.from(e))).toList();
      points.value = pointList.map((e) => PointModel.fromJson(Map<String, dynamic>.from(e))).toList();
      vouchers.value = [
        ...normalList.map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e))),
        ...specialList.map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e))),
      ];

      histories.clear();

      for (var credit in credits) {
        histories.add(HistoryModel(type: HistoryType.credit, transactionDate: credit.transactionDate, credit: credit));
      }

      for (var point in points) {
        histories.add(HistoryModel(type: HistoryType.point, transactionDate: point.transactionDate, point: point));
      }

      for (var voucher in vouchers) {
        histories.add(HistoryModel(type: HistoryType.voucher, transactionDate: voucher.createdAt, voucher: voucher));
        histories.addIf(voucher.redeemDate != 0, HistoryModel(type: HistoryType.voucher, transactionDate: voucher.redeemDate, voucher: voucher));
      }

      histories.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    }

    isLoading.value = false;
  }
}
