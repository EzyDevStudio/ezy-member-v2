import 'package:ezy_member_v2/constants/enum.dart';
import 'package:ezy_member_v2/models/credit_model.dart';
import 'package:ezy_member_v2/models/history_model.dart';
import 'package:ezy_member_v2/models/point_model.dart';
import 'package:ezy_member_v2/models/voucher_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var credits = <CreditModel>[].obs;
  var points = <PointModel>[].obs;
  var vouchers = <VoucherModel>[].obs;
  var histories = <HistoryModel>[].obs;

  Future<List<T>> _fetchHistories<T>(
    String memberCode,
    String endPoint,
    String module,
    String listKey,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final Map<String, dynamic> data = {"member_code": memberCode};
    final response = await _api.get(endPoint: endPoint, module: module, data: data);

    if (response == null || response.data[listKey] == null) return [];

    final List<dynamic> list = response.data[listKey] ?? [];

    return list.map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> loadCredits(String memberCode) async {
    isLoading.value = true;

    credits.value = await _fetchHistories(
      memberCode,
      "get-credit-history",
      "HistoryController - loadCredits",
      CreditModel.keyCredit,
      (json) => CreditModel.fromJson(json),
    );

    isLoading.value = false;
  }

  Future<void> loadPoints(String memberCode) async {
    isLoading.value = true;

    points.value = await _fetchHistories(
      memberCode,
      "get-point-history",
      "HistoryController - loadPoints",
      PointModel.keyPoint,
      (json) => PointModel.fromJson(json),
    );

    isLoading.value = false;
  }

  Future<void> loadVouchers(String memberCode) async {
    isLoading.value = true;

    final normalVouchers = await _fetchHistories(
      memberCode,
      "get-voucher-history",
      "HistoryController - loadVouchers",
      VoucherModel.keyNormalVoucher,
      (json) => VoucherModel.fromJson(json),
    );

    final specialVouchers = await _fetchHistories(
      memberCode,
      "get-voucher-history",
      "HistoryController - loadVouchers",
      VoucherModel.keySpecialVoucher,
      (json) => VoucherModel.fromJson(json),
    );

    vouchers.value = [...normalVouchers, ...specialVouchers];
    isLoading.value = false;
  }

  Future<void> loadHistories(String memberCode) async {
    isLoading.value = true;

    await loadCredits(memberCode);
    await loadPoints(memberCode);
    await loadVouchers(memberCode);

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
    isLoading.value = false;
  }
}
