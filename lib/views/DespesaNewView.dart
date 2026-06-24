import 'package:bill_manager/components/appScaffold.dart';
import 'package:bill_manager/repositorys/DespesaRepository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import '../controllers/despesa_controller.dart';

class DespesaNewView extends StatelessWidget {
  //final DespesaController ctrl = Get.put(DespesaController());
  final int ano = DateTime
      .parse(new DateTime.now().toString())
      .year;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DespesaController>(
        init: DespesaController(DespesaRepository(Get.find<Dio>())),

        builder: (ctrl) {
          return AppScaffold(
              title: 'Bill Manager',
              body: Column(children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Obx(() =>
                      Text('Despesa em ${ctrl.nomeEv.value}', style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge)),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Obx(
                        () =>
                    (TextFormField(
                      style: new TextStyle(fontSize: 12),
                      readOnly: true,
                      controller: ctrl.dateController.value,
                      decoration: InputDecoration(hintText: 'Data da Despesa'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'A data é obrigatória!!';
                        } else {
                          return null;
                        }
                      },
                      onSaved: null,
                      onTap: () async {
                        var date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.parse(ctrl.dtDespesa.value),
                          firstDate: DateTime(ano - 2),
                          lastDate: DateTime(ano + 1),
                        );
                        if (date != null) {
                          await ctrl.getCurrentDate(
                              date.toString().substring(0, 10));
                          date.toString().substring(0, 10);
                        }
                      },
                    )),
                  ),
                ),
                ListTile(
                  title: Text(
                    'Descrição:',
                    style: new TextStyle(fontSize: 13),
                    textAlign: TextAlign.start,
                  ),
                  subtitle: TextFormField(
                    style: new TextStyle(fontSize: 12),
                    decoration: InputDecoration(labelText: 'Descrição'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'A descrição da despesa é obrigatória!!';
                      } else {
                        return null;
                      }
                    },
                    controller: ctrl.descricaoController,
                    onSaved: null,
                  ),
                ),
                ListTile(
                  title: Text(
                    'Valor:',
                    style: new TextStyle(fontSize: 13),
                    textAlign: TextAlign.start,
                  ),
                  subtitle: TextFormField(
                    style: new TextStyle(fontSize: 12),
                    decoration: InputDecoration(labelText: 'Valor'),
                    keyboardType: TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'O valor da despesa é obrigatório!!';
                      } else {
                        return null;
                      }
                    },
                    controller: ctrl.valorController,
                    onSaved: null,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.face),
                  title: const Text(
                      'Pago por:', style: TextStyle(fontSize: 13)),
                  subtitle: Obx(() {
                    if (ctrl.loadingPagador.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Verifique se o valor atual está na lista antes de atribuir ao value
                    // Isso evita o erro de valor inicial inexistente
                    String? valorAtual = ctrl.idPagador.value;
                    bool existeNaLista = ctrl.lstPagador.any((item) =>
                    item.value == valorAtual);

                    return DropdownButtonFormField<String>(
                      hint: const Text('Participante'),
                      value: existeNaLista ? valorAtual : null,
                      // Só passa se for válido
                      isExpanded: true,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder()),
                      items: ctrl.lstPagador,
                      onChanged: (value) => ctrl.updatePagador(value!),
                    );
                  }),
                ),
                ListTile(
                  title: Text(
                    'Observação:',
                    style: new TextStyle(fontSize: 13),
                    textAlign: TextAlign.start,
                  ),
                  subtitle: TextFormField(
                    style: new TextStyle(fontSize: 12),
                    decoration: InputDecoration(labelText: 'Opcional'),
                    controller: ctrl.observacaoController,
                    onSaved: null,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Participantes', style: TextStyle(fontSize: 16)),
                ),
                Expanded(
                  child: Obx(
                        () =>
                        ListView.builder(
                          itemCount: ctrl.listaParticipantes.length,
                          itemBuilder: (context, index) {
                            final item = ctrl.listaParticipantes[index];

                            return CheckboxListTile(
                              title: Text(item.nome),
                              value: item.isChecked,
                              onChanged: (bool? newValue) {
                                ctrl.toggleCheck(index);
                              },
                              controlAffinity:
                              ListTileControlAffinity
                                  .leading, // Checkbox na esquerda
                            );
                          },
                        ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: FilledButton(
                        onPressed: () {
                          ctrl.salvarDespesa();
                        },
                        child: Text('Salvar')
                    ),
                  ),
                ),
              ]));
        });
  }
}
