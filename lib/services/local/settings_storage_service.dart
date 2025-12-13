import 'package:hive_flutter/hive_flutter.dart';

class SettingsStorageService {
  static final SettingsStorageService _instance = SettingsStorageService._internal();
  factory SettingsStorageService() => _instance;
  SettingsStorageService._internal();

  static const String _boxName = "SettingsBox";
  static const String _keyLanguage = "language";

  Box<String>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> saveLanguage(String languageCode) async => await _box?.put(_keyLanguage, languageCode);

  String? getLanguage() => _box?.get(_keyLanguage);

  Future<void> clearLanguage() async => await _box?.delete(_keyLanguage);

  bool hasLanguage() => _box?.containsKey(_keyLanguage) ?? false;
}
