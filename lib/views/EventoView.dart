import 'dart:io';

import 'package:bill_manager/components/appScaffold.dart';
import 'package:bill_manager/controllers/evento_controller.dart';
import 'package:camera_camera/camera_camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import '../api_config.dart';
import '../controllers/camera_controller.dart';
import '../repositorys/EventoRepository.dart';

class EventoView extends StatelessWidget {
  final MyCameraController cCtrl = Get.find<MyCameraController>();

  @override
  Widget build(BuildContext context) {
    final String baseUrl = ApiConfig.baseUrl;
    return GetBuilder<EventoController>(
      init: EventoController(EventoRepository(Get.find<Dio>())),

      builder: (ctrl) {
        return AppScaffold(
          title: 'Bill Manager',
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Novo Evento',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListTile(
                  title: Text(
                    'Nome do Evento:',
                    style: new TextStyle(fontSize: 13),
                    textAlign: TextAlign.start,
                  ),
                  subtitle: TextFormField(
                    style: new TextStyle(fontSize: 12),
                    decoration: InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'O nome é obrigatório!!';
                      } else {
                        return null;
                      }
                    },
                    controller: ctrl.nomeController,
                    onSaved: null,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Participantes', style: TextStyle(fontSize: 15)),
                ),

                // Campo para adicionar participante
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: ctrl.participanteController,
                          decoration: const InputDecoration(
                            labelText: 'Incluir participante',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          if (ctrl.participanteController.text.isNotEmpty) {
                            // Adiciona na lista
                            ctrl.listaParticipantes.add(
                              ctrl.participanteController.text,
                            );
                            ctrl.participanteController
                                .clear(); // Limpa o campo
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Lista de participantes
                Obx(
                  () => ListView.builder(
                    shrinkWrap:
                        true, // Importante para usar dentro de SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ctrl.listaParticipantes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(ctrl.listaParticipantes[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              ctrl.listaParticipantes.removeAt(index),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Obx(() {
                      // Verifica se a string está vazia ou nula
                      if (ctrl.imagem.value.isEmpty) {
                        return Container(
                          height: 200,
                          color:
                              Colors.grey[300], // Cor de fundo do placeholder
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                Text("Nenhuma imagem selecionada"),
                              ],
                            ),
                          ),
                        );
                      } else {
                        // Exibe a imagem selecionada
                        return Image.network(
                          "$baseUrl/evento/foto/${ctrl.imagem}", // Monta a URL completa
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image),
                        );
                      }
                    }),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: FilledButton(
                      onPressed: () async {
                        await ctrl.salvarEventoCompleto();
                      },
                      child: Text('Salvar'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: const Icon(Icons.camera_enhance),
            onPressed: () {
              showModalBottomSheet(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                context: context,
                builder: (context) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Galeria'),
                        onTap: () {
                          Navigator.pop(context); // Fecha o modal
                          ctrl.pickImage();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Câmera'),
                        onTap: () async {
                          Navigator.pop(context); // Fecha o modal
                          await Get.to(
                            CameraCamera(
                              onFile: (file) => cCtrl.tirarFoto(file),
                              resolutionPreset: ResolutionPreset.medium,
                            ),
                          );
                          ctrl.imagem.value = cCtrl.arquivo.path;
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
