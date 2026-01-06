import 'package:ezy_member_v2/language/globalization.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'enum.dart';

class AppStrings {
  // App Name
  static const String appName = "EzyMember";

  // App Server Url
  // static const String serverUrl = "http://127.0.0.1:8000";
  static const String serverUrl = "http://192.168.0.171:8000";
  static const String serverDirectory = "api";

  Map<HistoryType, String> historyTypes = {
    HistoryType.all: Globalization.all.tr,
    HistoryType.point: Globalization.points.tr,
    HistoryType.voucher: Globalization.vouchers.tr,
    HistoryType.credit: Globalization.credits.tr,
  };
  Map<ImageSource, String> imageSrc = {ImageSource.camera: Globalization.camera.tr, ImageSource.gallery: Globalization.gallery.tr};
  Map<String, String> genders = {"M": Globalization.male.tr, "F": Globalization.female.tr, "O": Globalization.preferNotToSay.tr};
  Map<String, String> idTypes = {"nric": "NRIC", "brn": "BRN", "passport": "PASSPORT", "army": "ARMY"};
}
