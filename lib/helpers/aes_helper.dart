import 'package:encrypt/encrypt.dart';

class AesHelper {

  static  String staticKey = "TkZcxWzmEzLkpXmRUhMfLGrB2NWefzNk";
  static  String staticIv = "RCk3zv7xgqeTwynS";

  static String encrypt(String text) {
    Key key = Key.fromBase64(staticKey);
    IV iv = IV.fromBase64(staticIv);

    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv);
    final encryptedBase64 = encrypted.base64;

    return encryptedBase64;
  }

  static String decrypt(String cipherText) {
    Key key = Key.fromBase64(staticKey);
    IV iv = IV.fromBase64(staticIv);

    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(cipherText), iv: iv);
    final decryptedText = decrypted;

    return decryptedText;
  }
}