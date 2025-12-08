import 'package:ezy_member_v2/hive/member_profile_hive.dart';
import 'package:ezy_member_v2/services/local/member_profile_storage_service.dart';
import 'package:get/get.dart';

class MemberHiveController extends GetxController {
  final _storage = MemberProfileStorageService();

  var memberProfile = Rxn<MemberProfileHive>();

  bool get isSignIn => memberProfile.value?.memberCode.isNotEmpty == true;

  @override
  void onInit() {
    super.onInit();

    loadMemberHive();
  }

  Future<void> loadMemberHive() async {
    memberProfile.value = _storage.getMemberProfile();
  }

  Future<void> signIn(MemberProfileHive profile) async {
    await _storage.saveMemberProfile(profile);
    memberProfile.value = profile;
  }

  Future<void> signOut() async {
    await _storage.clearMemberProfile();
    memberProfile.value = null;
  }
}
