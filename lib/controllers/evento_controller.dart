import 'dart:async';
import 'package:bill_manager/models/evento.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositorys/EventoRepository.dart';
import '../util/db_helper.dart';
import 'package:image_picker/image_picker.dart';

import '../util/storage.dart';



class EventoController extends GetxController {
  int? editId;
  Evento? eventoEmEdicao;

  final EventoRepository repository;
  EventoController(this.repository);

  @override
  void onInit() {
    super.onInit();
    preparar();
  }

  void preparar() {
    eventoEmEdicao = Get.arguments as Evento?;

    if (eventoEmEdicao == null) {
      editId = 0;
      doClear();
    } else {
      editId = eventoEmEdicao?.idEvento;
      prepararTela(eventoEmEdicao!);
    }
  }



  var clearAll = false.obs;

  static const snackBarDuration = Duration(seconds: 2);

  final nomeController = TextEditingController();
  final participanteController = TextEditingController();

  final RxList<String> listaParticipantes = <String>[].obs;

  var evento = new Evento(nome: '').obs;
  final dbHelper = DbHelper.instance;

  RxString imagem = ''.obs;

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Opcional: reduz o peso da imagem
    );

    if (pickedFile != null) {
     // File imageFile = File(pickedFile.path);
      imagem.value = pickedFile.path;
    }
  }

  Future<void> prepararTela(Evento ev) async {
      nomeController.text = ev.nome;
      editId = ev.idEvento;
      listaParticipantes.value = ev.participantes!;
      imagem.value = ev.foto!;
  }


  Future<void> salvarEventoCompleto() async {

   try {
     Evento obj = new Evento(
         idEvento:  editId,
         nome: nomeController.text,
         foto: imagem.value,
         participantes: listaParticipantes
     );


     repository.save(obj);

     Get.snackbar("Sucesso", 'Registro salvo com sucesso!');

     await Storage.insere('id_evento_ativo', obj.idEvento);
     await Storage.insere('nome_evento_ativo', obj.nome);

     Future.delayed(snackBarDuration, () {
       Get.back();
     });
   } catch (e) {
     print("Erro ao salvar: $e");
     Get.snackbar("Erro", 'Erro ao salvar: $e');
   }

  }

  doClear() {
    this.nomeController.text = '';
    this.listaParticipantes.clear();
  }
}
