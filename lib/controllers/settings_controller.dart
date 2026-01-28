import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/services/local/settings_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final SettingsStorageService _storageService = SettingsStorageService();
  final Rx<Locale> locale = Globalization.defaultLocale.obs;

  Locale get currentLocale => locale.value;

  @override
  void onInit() {
    super.onInit();

    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    await _storageService.init();

    final savedLocale = _storageService.getLocale();

    if (savedLocale != null) locale.value = savedLocale;

    Get.updateLocale(locale.value);
  }

  Future<void> changeLanguage(Locale newLocale) async {
    locale.value = newLocale;
    Get.updateLocale(newLocale);
    await _storageService.saveLocale(newLocale);
  }
}
