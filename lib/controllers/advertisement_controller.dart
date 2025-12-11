import 'package:ezy_member_v2/models/advertisement_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:get/get.dart';

class AdvertisementController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var advertisements = <AdvertisementModel>[].obs;

  Future<void> loadAdvertisements({String? companyID}) async {
    isLoading.value = true;
    advertisements.clear();

    final response = await _api.get(
      endPoint: companyID == null ? "get-all-advertisement" : "get-branch-advertisement",
      module: "AdvertisementController - loadAdvertisements",
      data: companyID == null ? null : {"company_id": companyID},
    );

    if (response == null || response.data[AdvertisementModel.keyAdvertisement] == null) {
      isLoading.value = false;
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> list = response.data[AdvertisementModel.keyAdvertisement];

      advertisements.addAll(list.map((e) => AdvertisementModel.fromJson(Map<String, dynamic>.from(e))).toList());
    }

    isLoading.value = false;
  }
}
