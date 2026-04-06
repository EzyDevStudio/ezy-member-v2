import 'dart:typed_data';

import 'package:ezymember/constants/enum.dart';
import 'package:ezymember/hive/member_profile_hive.dart';
import 'package:ezymember/services/local/member_profile_storage_service.dart';
import 'package:get/get.dart';

class MemberHiveController extends GetxController {
  final _storage = MemberProfileStorageService();

  var memberProfile = Rxn<MemberProfileHive>();

  bool get isSignIn => memberProfile.value?.memberCode.isNotEmpty == true;
  Uint8List? get image => memberProfile.value?.image;
  Uint8List? get backgroundImage => memberProfile.value?.backgroundImage;
  Uint8List? get personalInvoice => memberProfile.value?.personalInvoice;
  Uint8List? get workingInvoice => memberProfile.value?.workingInvoice;

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

  Future<void> updateMedia(Uint8List bytes, MediaType type) async {
    if (memberProfile.value == null) return;

    final profile = memberProfile.value!;
    MemberProfileHive updatedProfile;

    switch (type) {
      case MediaType.image:
        updatedProfile = profile.copyWith(image: bytes);
        break;
      case MediaType.background:
        updatedProfile = profile.copyWith(backgroundImage: bytes);
        break;
      case MediaType.personalInvoice:
        updatedProfile = profile.copyWith(personalInvoice: bytes);
        break;
      case MediaType.workingInvoice:
        updatedProfile = profile.copyWith(workingInvoice: bytes);
        break;
    }

    await _storage.saveMemberProfile(updatedProfile);
    memberProfile.value = updatedProfile;
  }

  Future<void> clearMedia(MediaType type) async {
    if (memberProfile.value == null) return;

    final updatedProfile = memberProfile.value!.clearMedia(type);
    await _storage.saveMemberProfile(updatedProfile);
    memberProfile.value = updatedProfile;
  }
}
