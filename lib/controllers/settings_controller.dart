import 'package:ezy_member_v2/services/local/settings_storage_service.dart';
import 'package:ezy_member_v2/translations/translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final SettingsStorageService _storageService = SettingsStorageService();

  var lang = "".obs;

  String get language => lang.value;

  @override
  void onInit() {
    super.onInit();

    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    await _storageService.init();

    if (_storageService.hasLanguage()) {
      lang.value = _storageService.getLanguage() ?? AppTranslations.defaultLanguage;
      Get.updateLocale(Locale(lang.value));
    } else {
      lang.value = AppTranslations.defaultLanguage;
      Get.updateLocale(Locale(AppTranslations.defaultLanguage));
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    Locale locale = Locale(languageCode);
    Get.updateLocale(locale);

    await _storageService.saveLanguage(languageCode);

    lang.value = languageCode;
  }
}
