import 'dart:ui';

import 'package:hive_flutter/hive_flutter.dart';

class SettingsStorageService {
  static final SettingsStorageService _instance = SettingsStorageService._internal();
  factory SettingsStorageService() => _instance;
  SettingsStorageService._internal();

  static const String _boxName = "SettingsBox";
  static const String _keyLanguage = "language";

  Box<String>? _box;

  Future<void> init() async => _box = await Hive.openBox<String>(_boxName);

  Future<void> saveLocale(Locale locale) async => await _box?.put(_keyLanguage, "${locale.languageCode}_${locale.countryCode}");

  Locale? getLocale() {
    final value = _box?.get(_keyLanguage);

    if (value == null) return null;

    final parts = value.split("_");

    return Locale(parts[0], parts.length > 1 ? parts[1] : null);
  }

  Future<void> clearLanguage() async => await _box?.delete(_keyLanguage);

  bool hasLocale() => _box?.containsKey(_keyLanguage) ?? false;
}
