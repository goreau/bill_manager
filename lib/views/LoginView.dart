import 'package:bill_manager/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../components/appScaffold.dart';


class LoginView extends GetView<LoginController> {
 // final LoginController ctrl = Get.find<LoginController>();
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Bill Manager',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Login', style: Theme.of(context).textTheme.titleLarge),
          ),
          ListTile(
            title: Text(
              'Email:',
              style: new TextStyle(fontSize: 13),
              textAlign: TextAlign.start,
            ),
            subtitle: TextFormField(
              style: new TextStyle(fontSize: 12),
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'O email é obrigatório!!';
                } else {
                  return null;
                }
              },
              controller: controller.emailController,
              onSaved: null,
            ),
          ),
          ListTile(
            title: Text(
              'Senha:',
              style: new TextStyle(fontSize: 13),
              textAlign: TextAlign.start,
            ),
            subtitle: TextFormField(
              style: new TextStyle(fontSize: 12),
              decoration: InputDecoration(labelText: 'Senha'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'A senha é obrigatória!!';
                } else {
                  return null;
                }
              },
              controller: controller.senhaController,
              onSaved: null,
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: FilledButton(
                onPressed: () async {
                  await controller.logar();
                },
                child: Text('Logar'),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.toNamed('/register');
            },
            child: const Text(
              "Ainda não tenho cadastro",
              style: TextStyle(
                decoration: TextDecoration.underline, // Opcional: para parecer um link
                color: Colors.blue,                   // Cor característica de link
              ),
            ),
          )
        ],
      ),
    );
  }
}
