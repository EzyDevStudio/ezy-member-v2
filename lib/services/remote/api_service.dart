import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezymember/constants/app_strings.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = "${AppStrings.serverUrl}/${AppStrings.serverDirectory}";

  static const String keyStatusCode = "status_code";

  Future<Response?> get<T>({String? baseUrl, required String endPoint, required String module, Map<String, dynamic>? data}) async {
    final url = "${baseUrl ?? _baseUrl}/$endPoint";

    try {
      final response = await _dio.get(
        url,
        queryParameters: data,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      return response;
    } on DioException catch (e) {
      _showLog(e, "Dio Error", module, url);
      return null;
    } catch (e) {
      _showLog(e, "Unknown Error", module, url);
      return null;
    }
  }

  Future<Response?> post<T>({required String endPoint, required String module, Map<String, dynamic>? data, String? memberToken}) async {
    final url = "$_baseUrl/$endPoint";

    try {
      final response = await _dio.post(
        url,
        data: data,
        options: Options(headers: {"Authorization": "Bearer $memberToken", "Content-Type": "application/json"}),
      );

      return response;
    } on DioException catch (e) {
      _showLog(e, "Dio Error", module, url);
      return null;
    } catch (e) {
      _showLog(e, "Unknown Error", module, url);
      return null;
    }
  }

  Future<Response?> postFile<T>({
    required File file,
    required Map<String, dynamic> data,
    required String endPoint,
    required String memberToken,
    required String module,
  }) async {
    final url = "$_baseUrl/$endPoint";

    try {
      String fileName = file.path.split("/").last;
      FormData formData = FormData();

      data.forEach((key, value) => formData.fields.add(MapEntry(key, value.toString())));
      formData.files.add(MapEntry("media", await MultipartFile.fromFile(file.path, filename: fileName)));

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $memberToken", "Content-Type": "multipart/form-data"}),
      );

      return response;
    } on DioException catch (e) {
      _showLog(e, "Dio Error", module, url);
      return null;
    } catch (e) {
      _showLog(e, "Unknown Error", module, url);
      return null;
    }
  }

  void _showLog(Object error, String name, String module, String url) => log("$module $url", time: DateTime.now(), error: error, name: name);
}
