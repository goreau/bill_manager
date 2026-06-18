import 'dart:async';
import 'dart:io';
import 'package:bill_manager/models/evento.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../util/db_helper.dart';
import 'package:image_picker/image_picker.dart';



class EventoController extends GetxController {
  int? editId;

  var clearAll = false.obs;

  static const snackBarDuration = Duration(seconds: 2);

  final nomeController = TextEditingController();
  final participanteController = TextEditingController();

  final RxList<String> listaParticipantes = <String>[].obs;

  var evento = new Evento().obs;
  final dbHelper = DbHelper.instance;



  RxString imagem = ''.obs;

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Opcional: reduz o peso da imagem
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      imagem.value = pickedFile.path;
      // Use a imagem aqui (ex: exibir no app ou enviar para servidor)
    }
  }

  Future<void> prepararTela(int id) async {
    editId = id;
    if (id > 0) {
      await carregarEvento(id);
    } else {
      doClear();
    }
  }

  initObj(int id) async {
    editId = id;
    final db = DbHelper.instance;

    var json = await db.queryObj('evento', id);

    nomeController.text = json['nome'].toString();
  }



  Future<void> carregarEvento(int id) async {
   // editId = id;
   // final db = await dbHelper.database;
    final db = DbHelper.instance;

    // 1. Busca o nome do evento
    var evento = await db.queryRows('evento', where: 'id_evento = ?', whereArgs: [id]);
    nomeController.text = evento.first['nome'] as String;
    imagem.value = evento.first['foto'] as String;

    // 2. Busca os participantes vinculados
    var participantes = await db.queryRows('participante', where: 'id_evento = ?', whereArgs: [id]);
    listaParticipantes.value = participantes.map((p) => p['nome'] as String).toList();
  }

  Future<void> salvarEventoCompleto(BuildContext context) async {
   final scaffold = ScaffoldMessenger.of(context);

   try {
     final db = await dbHelper.database;

     await db?.transaction((txn) async {
       if (editId == 0) {
         // Lógica de INSERT
         int editId = await txn.insert('evento', {'nome': nomeController.text, 'foto': imagem.value});
         for (var nome in listaParticipantes) {
           await txn.insert('participante', {'nome': nome, 'id_evento': editId});
         }
       } else {
         // Lógica de UPDATE (Delete + Insert)
         await txn.update('evento', {'nome': nomeController.text, 'foto': imagem.value}, where: 'id_evento = ?', whereArgs: [editId]);
         await txn.delete('participante', where: 'id_evento = ?', whereArgs: [editId]);
         for (var nome in listaParticipantes) {
           await txn.insert('participante', {'nome': nome, 'id_evento': editId});
         }
       }
     });

     // Se o código chegou aqui, a transação foi concluída com sucesso!
     scaffold.showSnackBar(
       SnackBar(
         content: const Text('Registro salvo com sucesso!'),
         backgroundColor: Theme.of(context).colorScheme.primary,
         duration: snackBarDuration,
       ),
     );

     Future.delayed(snackBarDuration, () {
       Get.back();
     });
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

  doClear() {
    this.nomeController.text = '';
    this.listaParticipantes.clear();
  }
}
