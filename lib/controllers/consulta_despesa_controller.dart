import 'package:bill_manager/models/auxiliares.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../util/db_helper.dart';

class ConsultaDespesaController extends GetxController {
  var isLoading = false.obs;
  final itens = <DespesaModel>[].obs;

  int? eventoId;
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
      arguments: {'eventoId': eventoId, 'editId': 0},
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
      final db = DbHelper.instance;
      itens.value = await db.consultaDespesaMaster(eventoId!);
    } catch (ex) {
      print('Erro carregando lista: $ex');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> wait() async {}

  Future<void> excluiDespesa(id) async {
    final db = await DbHelper.instance.database;

    List<Map<String, Object?>>? desps = await db?.query(
      'despesa',
      where: 'id_evento = ?',
      whereArgs: [id],
    );

    await db?.transaction((txn) async {
      for (var row in desps!) {
        await txn.delete(
          'rateio',
          where: 'id_despesa = ?',
          whereArgs: [row['id_despesa']],
        );
      }

      await txn.delete('despesa', where: 'id_evento = ?', whereArgs: [id]);
    });

    loadItens();
  }
}
