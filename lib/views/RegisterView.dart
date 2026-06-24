import 'package:bill_manager/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import '../components/appScaffold.dart';

class RegisterView extends StatelessWidget {
  final LoginController ctrl = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Bill Manager',
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Cadastro', style: Theme.of(context).textTheme.titleLarge),
          ),
          ListTile(
            title: Text(
              'Nome:',
              style: new TextStyle(fontSize: 13),
              textAlign: TextAlign.start,
            ),
            subtitle: TextFormField(
              style: new TextStyle(fontSize: 12),
              decoration: InputDecoration(labelText: 'Email'),
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
              controller: ctrl.emailController,
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
              controller: ctrl.senhaController,
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
                  await ctrl.register();


                },
                child: Text('Registrar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
