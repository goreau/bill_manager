import 'package:bill_manager/controllers/navigation_controller.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../models/evento.dart';
import '../repositorys/EventoRepository.dart';
import '../util/db_helper.dart';
import '../util/storage.dart';


class ConsultaEventoController extends GetxController {
  final EventoRepository _repository;

  ConsultaEventoController(this._repository);

  var isLoading = false.obs;
  final itens = <Evento>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    loadItens();
  }

  Future<void> loadItens() async {
    try {
      isLoading.value = true;

      itens.value = await _repository.fetchAll();

      String? ev = await Storage.recupera('id_evento_ativo');
      if (ev == null || ev.isEmpty) {
        if (itens.isNotEmpty) {
          int? idPadrao = itens.first.idEvento;
          String? nome = itens.first.nome;
          await Storage.insere('id_evento_ativo', idPadrao.toString());
          await Storage.insere('nome_evento_ativo', nome);
        }
      }
    } catch (ex) {
      print('Erro carregando lista: $ex');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> novoEvento() async {
    await Get.toNamed('/evento', arguments: null);

    loadItens();
  }


  Future<void> abrirDespesas()async {
      Get.find<NavigationController>().changeTabIndex(1);
  }

  void selecionarEvento(int id) {
    Storage.insere('evento_ativo_id', id);
  }

  Future<void> excluiEvento(id) async {
    _repository.delete(id);
    loadItens();
  }

  Future<void> excluirEvento(int id) async {
    // Remove o evento
    await _repository.delete(id);

    // Atualiza a lista localmente
    itens.removeWhere((e) => e.idEvento == id);

    // Verifica se o excluído era o ativo
    String? idAtivo = await Storage.recupera('id_evento_ativo');

    if (idAtivo == id.toString()) {
      if (itens.isNotEmpty) {
        // Seta o primeiro da lista como novo ativo
        await Storage.insere('id_evento_ativo', itens.first.idEvento.toString());
        await Storage.insere('nome_evento_ativo', itens.first.nome);
      } else {
        // Lista vazia, limpa o storage
        await Storage.remove('id_evento_ativo');
        await Storage.remove('nome_evento_ativo');
      }
    }
  }

}
