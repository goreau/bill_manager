import 'dart:io';

import 'package:bill_manager/controllers/consulta_evento_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../controllers/camera_controller.dart';
import '../models/auxiliares.dart';

class HomeView extends StatelessWidget {
  final ConsultaEventoController ctrl = Get.put(ConsultaEventoController());
  final MyCameraController cCtrl = Get.find<MyCameraController>();

  late List<EventoModel> items = ctrl.itens;

  @override
  Widget build(BuildContext context) {
    // ctrl.verifEnvio(context);
    return Container(
      child: Obx(() {
        if (ctrl.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (ctrl.itens.isEmpty) {
          return Center(child: Text("Nenhum evento encontrado"));
        }

        return ListView.builder(
          itemCount: ctrl.itens.length,
          itemBuilder: (context, index) {
            final evento = ctrl.itens[index];
            return Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Slidable(
                key: ValueKey(
                  evento.id,
                ), // Chave única para o Slidable do evento
                startActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      label: 'Editar',
                      backgroundColor: Colors.green,
                      icon: Icons.edit,
                      onPressed: (context) async {
                        await Get.toNamed('/evento', arguments: evento.id);

                        ctrl.loadItens();
                      },
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      label: 'Excluir',
                      backgroundColor: Colors.red,
                      icon: Icons.delete,
                      onPressed: (context) => ctrl.excluiEvento(evento.id),
                    ),
                  ],
                ),
                // O ExpansionTile fica como "filho" do Slidable
                child: ExpansionTile(
                  title: InkWell(
                    onTap: () async {
                      ctrl.selecionarEvento(evento.id);
                      Get.toNamed('/search', arguments: evento.id);
                    },
                    child: Text(
                      evento.nome,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  subtitle: Text(
                    '${evento.participantes.length} participantes',
                  ),
                  leading: SizedBox(
                    width: 40, // Defina uma largura fixa
                    height: 40, // Defina uma altura fixa
                    child:
                        (evento.foto.isNotEmpty &&
                            File(evento.foto).existsSync())
                        ? ClipRRect(
                            // Para deixar redonda
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(evento.foto),
                              fit: BoxFit
                                  .cover, // Importante para preencher o quadrado
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(
                              4.0,
                            ), // Padding opcional para não encostar na borda
                            child: Image.asset(
                              'assets/icon/ic_launcher_base.png', // <--- CAMINHO DO SEU ÍCONE AQUI
                              fit: BoxFit.contain,
                            ),
                          ), // Fallback se não tiver foto
                  ),
                  children: evento.participantes
                      .map(
                        (nome) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.person, size: 16),
                          title: Text(nome),
                        ),
                      )
                      .toList(),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
