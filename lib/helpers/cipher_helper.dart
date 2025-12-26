import 'package:encrypt/encrypt.dart';

class CipherHelper {
  final key = Key.fromUtf8("thisencryptionworksforezyseries!");
  final iv = IV.fromUtf8("justezyseriesuse");

  Future<String> encryption(String text) async {
    final e = Encrypter(AES(key, mode: AESMode.cbc));
    final encryptedData = e.encrypt(text, iv: iv);

    return encryptedData.base64;
  }
}
