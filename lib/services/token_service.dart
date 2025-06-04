import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class TokenService {
  // Replace these with your actual 100ms credentials
  static const String APP_ACCESS_KEY = "683c78b6145cb4e8449af966";
  static const String APP_SECRET = "hQWhMFeeKOK83FqTJyln-Cucxcgkuh0KLD75m9coBHFP3dP20P5AwhBnVAq-5o45i7SXBhNwvpXHeFOrYvr4Hg3hB19zzzVTw3RG3ekN5hhvxsbiIzoiAiN_2DBGnWzRwtxzdOqR7Cytu4UNAHH_3TV6mK6Y9FeAdDlVzg7t85w=";

  static String generateToken({
    required String roomCode,
    required String userId,
    String role = 'guest',
  }) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final payload = {
      'access_key': APP_ACCESS_KEY,
      'room_id': roomCode,
      'user_id': userId,
      'role': role,
      'type': 'app',
      'version': 2,
      'iat': now,
      'nbf': now,
    };

    final jwt = JWT(payload);
    final token = jwt.sign(SecretKey(APP_SECRET), algorithm: JWTAlgorithm.HS256);

    return token;
  }
}