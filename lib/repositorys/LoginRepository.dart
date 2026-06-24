import 'package:bill_manager/util/storage.dart';
import 'package:dio/dio.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class LoginRepository {
  final Dio dio = Get.find<Dio>();
  LoginRepository(dio);

  Future<bool> login(String email, String password) async {
    try {
      final response = await dio.post('/user/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token']; // Ajuste conforme o JSON do seu backend
        final user = response.data['user'];
        Storage.insere('jwt_token', token);
        Storage.insere('user', user.toString());
       // await _storage.write(key: 'jwt_token', value: token);
      //  await _storage.write(key: 'user', value: user.toString());
        return true;
      }
      return false;
    } catch (e) {
      print("Erro no login: $e");
      return false;
    }
  }

  Future<String> register(String email, String password, String nome) async {
    try {
      final response = await dio.post('/user/register', data: {
        'email': email,
        'password': password,
        'nome': nome
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = response.data['message']; // Ajuste conforme o JSON do seu backend
      //  final user = response.data['user'];
        return message;
      }
      return 'Erro ao cadastrar o usuário';
    } catch (e) {
      print("Erro no login: $e");
      return "Erro no registro: $e";
    }
  }

  Future<bool> sair() async {
    try {
      await Storage.remove('jwt_token');
      return true;
    } catch (e) {
      print("Erro ao sair: $e");
      return false;
    }
  }
}