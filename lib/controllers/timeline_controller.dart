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

    final response = await _api.get(
      endPoint: companyID == null ? "get-all-timeline" : "get-branch-timeline",
      module: "TimelineController - loadTimelines",
      data: companyID == null ? null : {"company_id": companyID},
    );

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
