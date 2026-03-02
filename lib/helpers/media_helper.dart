import 'dart:developer';
import 'dart:io';

import 'package:ezymember/helpers/message_helper.dart';
import 'package:ezymember/helpers/permission_helper.dart';
import 'package:ezymember/language/globalization.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MediaHelper {
  static final ImagePicker _picker = ImagePicker();
  static const int maxFileSizeInBytes = 5 * 1024 * 1024;

  static Future<File?> processImage(ImageSource source) async {
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

      final File originalFile = File(xFile.path);
      final int fileSize = await originalFile.length();

      if (fileSize > maxFileSizeInBytes) {
        MessageHelper.show(Globalization.msgImageSizeExceed.tr);
        return null;
      }

      final String directory = originalFile.parent.path;
      final String extension = originalFile.path.split(".").last;
      final String path = "$directory/${DateTime.now().millisecondsSinceEpoch}.$extension";
      final File currentFile = await originalFile.copy(path);

      return currentFile;
    } catch (e) {
      log("MediaHelper - processImage", time: DateTime.now(), error: e, name: "Unknown Error");
      return null;
    }
  }
}
