import 'dart:ui';
import 'package:bill_manager/controllers/consulta_evento_controller.dart';
import 'package:bill_manager/controllers/resumo_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';

import 'despesa_controller.dart';

class NavigationController extends GetxController {
  var tabIndex = 0.obs;
  late BuildContext context;

  @override
  void onInit(){
    super.onInit();
    Get.put(DespesaController());
  }

  List<Widget> get appBarActions {
    switch (tabIndex.value) {
      case 0:
        return [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'about'){
                WidgetsFlutterBinding.ensureInitialized();
                PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
                  // String appName = packageInfo.appName;
                  // String packageName = packageInfo.packageName;
                  //   String version = packageInfo.version;
                  //   String buildNumber = packageInfo.buildNumber;
                  showAboutDialog(
                    context: context,
                    applicationVersion: packageInfo.version,
                    applicationIcon: Image.asset('assets/icon/icone.png'),
                    applicationLegalese: 'App para gestão de contas compartilhadas',
                  );
                });
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Sair do aplicativo?'),
                    content: Text('Você tem certeza que deseja sair?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Não'),
                      ),
                      TextButton(
                        onPressed: () => SystemNavigator.pop(),
                        child: Text('Sim'),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'about', child: Text('Sobre')),
              const PopupMenuItem(value: 'quit', child: Text('Sair')),
            ],
          ),
        ];
      case 1:
        return [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Get.toNamed('detalhe'),
            tooltip: "Detalhar",
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => Get.find<ResumoController>().exportarParaCSV(),
            tooltip: "Exportar",
          ),
        ];
      default:
        return []; // Retorna lista vazia se não houver ações
    }
  }


  VoidCallback? get fabAction {
    switch (tabIndex.value) {
      case 0: return () => Get.find<ConsultaEventoController>().novoEvento();
      default: return null;
    }
  }

  // Define o ícone do FAB
  Icon? get fabIcon {
    switch (tabIndex.value) {
      case 0: return const Icon(Icons.add_circle_outline);
      default: return null;
    }
  }



  void changeTabIndex(int index) {
    tabIndex.value = index;

    if (index == 1) {
      Get.find<ResumoController>().calcularAcerto();
    }
  }
}