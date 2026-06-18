import 'package:bill_manager/components/appScaffold.dart';
import 'package:bill_manager/controllers/consulta_despesa_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class SearchView extends StatelessWidget {
  final ConsultaDespesaController ctrl = Get.put(ConsultaDespesaController());

  @override
  Widget build(BuildContext context) {
    final int id = Get.arguments ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.manageDespesa(id);
    });
    return AppScaffold(
      title: 'Bill Manager',
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (ctrl.itens.isEmpty) {
          return Center(child: Text("Nenhuma despesa cadastrada"));
        }

        return ListView.builder(
          itemCount: ctrl.itens.length,
          itemBuilder: (context, index) {
            final despesa = ctrl.itens[index];

            // O Slidable agora envolve o ExpansionTile (o evento)
            return Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Slidable(
                key: ValueKey(
                  despesa.id,
                ), // Chave única para o Slidable do evento
                startActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      label: 'Editar',
                      backgroundColor: Colors.green,
                      icon: Icons.edit,
                      onPressed: (context) => Get.toNamed(
                        '/despesa',
                        arguments: {'eventoId': id, 'editId': despesa.id},
                      ),
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
                      onPressed: (context) => ctrl.excluiDespesa(despesa.id),
                    ),
                  ],
                ),
                // O ExpansionTile fica como "filho" do Slidable
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Despesa: ${despesa.descricao}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Data: ${despesa.data}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(child: Text('R\$ ${despesa.valor}')),
                      Expanded(child: Text('Pago por: ${despesa.pagador}')),
                    ],
                  ),
                  leading: const Icon(Icons.event),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Participantes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...despesa.devedores.map(
                      (p) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.person, size: 16),
                        title: Row(
                          children: [
                            // Aqui dentro pode usar Expanded pois é filho de Row!
                            Expanded(child: Text(p.nome.toString())),
                            Expanded(child: Text('R\$ ${p.valor.toString()}')),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(Icons.add_circle_outline),
        onPressed: () async => {
          await Get.toNamed(
            '/despesa',
            arguments: {'eventoId': ctrl.eventoId, 'editId': 0},
          ),
          ctrl.loadItens(),
        },
      ),
    );
  }
}
