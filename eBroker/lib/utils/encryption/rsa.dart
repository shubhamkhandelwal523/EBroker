import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart' as d;

class RSAEncryption {
  final parser = RSAKeyParser();
  //encrypted data must be in base 64
  String decrypt({required String privateKey, required String encryptedData}) {
    try {
      Uint8List encryptedData_ =
          Uint8List.fromList(base64Decode(encryptedData));
      // Parse the private key from the PEM format
      final __privateKey__ = parser.parse(privateKey) as d.RSAPrivateKey;

      // Create an RSA decrypter with the private key
      final decrypter = Encrypter(RSA(privateKey: __privateKey__));

      // Decrypt the data
      final decryptedData = decrypter.decryptBytes(Encrypted(encryptedData_));

      // Convert the decrypted data to a string
      String decryptedText = utf8.decode(decryptedData);

      return decryptedText;
    } catch (e) {
      throw ("Decrypt failed:$e");
    }
  }

  String encrypt({required String data, required String publicKey}) {
    d.RSAPublicKey publicKey_ = parser.parse(publicKey) as d.RSAPublicKey;
    final encrypter = Encrypter(RSA(publicKey: publicKey_));
    final encrypted = encrypter.encrypt(data);
    return encrypted.base64;
  }
}
