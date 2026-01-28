import 'package:ezymember/models/promotion_model.dart';
import 'package:ezymember/services/remote/api_service.dart';
import 'package:get/get.dart';

class PromotionController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var promotions = <PromotionModel>[].obs;

  Future<void> loadPromotions({String? companyID}) async {
    isLoading.value = true;
    promotions.clear();

    final response = await _api.get(
      endPoint: companyID == null ? "get-all-promotion-advertisement" : "get-branch-promotion",
      module: "PromotionController - loadPromotions",
      data: companyID == null ? null : {"company_id": companyID},
    );

    if (response == null || response.data[PromotionModel.keyPromotion] == null) {
      isLoading.value = false;
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> list = response.data[PromotionModel.keyPromotion];

      promotions.addAll(list.map((e) => PromotionModel.fromJson(Map<String, dynamic>.from(e))).toList());
    }

    isLoading.value = false;
  }
}
