import 'dart:io';

import 'package:bill_manager/util/storage.dart';
import 'package:csv/csv.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/auxiliares.dart';
import '../util/db_helper.dart';

class ResumoController extends GetxController {
  var isLoading = false.obs;
  final dbHelper = DbHelper.instance;
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

    await calcularAcerto(); // Sua função de cálculo

  }

  Future<List<ResumoDivida>> calcularAcerto() async {
    eventoId = await Storage.recupera('evento_ativo_id');

    List<Map<String, dynamic>>? resultadosPagamentos = await getPagadores();
    List<Map<String, dynamic>>? resultadosDevidos = await getDevedores();
//print(resultadosPagamentos);
//print(resultadosDevidos);

    Map<String, double> saldos = {};

// 1. Adiciona créditos (quem pagou)
    for (var row in resultadosPagamentos!) {
      String nome = row['nome'];
      double valor = row['total'];
      saldos[nome] = (saldos[nome] ?? 0) + valor;
    }

// 2. Subtrai débitos (quem deve)
    for (var row in resultadosDevidos!) {
      String nome = row['nome'];
      double valor = row['total'];
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
    //print(lista.toString());
    listaResumo.assignAll(lista);
    return lista;
  }



  Future<List<Map<String, dynamic>>?> getPagadores () async{
    try {
      final db = await dbHelper.database;

      List<Map<String, Object?>>? lista = await db?.rawQuery(
          'SELECT p.nome, SUM(valor) as total FROM despesa as d JOIN participante as p '
              'ON p.id_participante=d.id_participante WHERE d.id_evento = ? GROUP BY p.nome',
          [eventoId]
      );

      return lista;

    } catch (e) {
      // Se ocorrer qualquer erro, o catch captura e mostra o erro
      print("Erro ao salvar: $e");
    }
  }

  Future<List<Map<String, dynamic>>?> getDevedores () async{

    try {
      final db = await dbHelper.database;

      List<Map<String, Object?>>? lista = await db?.rawQuery(
          'SELECT p.nome, SUM(valor) as total FROM rateio as r JOIN participante as p '
          'ON p.id_participante=r.id_participante WHERE p.id_evento = ? GROUP BY p.nome',
          [eventoId]
      );

      return lista;

    } catch (e) {
      // Se ocorrer qualquer erro, o catch captura e mostra o erro
      print("Erro ao salvar: $e");
      /*scaffold.showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar registro: $e'),
          backgroundColor: Colors.red[900],
        ),
      );*/
    }
  }

  Future<void> exportarParaCSV() async {

    String path = await getCSVData();

    await SharePlus.instance.share( ShareParams( files: [XFile(path)], text: 'Segue a exportação em CSV', title: 'Exportar CSV', ), );

  }

  Future<String> getCSVData() async {
    final db = await dbHelper.database;


    List<Map<String, dynamic>>? dados = await db?.rawQuery('SELECT e.nome AS evento_nome, d.descricao AS despesa_descricao, d.valor AS despesa_valor, '
        'p_pagador.nome AS pagador, p_rateio.nome AS participante_rateio, r.valor AS valor_rateio, d.id_despesa, d.data '
        'FROM despesa d JOIN evento e ON d.id_evento = e.id_evento JOIN participante p_pagador ON d.id_participante = p_pagador.id_participante '
        'LEFT JOIN rateio r ON d.id_despesa = r.id_despesa LEFT JOIN participante p_rateio ON r.id_participante = p_rateio.id_participante '
        'WHERE p_pagador.id_evento = ? ORDER BY d.data',
        [eventoId]);

    if (dados!.isEmpty) return "";

    Map<String, double> saldosAcumulados = {};

    Set<String> participantes = {};
    for (var row in dados) {
      if (row['participante_rateio'] != null) {
        participantes.add(row['participante_rateio']);
        saldosAcumulados[row['participante_rateio']] = 0;
      }
    }

    List<String> header = ['Evento', 'Descrição', 'Data', 'Valor Total', 'Pagador'];
    header.addAll(participantes);
    header.addAll(participantes.map((n) => "Saldo $n"));


    Map<int, Map<String, dynamic>> despesasMap = {};

    for (var row in dados) {
      int idDespesa = row['id_despesa'];

      if (!despesasMap.containsKey(idDespesa)) {
        despesasMap[idDespesa] = {
          'evento': row['evento_nome'],
          'descricao': row['despesa_descricao'],
          'data': row['data'],
          'valor_total': row['despesa_valor'],
          'pagador': row['pagador'],
          'rateios': <String, dynamic>{},
        };
      }

      // Adiciona o valor do rateio deste participante à despesa correspondente
      if (row['participante_rateio'] != null) {
        despesasMap[idDespesa]!['rateios'][row['participante_rateio']] = row['valor_rateio'];
      }
    }

    for (var despesa in despesasMap.values) {
      String pagador = despesa['pagador'];
      double valorTotal = (despesa['valor_total'] as num).toDouble();

      // Para cada participante, calculamos o impacto desta despesa
      for (var nome in participantes) {
        double valorRateio = (despesa['rateios'][nome] ?? 0.0).toDouble();

        // Impacto = Quanto ele pagou (se for o pagador) - quanto ele consumiu
        double impacto = (nome == pagador ? valorTotal : 0.0) - valorRateio;

        // Atualiza o acumulador
        saldosAcumulados[nome] = saldosAcumulados[nome]! + impacto;

        // Salva o saldo DESTA linha no objeto da despesa
        despesa['saldos_apos_despesa'] ??= <String, double>{};
        despesa['saldos_apos_despesa'][nome] = saldosAcumulados[nome]!;
      }
    }

    // 1. Preparar a lista de listas (o formato que o pacote espera)
    List<List<dynamic>> csvData = [];

    // Cabeçalho

    csvData.add(header);

    for (var despesa in despesasMap.values) {
      List<dynamic> row = [
        despesa['evento'],
        despesa['descricao'],
        despesa['data'],
        despesa['valor_total'].toStringAsFixed(2).replaceAll('.', ','),
        despesa['pagador']
      ];

      List<String> listaPart = participantes.toList();

      for (var nome in listaPart) {
        var val = (despesa['rateios'][nome] ?? 0.0);
        row.add(val.toStringAsFixed(2).replaceAll('.', ','));
      }

      // Adiciona saldos acumulados
      for (var nome in listaPart) {
        var saldo = (despesa['saldos_apos_despesa'][nome] ?? 0.0);
        row.add(saldo.toStringAsFixed(2).replaceAll('.', ','));
      }

      csvData.add(row);
    }

    print(csvData);

    // 2. Converter para string usando o pacote csv
    String csvString = const ListToCsvConverter(fieldDelimiter: ';').convert(csvData);
    //print(csvString);

    // 3. Salvar o arquivo
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/exportacao.csv';
    final file = File(path);

    await file.writeAsString(csvString);
    return path;
  }

  Future<void> detalhes() async {
    try {
      final db = await dbHelper.database;

      List<Map<String, Object?>>? dados = await db?.rawQuery(
          'SELECT p.nome, COALESCE(sub_pago.total_pago, 0) as pago, COALESCE(sub_consumo.total_consumo, 0) as consumo, 0 as balanco '
          'FROM participante p LEFT JOIN (SELECT id_participante, SUM(valor) as total_pago FROM despesa GROUP BY id_participante) as sub_pago ON p.id_participante = sub_pago.id_participante '
          'LEFT JOIN (SELECT id_participante, SUM(valor) as total_consumo FROM rateio GROUP BY id_participante) as sub_consumo ON p.id_participante = sub_consumo.id_participante '
          'WHERE p.id_evento = ?',
          [eventoId]
      );

      List<Map<String, dynamic>> listaProcessada = [];

      for (var row in dados!) {
        // Cria uma cópia modificável do mapa
        var novaLinha = Map<String, dynamic>.from(row);

        novaLinha['pago'] = (novaLinha['pago'] as num? ?? 0).toDouble();

        // Agora você pode modificar livremente
        double pago = (novaLinha['pago'] as num).toDouble();
        double consumo = (novaLinha['consumo'] as num? ?? 0).toDouble();

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