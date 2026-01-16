import 'package:ezy_member_v2/models/category_model.dart';
import 'package:ezy_member_v2/services/remote/api_service.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  final ApiService _api = ApiService();

  var isLoading = false.obs;
  var categories = <CategoryModel>[].obs;

  Future<void> loadCategories() async {
    isLoading.value = true;

    final response = await _api.get(endPoint: "get-all-category", module: "CategoryController - loadCategories");

    if (response == null || response.data[CategoryModel.keyCategory] == null) {
      isLoading.value = false;
      return;
    }

    if (response.data[ApiService.keyStatusCode] == 200) {
      final List<dynamic> list = response.data[CategoryModel.keyCategory] ?? [];

      categories.value = list.map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    isLoading.value = false;
  }
}
