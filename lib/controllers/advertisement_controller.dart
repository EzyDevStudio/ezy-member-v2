import 'package:ezy_member_v2/models/advertisement_model.dart';
import 'package:ezy_member_v2/models/company_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:get/get.dart';

class AdvertisementController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var advertisements = <AdvertisementModel>[].obs;

  Future<void> loadAdvertisements({CompanyModel? company}) async {
    isLoading.value = true;
    final List<AdvertisementModel> tmpAdvertisements = [];

    final response = await _api.get(
      endPoint: company == null ? "get-all-advertisement" : "get-branch-advertisement",
      module: "AdvertisementController - loadAdvertisements",
      data: company == null ? null : {"company_id": company.companyID},
    );

    if (response == null || response.data[AdvertisementModel.keyAdvertisement] == null) {
      isLoading.value = false;
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> list = response.data[AdvertisementModel.keyAdvertisement];
      tmpAdvertisements.addAll(list.map((e) => AdvertisementModel.fromJson(Map<String, dynamic>.from(e))).toList());
    }

    isLoading.value = false;
    advertisements.value = tmpAdvertisements;
  }
}
