import 'dart:io';

import 'package:bill_manager/controllers/consulta_evento_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import '../api_config.dart';
import '../controllers/camera_controller.dart';
import '../repositorys/EventoRepository.dart';
import '../util/storage.dart';

class HomeView extends StatelessWidget {
  final MyCameraController cCtrl = Get.find<MyCameraController>();

  @override
  Widget build(BuildContext context) {
    final String baseUrl = ApiConfig.baseUrl;
    return GetBuilder<ConsultaEventoController>(
      init: ConsultaEventoController(EventoRepository(Get.find<Dio>())),
      builder: (ctrl) {
        ctrl.loadItens();
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
                      evento.idEvento,
                    ), // Chave única para o Slidable do evento
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          label: 'Editar',
                          backgroundColor: Colors.green,
                          icon: Icons.edit,
                          onPressed: (context) async {
                            await Get.toNamed(
                              '/evento',
                              arguments: evento,
                            );
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
                          onPressed: (context) =>
                              ctrl.excluiEvento(evento.idEvento),
                        ),
                      ],
                    ),
                    // O ExpansionTile fica como "filho" do Slidable
                    child: ExpansionTile(
                      title: InkWell(
                        onTap: () async {
                          //+ ctrl.selecionarEvento(evento.idEvento);
                          Get.toNamed('/search', arguments: evento.idEvento);
                          await Storage.insere('id_evento_ativo', evento.idEvento.toString());
                          await Storage.insere('nome_evento_ativo', evento.nome);
                        },
                        child: Text(
                          evento.nome,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: Text(
                        '${evento.participantes?.length} participantes',
                      ),
                      leading: SizedBox(
                        width: 40, // Defina uma largura fixa
                        height: 40, // Defina uma altura fixa
                        child: (evento.foto != null)
                            ? ClipRRect(
                                // Para deixar redonda
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  "$baseUrl/evento/foto/${evento.foto}", // Monta a URL completa
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.broken_image),
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
                      children: evento.participantes!
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
      },
    );
  }
}
