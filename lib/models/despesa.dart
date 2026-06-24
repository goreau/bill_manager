class Despesa {
  int? idDespesa; // Usar int? ajuda a lidar com o caso de novos despesas (id = null)
  int id_evento;
  int id_pagador;
  String descricao;
  String? observacao;
  String valor;
  String data;
  List<Rateio>? rateio; // Lista de e-mails ou nomes

  Despesa({
    this.idDespesa,
    required this.id_evento,
    required this.id_pagador,
    required this.descricao,
    this.observacao,
    required this.valor,
    required this.data,
    this.rateio,
  });

  // Factory constructor: forma padrão e recomendada no Flutter
  factory Despesa.fromJson(Map<String, dynamic> json) {
    return Despesa(
      idDespesa: json['id_despesa'] != null ? int.tryParse(json['id_despesa'].toString()) : null,
      id_evento: json['id_evento'],
      id_pagador: json['id_pagador'],
      descricao: json['descricao'] ?? '',
      observacao: json['observacao'],
      valor: json['valor'],
      data: json['data'],
      rateio: (json['rateio'] as List)
          .map((item) => Rateio.fromMap(item))
          .toList(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id_despesa': idDespesa,
      'id_evento': id_evento,
      'id_pagador': id_pagador,
      'descricao': descricao,
      'observacao': observacao,
      'valor': valor,
      'data': data,
      'rateio': rateio, // O backend espera esse array
    };
  }
}

class Rateio {
  int id_pagador;
  String nome;
  String valor;

  Rateio({
    required this.id_pagador,
    required this.nome,
    required this.valor
  });

  factory Rateio.fromMap(Map<String, dynamic> map) {
    return Rateio(
      id_pagador: map['id'],
      nome: map['nome'],
      valor: map['valor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pagador': id_pagador,
      'nome': nome,
      'valor': valor,
    };
  }

}
