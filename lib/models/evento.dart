import 'auxiliares.dart';

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

abstract class EventoRepository {
  Future<List<EventoModel>> fetchAll();
  Future<void> save(EventoModel evento);
  Future<void> delete(int id);
}