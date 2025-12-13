import 'package:ezy_member_v2/helpers/location_helper.dart';
import 'package:ezy_member_v2/models/timeline_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:get/get.dart';

class TimelineController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var timelines = <TimelineModel>[].obs;

  Future<void> loadTimelines({String? companyID}) async {
    isLoading.value = true;
    timelines.clear();

    Map<String, dynamic>? data;

    final Coordinate? current = await LocationHelper.getCurrentCoordinate();

    if (current != null) data = {"city": current.city};
    if (companyID != null) (data ??= {})["company_id"] = companyID;

    final response = await _api.get(endPoint: "get-all-timeline", module: "TimelineController - loadTimelines", data: data);

    if (response == null || response.data[TimelineModel.keyTimeline] == null) {
      isLoading.value = false;
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> list = response.data[TimelineModel.keyTimeline];

      timelines.addAll(list.map((e) => TimelineModel.fromJson(Map<String, dynamic>.from(e))).toList());
    }

    isLoading.value = false;
  }
}
