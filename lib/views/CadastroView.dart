
import 'package:bill_manager/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../components/appScaffold.dart';
import '../controllers/camera_controller.dart';

class CadastroView extends StatelessWidget {
  final LoginController ctrl = Get.find<LoginController>();
  final MyCameraController cCtrl = Get.find<MyCameraController>();


  @override
  Widget build(BuildContext context) {
    return  Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: FilledButton(
                onPressed: () async {
                  await ctrl.sair();
                },
                child: Text('Sair'),
              ),
            ),
          ),
        ],
    );
  }
}