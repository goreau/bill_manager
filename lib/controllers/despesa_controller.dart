
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../util/db_helper.dart';

class DespesaController extends GetxController {
  int? eventoId;
  int? editId;

  final dbHelper = DbHelper.instance;

  var nomeEv = ''.obs;
  final RxList<ItemEvento> listaParticipantes = <ItemEvento>[].obs;
  final lstPagador = <DropdownMenuItem<String>>[].obs;

  final valorController = TextEditingController();
  final descricaoController = TextEditingController();
  final observacaoController = TextEditingController();
  final dateController = TextEditingController().obs;
  var idPagador = '0'.obs;

  var dtDespesa = DateTime.now().toString().substring(0, 10).obs;

  var loadingPagador = false.obs;

  Future<void> manageEvento(int id, int edit) async {
    editId = edit;
    eventoId = id;

    if ( editId! > 0 ){
        await carregarDespesa();
    } else {
      limpaForm();
    }

    if (id > 0) {
      await carregarEvento();
      lstPagador.assignAll(await loadData('participante', 'id_evento = ' + id.toString()));
    } else {
      //voltar para o início
    }
  }

  void limpaForm(){
    valorController.text = '';
    descricaoController.text = '';
    observacaoController.text = '';
    idPagador.value = '0';
    marcarTodos(true);
  }

  Future<void> carregarDespesa() async {
    final db = DbHelper.instance;

    var json = await db.queryObj('despesa', editId!);

    valorController.text = json['valor'].toString();
    descricaoController.text = json['descricao'].toString();
    observacaoController.text = json['observacao'].toString();
    dateController.value.text = json['data'].toString();

    updatePagador(json['id_participante'].toString());

    var rateios = await db.queryRows('rateio', where: 'id_despesa = ?', whereArgs: [editId]);
    Set<String> idsRateados = rateios.map((r) => r['id_participante'].toString()).toSet();

    var participantes = await db.queryRows('participante', where: 'id_evento = ?', whereArgs: [eventoId]);

    listaParticipantes.value = participantes.map((p) {
      String idPart = p['id_participante'].toString();

      return ItemEvento(
        id: idPart,
        nome: p['nome'] as String,
        // Se o idPart estiver no nosso Set, retorna true, senão false
        isChecked: idsRateados.contains(idPart),
      );
    }).toList();

  }

  Future<void> carregarEvento() async {
    final db = DbHelper.instance;

    // 1. Busca o nome do evento
    var evento = await db.queryRows('evento', where: 'id_evento = ?', whereArgs: [eventoId]);
    nomeEv.value = evento.first['nome'] as String;

    if (editId == 0) {
      var participantes = await db.queryRows(
          'participante', where: 'id_evento = ?', whereArgs: [eventoId]);
      listaParticipantes.value = participantes.map((p) {
        return ItemEvento(
          id: p['id_participante'].toString(), // Pega o ID original
          nome: p['nome'] as String, // Pega o nome
          isChecked: true,
        );
      }).toList();
    }
  }

  void toggleCheck(int index) {
    listaParticipantes[index].isChecked = !listaParticipantes[index].isChecked;
    listaParticipantes.refresh(); // Notifica os ouvintes que a lista mudou
  }

  void marcarTodos(bool valor) {
    for (var item in listaParticipantes) {
      item.isChecked = valor;
    }
    listaParticipantes.refresh();
  }

  updatePagador(value) {
    this.idPagador.value = value;
  }


  static Future<List<DropdownMenuItem<String>>> loadData(
      String tabela, String filtro) async {
    final db = DbHelper.instance;
    List<DropdownMenuItem<String>> list = [];

    // Adiciona a opção padrão
    list.add(const DropdownMenuItem<String>(
      value: '0',
      child: Text('--Selecione--', style: TextStyle(fontSize: 12.0)),
    ));

    final ret = await db.qryCombo(tabela, filtro);

    // Use .map().toList() para garantir a execução imediata e o retorno da lista
    final items = ret.map((map) => getDropDownWidget(map)).toList();

    // Adiciona tudo de uma vez à lista principal
    list.addAll(items);

    return list;
  }



  static DropdownMenuItem<String> getDropDownWidget(Map<dynamic, dynamic> map) {
    return DropdownMenuItem<String>(
      child: Text(
        map['nome'],
        style: new TextStyle(
          fontSize: 12.0,
        ),
      ),
      value: map['id'].toString(),
    );
  }

  getCurrentDate(String date) async {
    //var dateParse = DateTime.parse(date);
    var formattedDate = date.split('-').reversed.join('/');
    //var formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";
    this.dateController.value.text = formattedDate;
    this.dtDespesa.value = date;
  }

  Future<void> salvarDespesa(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);

    try {
      final db = await dbHelper.database;

      var dt = dateController.value.text;
      if (dt == ''){
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          SnackBar(
            content: const Text('A data da despesa é obrigatória.'),
            backgroundColor: Colors.red[900],
          ),
        );
        return;
      }
      var formattedDate = dt.split('/').reversed.join('-');


      await db?.transaction((txn) async {
        var obj = {
          'id_evento': eventoId,
          'valor': valorController.text,
          'descricao': descricaoController.text,
          'observacao': observacaoController.text,
          'id_participante': idPagador.value,
          'data': formattedDate,
        };

        List<ItemEvento> selecionados = listaParticipantes.where((item) => item.isChecked).toList();

        // A quantidade
        int quantidade = selecionados.length;

        var valor = double.parse(valorController.text) / quantidade;

        if (editId == 0 || editId == null) {
          int editId = await txn.insert(
              'despesa', obj);
          for (var pag in selecionados) {
            await txn.insert(
                'rateio', {'id_despesa': editId, 'id_participante': pag.id, 'valor': valor});
          }
        } else {
          // Lógica de UPDATE (Delete + Insert)
          await txn.update(
              'despesa', obj, where: 'id_despesa = ?',
              whereArgs: [editId]);
          await txn.delete(
              'rateio', where: 'id_despesa = ?', whereArgs: [editId]);
          for (var pag in selecionados) {
            await txn.insert(
                'rateio', {'id_despesa': editId, 'id_participante': pag.id, 'valor': valor});
          }
        }
      });

      // Se o código chegou aqui, a transação foi concluída com sucesso!
      scaffold.showSnackBar(
        SnackBar(
          content: const Text('Registro salvo com sucesso!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      // Opcional: fechar a tela após salvar
      Navigator.pop(context);
    } catch (e) {
      // Se ocorrer qualquer erro, o catch captura e mostra o erro
      print("Erro ao salvar: $e");
      scaffold.showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar registro: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class ItemEvento {
  String id;
  String nome;
  bool isChecked;

  ItemEvento({required this.id, required this.nome, this.isChecked = false});
}
