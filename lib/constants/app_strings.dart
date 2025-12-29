import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'enum.dart';

class AppStrings {
  // App Name
  static const String appName = "EzyMember";

  // App Server Url
  static const String serverUrl = "http://127.0.0.1:8000";
  static const String serverDirectory = "api";

  Map<HistoryType, String> historyTypes = {
    HistoryType.all: "all".tr,
    HistoryType.point: "points".tr,
    HistoryType.voucher: "vouchers".tr,
    HistoryType.credit: "credits".tr,
  };
  Map<ImageSource, String> imageSrc = {ImageSource.camera: "camera".tr, ImageSource.gallery: "gallery".tr};
  Map<String, String> genders = {"M": "male".tr, "F": "female".tr, "O": "prefer_not_to_say".tr};
  Map<String, String> idTypes = {"nric": "NRIC", "brn": "BRN", "passport": "PASSPORT", "army": "ARMY"};
}
