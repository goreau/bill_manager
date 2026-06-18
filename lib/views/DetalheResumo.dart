import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../components/appScaffold.dart';
import '../controllers/resumo_controller.dart';

class DetalheResumoView extends StatelessWidget {
  final ResumoController ctrl = Get.find<ResumoController>();

  @override
  Widget build(BuildContext context) {
    ctrl.detalhes();

    return AppScaffold(
        title: 'Bill Manager',
        body: Obx(() => ListView.builder(
            itemCount: ctrl.listaDetalhe.length,
            itemBuilder: (context, index) {
              final item = ctrl.listaDetalhe[index];
              final double balanco = (item['balanco'] as num).toDouble();
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.currency_exchange)),
                  title: Text("${item['nome']}: pagou ${item['pago']} e consumiu ${item['consumo']}"),
                  subtitle: Text(
                    "Saldo: R\$ ${item['balanco'].toStringAsFixed(2)}",
                    style: TextStyle(fontWeight: FontWeight.bold, color: balanco >= 0 ? Colors.green : Colors.red),
                  ),
                ),
              );
            },
          ))
    );
  }
}