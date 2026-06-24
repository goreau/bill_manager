import 'package:bill_manager/controllers/consulta_evento_controller.dart';
import 'package:dio/dio.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import '../../repositorys/EventoRepository.dart';


class EventoBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Garante que o repositório esteja registrado
    Get.lazyPut(() => EventoRepository(Get.find<Dio>()));

    // 2. Injeta o controller passando o repositório através do construtor
    // O Get.find<EventoRepository>() busca a instância criada na linha acima
    Get.lazyPut(() => ConsultaEventoController(Get.find<EventoRepository>()));
  }
}