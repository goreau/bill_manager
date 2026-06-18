import 'dart:ffi';

class EventoModel {
  final int id;
  final String nome;
  final String foto;
  final List<String> participantes;

  factory EventoModel.fromMap(Map<String, dynamic> map, List<String> participantes) {
    return EventoModel(
      id: map['id_evento'],
      nome: map['nome'],
      foto: map['foto'] ?? '',
      participantes: participantes,
    );
  }

  EventoModel({
    required this.id,
    required this.nome,
    required this.foto,
    required this.participantes
  });
}

class DespesaModel {
  final int id;
  final String pagador;
  final String descricao;
  final double valor;
  final String data;
  final List<RateioModel> devedores;

  factory DespesaModel.fromMap(Map<String, dynamic> map, List<RateioModel> devs) {
    return DespesaModel(
      id: map['id_despesa'],
      pagador: map['nome'],
      descricao: map['descricao'],
      valor: map['valor'],
      data: map['data'],
      devedores: devs,
    );
  }

  DespesaModel({
    required this.id,
    required this.pagador,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.devedores
  });
}

class RateioModel {
  final int id;
  final String nome;
  final double valor;

  factory RateioModel.fromMap(Map<String, dynamic> map) {
    return RateioModel(
      id: map['id_rateio'],
      nome: map['nome'],
      valor: map['valor'],
    );
  }

  RateioModel({
    required this.id,
    required this.nome,
    required this.valor
  });
}

class ResumoDivida {
  final String devedor;
  final String credor;
  final double valor;

  ResumoDivida(this.devedor, this.credor, this.valor);


  @override
  String toString() {
    return '$devedor deve R\$ $valor para $credor';
  }
}


