import 'package:ezymember/helpers/location_helper.dart';
import 'package:ezymember/models/timeline_model.dart';
import 'package:ezymember/services/remote/api_service.dart';
import 'package:get/get.dart';

class TimelineController extends GetxController {
  final ApiService _api = ApiService();
  final int _limit = 10;

  var isLoading = false.obs;
  var timelines = <TimelineModel>[].obs;

  bool hasMore = true;
  int _offset = 0;

  void reset() {
    timelines.clear();
    hasMore = true;
    _offset = 0;
  }

  Future<void> loadTimelines({String? companyID, String? memberCode, bool isLoadMore = false}) async {
    if (isLoading.value || !hasMore) return;

    isLoading.value = true;

    final Coordinate? c = await LocationHelper.getCurrentCoordinate();

    final Map<String, dynamic> data = {
      "limit": _limit,
      "offset": _offset,
      if (c != null) "city": c.city,
      if (companyID != null) "company_id": companyID,
      if (memberCode != null) "member_code": memberCode,
    };

    final response = await _api.get(endPoint: "get-all-timeline", module: "TimelineController - loadTimelines", data: data);

    if (response == null || response.data[TimelineModel.keyTimeline] == null) {
      isLoading.value = false;
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> list = response.data[TimelineModel.keyTimeline] ?? [];

      if (!isLoadMore) timelines.clear();

      timelines.addAll(list.map((e) => TimelineModel.fromJson(Map<String, dynamic>.from(e))));
      _offset += list.length;

      if (list.length < _limit) hasMore = false;
    }

    isLoading.value = false;
  }
}
