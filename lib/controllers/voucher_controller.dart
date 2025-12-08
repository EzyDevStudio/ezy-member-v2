import 'package:ezy_member_v2/models/company_model.dart';
import 'package:ezy_member_v2/models/voucher_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:get/get.dart';

class VoucherController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var vouchers = <VoucherModel>[].obs;

  Future<void> loadVouchers(String memberCode, int checkStart) async {
    isLoading.value = true;
    final List<VoucherModel> tmpVouchers = [];

    final Map<String, dynamic> data = {"member_code": memberCode, "check_start": checkStart};

    final response = await _api.get(
      endPoint: "get-all-voucher",
      data: data,
      module: "VoucherController - loadVouchers",
    );

    if (response == null || (response.data[VoucherModel.keyNormalVoucher] == null && response.data[VoucherModel.keySpecialVoucher] == null)) {
      isLoading.value = false;
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> normalList = response.data["normal_voucher"] ?? [];
      final List<dynamic> specialList = response.data["special_voucher"] ?? [];

      tmpVouchers.addAll(normalList.map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e))).toList());
      tmpVouchers.addAll(specialList.map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e))).toList());
    }

    isLoading.value = false;
    vouchers.value = tmpVouchers;
  }

  Future<void> loadCollectableVouchers({required String memberCode, required String publicKey, required String privateKey}) async {
    isLoading.value = true;

    final Map<String, dynamic> data = {"member_code": memberCode};

    final List<VoucherModel> tmpVouchers = [];

    final response = await _api.get(
      endPoint: "get-all-collectable-voucher",
      module: "VoucherController - loadCollectableVouchers",
      data: data,
    );

    if (response == null || response.data[CompanyModel.keyCompany] == null) {
      isLoading.value = false;
      return;
    }

    final List<dynamic> list = response.data[CompanyModel.keyCompany];

    for (var data in list) {
      for (var voucher in data[VoucherModel.keyNormalVoucher]) {
        final tmpVoucher = VoucherModel.fromJson(Map<String, dynamic>.from(voucher));
        tmpVouchers.add(tmpVoucher);
      }
    }

    isLoading.value = false;
    vouchers.value = tmpVouchers;
  }
}
