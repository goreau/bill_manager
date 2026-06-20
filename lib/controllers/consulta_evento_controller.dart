import 'package:bill_manager/controllers/navigation_controller.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../models/auxiliares.dart';
import '../util/db_helper.dart';
import '../util/storage.dart';


class ConsultaEventoController extends GetxController {
  var isLoading = false.obs;
  final itens = <EventoModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    checaBanco();
  }

  @override
  void onReady() {
    super.onReady();
    loadItens();
  }

  Future<void> loadItens() async {
    try {
      isLoading.value = true;
      final db = DbHelper.instance;
      itens.value = await db.consultaEventoMaster();
    } catch (ex) {
      print('Erro carregando lista: $ex');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> novoEvento() async {
    await Get.toNamed('/evento', arguments: 0);

    loadItens();
  }


  Future<void> abrirDespesas()async {
      Get.find<NavigationController>().changeTabIndex(1);
  }

  void selecionarEvento(int id) {
    Storage.insere('evento_ativo_id', id);
  }

  Future<void> excluiEvento(id) async {
    final db = await DbHelper.instance.database;

    List<Map<String, Object?>>? desps = await db?.query(
        'despesa',
        where: 'id_evento = ?',
        whereArgs: [id]
    );

    await db?.transaction((txn) async {
      for (var row in desps!){
        await txn.delete(
            'rateio',
            where: 'id_despesa = ?',
            whereArgs: [row['id_despesa']]
        );
      }

      await txn.delete(
          'despesa',
          where: 'id_evento = ?',
          whereArgs: [id]
      );

      await txn.delete(
          'participante',
          where: 'id_evento = ?',
          whereArgs: [id]
      );

      // 2. Depois, deleta o evento principal
      await txn.delete(
          'evento',
          where: 'id_evento = ?',
          whereArgs: [id]
      );
    });

    loadItens();
  }

  void checaBanco() async {
   // List<Map<String, dynamic>> dados;
   // final db = DbHelper.instance;

   /* db.limpa('rateio');
    db.limpa('despesa');
    db.limpa('participante');
    db.limpa('evento');*/
    
    //await db.limpaTable('rateio','id_despesa IS NULL');
    
   /* dados = await db.queryRows('evento');
    print(dados);

    dados = await db.queryRows('participante');
    print(dados);

    dados = await db.queryRows('despesa');
    print(dados);

    dados = await db.queryRows('rateio');
    print(dados);*/
  }
}
