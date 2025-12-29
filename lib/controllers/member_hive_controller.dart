import 'package:ezy_member_v2/hive/member_profile_hive.dart';
import 'package:ezy_member_v2/services/local/member_profile_storage_service.dart';
import 'package:get/get.dart';

class MemberHiveController extends GetxController {
  final _storage = MemberProfileStorageService();

  var memberProfile = Rxn<MemberProfileHive>();

  bool get isSignIn => memberProfile.value?.memberCode.isNotEmpty == true;
  String get backgroundImage => memberProfile.value != null ? memberProfile.value!.backgroundImage : "";
  String get image => memberProfile.value != null ? memberProfile.value!.image : "";

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

  Future<void> updateImage(String image) async {
    if (memberProfile.value == null) return;
    final updatedProfile = memberProfile.value!.copyWith(image: image);
    await _storage.saveMemberProfile(updatedProfile);
    memberProfile.value = updatedProfile;
  }

  Future<void> updateBackgroundImage(String image) async {
    if (memberProfile.value == null) return;
    final updatedProfile = memberProfile.value!.copyWith(backgroundImage: image);
    await _storage.saveMemberProfile(updatedProfile);
    memberProfile.value = updatedProfile;
  }
}
