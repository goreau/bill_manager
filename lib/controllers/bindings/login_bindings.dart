import 'package:dio/dio.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import '../../repositorys/LoginRepository.dart';
import '../login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Primeiro, garante que as dependências do repositório estejam disponíveis
    Get.lazyPut(() => LoginRepository(Get.find<Dio>()));

    // Depois, injeta o Controller já passando o repositório
    Get.lazyPut(() => LoginController(Get.find<LoginRepository>()));
  }
}