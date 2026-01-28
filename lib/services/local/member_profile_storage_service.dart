import 'package:ezymember/hive/member_profile_hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MemberProfileStorageService {
  static final MemberProfileStorageService _instance = MemberProfileStorageService._internal();
  factory MemberProfileStorageService() => _instance;
  MemberProfileStorageService._internal();

  static const String _boxName = "memberProfileBox";
  static const String _keyName = "memberProfile";

  Box<MemberProfileHive>? _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(MemberProfileHiveAdapter());
    _box = await Hive.openBox<MemberProfileHive>(_boxName);
  }

  Future<void> saveMemberProfile(MemberProfileHive memberProfile) async => await _box?.put(_keyName, memberProfile);

  MemberProfileHive? getMemberProfile() => _box?.get(_keyName);

  Future<void> clearMemberProfile() async => await _box?.delete(_keyName);

  bool hasMemberProfile() => _box?.containsKey(_keyName) ?? false;
}
