import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:path_provider/path_provider.dart';

import '../components/foto.dart';
import '../views/preview_page_view.dart';

class MyCameraController extends GetxController {
  late File arquivo;
  final hasFile = false.obs;
  //var editPath = ''.obs;

  MyCameraController() {
    initImage();
  }

  initImage() async {
    await getImageFileFromAssets().then((value) {
      if (!hasFile.value) {
        arquivo = value;
        hasFile.value = true;
      }
    });
  }

  tirarFoto(file) async {
    hasFile.value = false;
    file = await Get.to(() => PreviewPage(file: file));
    if (file != null) {
      arquivo = file;
      hasFile.value = true;
      Get.back();
    }
  }

  Widget showFoto(String arq) {
    return hasFile.value ? Foto(file: File(arq), size: 100) : Text('Imagem não disponível');
  }

  Future<File> getImageFileFromAssets() async {
    // var assets = await rootBundle.loadString('AssetManifest.json');

    String path = 'icon/ic_launcher_base.png';
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/ic_launcher_base.png');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }
}