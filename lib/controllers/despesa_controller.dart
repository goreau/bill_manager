
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../models/despesa.dart';
import '../repositorys/DespesaRepository.dart';
import '../util/db_helper.dart';

class DespesaController extends GetxController {
  int? editId;
  int? eventoId;

  Despesa? despesaEmEdicao;

  final DespesaRepository repository;
  DespesaController(this.repository);

  @override
  void onInit() {
    super.onInit();
    preparar();
  }

  static const snackBarDuration = Duration(seconds: 2);

  var nomeEv = ''.obs;
  final RxList<ItemRateio> listaParticipantes = <ItemRateio>[].obs;
  final lstPagador = <DropdownMenuItem<String>>[].obs;

  final valorController = TextEditingController();
  final descricaoController = TextEditingController();
  final observacaoController = TextEditingController();
  final dateController = TextEditingController().obs;
  var idPagador = '0'.obs;

  var dtDespesa = DateTime.now().toString().substring(0, 10).obs;

  var loadingPagador = false.obs;

  Future<void> preparar() async {
    final dynamic args = Get.arguments;
    if (args != null && args is Map) {
      despesaEmEdicao = args['desp'] as Despesa?;
      eventoId = args['evento'] as int;
    }


    if (despesaEmEdicao == null) {
      editId = 0;
      doClear();
    } else {
      editId = despesaEmEdicao?.idDespesa;
      prepararTela(despesaEmEdicao!);
    }

    criaLista();

  }

  Future<void> criaLista() async {
    List<dynamic> lista = await repository.getParticipantes(eventoId!);

    final idsNoRateio = despesaEmEdicao?.rateio?.map((r) => r.id_pagador).toList();

    listaParticipantes.value = lista.map((item) {
      return ItemRateio(
        id: item['id_participante'].toString(),
        nome: item['nome'],
        isChecked: idsNoRateio!.contains(item['id_participante']),
      );
    }).toList();

    lstPagador.value = dropdownItems;
}

  Future<void> prepararTela(Despesa ev) async {
    descricaoController.text = ev.descricao;
    editId = ev.idDespesa;
    valorController.text = ev.valor;
    observacaoController.text = ev.observacao!;
    idPagador.value = ev.id_pagador.toString();
    getCurrentDate(ev.data);
  }


  void doClear(){
    valorController.text = '';
    descricaoController.text = '';
    observacaoController.text = '';
    idPagador.value = '0';
    marcarTodos(true);
  }

  void toggleCheck(int index) {
    listaParticipantes[index].isChecked = !listaParticipantes[index].isChecked;
    listaParticipantes.refresh();
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

  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> list = [];

    // 1. Adiciona a opção padrão
    list.add(const DropdownMenuItem<String>(
      value: '0',
      child: Text('--Selecione--', style: TextStyle(fontSize: 12.0)),
    ));

    // 2. Mapeia sua lista que já está em memória
    final items = listaParticipantes.map((item) {
      return DropdownMenuItem<String>(
        value: item.id, // O ID do participante
        child: Text(
          item.nome,
          style: const TextStyle(fontSize: 12.0),
        ),
      );
    }).toList();

    list.addAll(items);
    return list;
  }

  Future<void> getCurrentDate(String date) async {
    //var dateParse = DateTime.parse(date);
    var formattedDate = date.split('-').reversed.join('/');
    //var formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";
    this.dateController.value.text = formattedDate;
    this.dtDespesa.value = date;
  }



  Future<void> salvarDespesa() async {
    try {

      Despesa obj = new Despesa(
          idDespesa:  editId,
          descricao: descricaoController.text,
          observacao: observacaoController.text,
          id_evento: eventoId!,
          id_pagador: int.parse(idPagador.value),
          valor: valorController.text,
          data: dtDespesa.value,
          rateio: []
      );

      List<ItemRateio> selecionados = listaParticipantes.where((item) => item.isChecked).toList();

      for (var pag in selecionados) {
        Rateio lst = new Rateio(
          id_pagador: int.parse(pag.id),
          nome: pag.nome,
          valor: '0'
        );
        obj.rateio?.add(lst);
      }

      repository.save(obj);

      Get.snackbar("Sucesso", 'Registro salvo com sucesso!');


      Future.delayed(snackBarDuration, () {
        Get.back();
      });
    } catch (e) {
      print("Erro ao salvar: $e");
      Get.snackbar("Erro", 'Erro ao salvar: $e');
    }
  }
}

class ItemRateio {
  String id;
  String nome;
  bool isChecked;

  ItemRateio({required this.id, required this.nome, this.isChecked = false});
}
