class Evento {
  late int idEvento;
  late String nome;


  void fromJson(dynamic json) {
    idEvento = int.parse(json['id_evento'].toString());
    nome = json['nome'];
  }

  Map toJson() => {
    'nome': nome,
  };
}

class LstMaster {
  String nome;

  LstMaster(this.nome);

  factory LstMaster.fromJson(dynamic json) {
    //var prop = jsonDecode(json['dados_proposta']);
    return LstMaster(
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