import 'package:ezy_member_v2/models/company_model.dart';
import 'package:ezy_member_v2/models/promotion_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:get/get.dart';

class PromotionController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var promotions = <PromotionModel>[].obs;

  Future<void> loadPromotions({CompanyModel? company}) async {
    isLoading.value = true;
    final List<PromotionModel> tmpPromotions = [];

    final response = await _api.get(
      endPoint: company == null ? "get-all-promotion-advertisement" : "get-branch-promotion",
      module: "PromotionController - loadPromotions",
      data: company == null ? null : {"company_id": company.companyID},
    );

    if (response == null || response.data[PromotionModel.keyPromotion] == null) {
      isLoading.value = false;
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> list = response.data[PromotionModel.keyPromotion];
      tmpPromotions.addAll(list.map((e) => PromotionModel.fromJson(Map<String, dynamic>.from(e))).toList());
    }

    isLoading.value = false;
    promotions.value = tmpPromotions;
  }
}
