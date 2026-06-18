class Participante {
  late int idParticipante;
  late int idEvento;
  late String nome;


  void fromJson(dynamic json) {
    idParticipante = int.parse(json['id_participante'].toString());
    idEvento = int.parse(json['id_evento'].toString());
    nome = json['nome'];
  }

  Map toJson() => {
    'id_evento': idEvento,
    'nome': nome,
  };
}

class LstMaster {
  String nome;
  String evento;

  LstMaster(this.nome, this.evento);

  factory LstMaster.fromJson(dynamic json) {
    //var prop = jsonDecode(json['dados_proposta']);
    return LstMaster(
      json['evento'].toString(),
      json['nome'].toString(),
    );
  }
}

/*class LstDetail {
  int id;
  int status;
  String ordem;
  String endereco;

  LstDetail(this.id, this.status, this.ordem, this.endereco);

  factory LstDetail.fromJson(dynamic json) {
    //var prop = jsonDecode(json['dados_proposta']);
    return LstDetail(
        int.parse(json['id_visita'].toString()),
        int.parse(json['status'].toString()),
        json['ordem'].toString(),
        json['endereco'].toString().trim() +
            ', ' +
            json['numero'].toString().trim());
  }
}*/