import 'package:bill_manager/models/auxiliares.dart';
import 'package:bill_manager/repositorys/DespesaRepository.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../models/despesa.dart';
import '../util/db_helper.dart';

class ConsultaDespesaController extends GetxController {
  final DespesaRepository _repository;

  ConsultaDespesaController(this._repository, this.eventoId);

  var isLoading = false.obs;
  final itens = <Despesa>[].obs;

  int eventoId;
  int? editId;

  final dbHelper = DbHelper.instance;

  @override
  void onInit() {
    super.onInit();
    loadItens();
  }

  Future<void> novaDespesa() async {
    await Get.toNamed(
      '/despesa',
      arguments: {'desp': null, 'evento': eventoId},
    );

    loadItens();
  }

  Future<void> manageDespesa(int id) async {
    eventoId = id;

    if (id > 0) {
      await loadItens();
    } else {
      //voltar para o início
    }
  }

  Future<void> loadItens() async {
    try {
      isLoading.value = true;
      itens.value = await _repository.fetchAll(eventoId);
    } catch (ex) {
      print('Erro carregando lista: $ex');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> wait() async {}

  Future<void> excluiDespesa(id) async {
    _repository.delete(id);

    loadItens();
  }
}
