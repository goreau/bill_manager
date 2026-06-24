import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  static const _storage = FlutterSecureStorage();

  // Salvar token
 /* static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // Ler token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }*/

  // Remover token (logout)
  static Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  static dynamic recupera(String key) async {
    return await _storage.read(key: key);
  }

  static insere(String key, value) async {
    await _storage.write(key:key, value: value);
  }

  static remove(String key) async {
    await _storage.delete(key: key);
  }


}

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await Storage.recupera('jwt_token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
}