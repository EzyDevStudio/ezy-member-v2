import 'dart:typed_data';

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

  Future<void> updateImage(Uint8List bytes) async {
    if (memberProfile.value == null) return;
    final updatedProfile = memberProfile.value!.copyWith(image: bytes);
    await _storage.saveMemberProfile(updatedProfile);
    memberProfile.value = updatedProfile;
  }

  Future<void> updateBackgroundImage(Uint8List bytes) async {
    if (memberProfile.value == null) return;
    final updatedProfile = memberProfile.value!.copyWith(backgroundImage: bytes);
    await _storage.saveMemberProfile(updatedProfile);
    memberProfile.value = updatedProfile;
  }

  Future<void> updatePersonalInvoiceImage(Uint8List bytes) async {
    if (memberProfile.value == null) return;
    final updatedProfile = memberProfile.value!.copyWith(personalInvoice: bytes);
    await _storage.saveMemberProfile(updatedProfile);
    memberProfile.value = updatedProfile;
  }

  Future<void> updateCompanyInvoiceImage(Uint8List bytes) async {
    if (memberProfile.value == null) return;
    final updatedProfile = memberProfile.value!.copyWith(workingInvoice: bytes);
    await _storage.saveMemberProfile(updatedProfile);
    memberProfile.value = updatedProfile;
  }
}
