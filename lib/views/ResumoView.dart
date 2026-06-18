import 'package:bill_manager/controllers/resumo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class ResumoView extends StatelessWidget {
  final ResumoController ctrl = Get.put(ResumoController());

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(() => ListView.builder(
        itemCount: ctrl.listaResumo.length,
        itemBuilder: (context, index) {
          final item = ctrl.listaResumo[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.currency_exchange)),
              title: Text("${item.devedor} deve para ${item.credor}"),
              subtitle: Text(
                "Valor: R\$ ${item.valor.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          );
        },
      )),
    );
  }
}