import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../repositorys/LoginRepository.dart';

class LoginController extends GetxController {
  late final LoginRepository _repository;

  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final nomeController = TextEditingController();

  var isRegister = false.obs;

  LoginController(this._repository);

  Future<void> logar() async {
    bool sucesso = await _repository.login(
        emailController.text,
        senhaController.text
    );

    if (sucesso) {
      Get.offAllNamed('/');
    } else {
      Get.snackbar("Erro", "Falha na autenticação");
    }
  }

  Future<void> register() async {
    String message = await _repository.register(
        emailController.text,
        senhaController.text,
        nomeController.text,
    );

    if (!message.contains("Erro")) {
      Get.snackbar("Sucesso", message);
      Get.toNamed('/login');
    } else {
      Get.snackbar("Erro", "Falha na autenticação");
    }
  }

  Future<void> sair() async {
    bool res = await _repository.sair();
    if (res) {
      Get.toNamed('/login');
    } else {
      Get.snackbar("Erro", "Falha ao sair");
    }
  }
}
