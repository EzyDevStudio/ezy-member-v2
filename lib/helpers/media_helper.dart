import 'dart:developer';

import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/helpers/permission_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MediaHelper {
  static final ImagePicker _picker = ImagePicker();
  static const int maxFileSizeInBytes = 5 * 1024 * 1024;

  static Future<XFile?> processImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final granted = await PermissionHelper.checkAndRequestCamera();
      if (!granted) return null;
    }

    if (source == ImageSource.gallery) {
      final granted = await PermissionHelper.checkAndRequestGallery();
      if (!granted) return null;
    }

    try {
      final XFile? xFile = await _picker.pickImage(source: source, imageQuality: 85);

      if (xFile == null) return null;

      final bytes = await xFile.readAsBytes();

      if (bytes.length > maxFileSizeInBytes) {
        MessageHelper.error(message: Globalization.msgImageSizeExceed.tr);
        return null;
      }

      return xFile;
    } catch (e) {
      log("MediaHelper - processImage", time: DateTime.now(), error: e, name: "Unknown Error");
      return null;
    }
  }
}
