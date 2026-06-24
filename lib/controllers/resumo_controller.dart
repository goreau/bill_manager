import 'dart:io';

import 'package:bill_manager/util/storage.dart';
import 'package:csv/csv.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/auxiliares.dart';
import '../repositorys/ResumoRepository.dart';

class ResumoController extends GetxController {
  final ResumoRepository repository;
  ResumoController(this.repository);

  var isLoading = false.obs;

  int? eventoId;

  //final listaResumo =[].obs;
  final listaResumo = RxList<ResumoDivida>([]);

  final listaDetalhe = RxList<Map<String, dynamic>>([]);

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    eventoId =  await Storage.recupera('id_evento_ativo');

    await calcularAcerto(); // Sua função de cálculo

  }

  Future<List<ResumoDivida>> calcularAcerto() async {
   // eventoId = 4;// await Storage.recupera('evento_ativo_id');
    //print(eventoId);

    final dados = await repository.getResumo(eventoId!);

    List<dynamic> resultadosPagamentos = dados.pagadores;
    List<dynamic> resultadosDevidos = dados.devedores;
//print(resultadosPagamentos);
//print(resultadosDevidos);

    Map<String, double> saldos = {};

// 1. Adiciona créditos (quem pagou)
    for (var row in resultadosPagamentos!) {
      String nome = row['nome'];
      double valor = double.parse(row['total']);
      saldos[nome] = (saldos[nome] ?? 0) + valor;
    }

// 2. Subtrai débitos (quem deve)
    for (var row in resultadosDevidos!) {
      String nome = row['nome'];
      double valor = double.parse(row['total']);
      saldos[nome] = (saldos[nome] ?? 0) - valor;
    }

    List<ResumoDivida> lista = [];

    // Separamos quem tem saldo positivo (credores) e negativo (devedores)
    var credores = saldos.entries.where((e) => e.value > 0).toList();
    var devedores = saldos.entries.where((e) => e.value < 0).toList();

    // Ordenamos para priorizar as maiores dívidas/créditos
    credores.sort((a, b) => b.value.compareTo(a.value));
    devedores.sort((a, b) => a.value.compareTo(b.value));

    int c = 0; // índice do credor
    int d = 0; // índice do devedor

    while (c < credores.length && d < devedores.length) {
      double valorDaDivida = devedores[d].value.abs();
      double valorDoCredito = credores[c].value;

      double pagamento = valorDaDivida < valorDoCredito ? valorDaDivida : valorDoCredito;

      lista.add(ResumoDivida(devedores[d].key, credores[c].key, pagamento));

      // Atualiza os saldos
      credores[c] = MapEntry(credores[c].key, credores[c].value - pagamento);
      devedores[d] = MapEntry(devedores[d].key, devedores[d].value + pagamento);

      // Se o saldo chegar a zero, passamos para o próximo
      if (credores[c].value < 0.01) c++;
      if (devedores[d].value > -0.01) d++;
    }
    print(lista.toString());
    listaResumo.assignAll(lista);
    return lista;
  }

  Future<void> exportarParaCSV() async {
    try {
      // 1. Define onde salvar temporariamente
      final directory = await getApplicationDocumentsDirectory();
      String nome = await Storage.recupera('nome_evento_ativo') ?? 'relatorio_evento_$eventoId';
      final String path = '${directory.path}/${nome}.csv';

      // 2. Chama o repositório para baixar o arquivo gerado pelo backend
      await repository.getExport(eventoId!, path);

      // 3. Compartilha o arquivo baixado
      await Share.shareXFiles(
        [XFile(path)],
        text: 'Segue o relatório exportado em CSV',
        subject: 'Exportar CSV',
      );
    } catch (e) {
      print("Erro ao exportar/compartilhar: $e");
      // Aqui você pode adicionar um Get.snackbar para avisar o usuário
    }
  }

  Future<void> detalhes() async {
    try{
      List<dynamic> dados = await repository.getDetalhes(eventoId!);
      print(dados.toString());

      List<Map<String, dynamic>> listaProcessada = [];

      for (var row in dados) {
        // Cria uma cópia modificável do mapa
        var novaLinha = Map<String, dynamic>.from(row);

        novaLinha['pago'] = double.tryParse(novaLinha['pago'].toString()) ?? 0.0;

        // Agora você pode modificar livremente
        double pago = double.tryParse(novaLinha['pago'].toString()) ?? 0.0;
        double consumo = double.tryParse(novaLinha['consumo'].toString()) ?? 0.0;

        novaLinha['balanco'] = pago - consumo;

        listaProcessada.add(novaLinha);
      }

      listaDetalhe.assignAll(listaProcessada);

    } catch (e) {
      // Se ocorrer qualquer erro, o catch captura e mostra o erro
      print("Erro ao salvar: $e");
    }
  }

}