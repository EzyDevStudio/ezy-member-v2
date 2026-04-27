import 'dart:developer';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:ezymember/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = AppStrings.serverUrl;
  final String _directory = AppStrings.serverDirectory;

  static const String keyStatusCode = "status_code";

  Future<Response?> get<T>({String? baseUrl, required String endPoint, required String module, Map<String, dynamic>? data}) async {
    final url = "${baseUrl ?? _baseUrl}/$_directory/$endPoint";

    try {
      final response = await _dio.get(
        url,
        queryParameters: data,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      debugPrint(response.toString());

      return response;
    } on DioException catch (e) {
      _showLog(e, "Dio Error", module, url);
      return null;
    } catch (e) {
      _showLog(e, "Unknown Error", module, url);
      return null;
    }
  }

  Future<Response?> post<T>({
    String? baseUrl,
    required String endPoint,
    required String module,
    Map<String, dynamic>? data,
    String? memberToken,
  }) async {
    final url = "${baseUrl ?? _baseUrl}/$_directory/$endPoint";

    try {
      final response = await _dio.post(
        url,
        data: data,
        options: Options(headers: {"Authorization": "Bearer $memberToken", "Content-Type": "application/json"}),
      );

      debugPrint(response.toString());

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
    required XFile file,
    required Map<String, dynamic> data,
    required String endPoint,
    required String memberToken,
    required String module,
  }) async {
    final url = "$_baseUrl/$_directory/$endPoint";

    try {
      String fileName = file.name;
      FormData formData = FormData();
      Uint8List bytes = await file.readAsBytes();

      data.forEach((key, value) => formData.fields.add(MapEntry(key, value.toString())));
      formData.files.add(MapEntry("media", MultipartFile.fromBytes(bytes, filename: fileName)));

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $memberToken", "Content-Type": "multipart/form-data"}),
      );

      debugPrint(response.toString());

      return response;
    } on DioException catch (e) {
      _showLog(e, "Dio Error", module, url);
      return null;
    } catch (e) {
      _showLog(e, "Unknown Error", module, url);
      return null;
    }
  }

  Future<Uint8List?> downloadImageAsBytes(String url) async {
    if (url.isEmpty) return null;

    try {
      final response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));

      return Uint8List.fromList(response.data);
    } catch (e) {
      return null;
    }
  }

  void _showLog(Object error, String name, String module, String url) => log("$module $url", time: DateTime.now(), error: error, name: name);
}
