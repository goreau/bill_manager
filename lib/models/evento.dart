class Evento {
  int? idEvento; // Usar int? ajuda a lidar com o caso de novos eventos (id = null)
  String nome;
  List<String>? participantes; // Lista de e-mails ou nomes
  String? foto;

  Evento({
    this.idEvento,
    required this.nome,
    this.participantes,
    this.foto
  });

  // Factory constructor: forma padrão e recomendada no Flutter
  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      // Se id_evento vier como nulo (evento novo), tratamos com ??
      idEvento: json['id_evento'] != null ? int.tryParse(json['id_evento'].toString()) : null,
      nome: json['nome'] ?? '',
      foto: json['foto'],
      // Mapeia a lista de participantes se ela existir
      participantes: json['participantes'] != null
          ? List<String>.from(json['participantes'].map((x) => x['nome']))
          : [],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'foto': foto,
      'participantes': participantes, // O backend espera esse array
    };
  }
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

/*abstract class EventoRepository {
  EventoRepository(find);

  Future<List<Evento>> fetchAll();
  Future<void> save(Evento evento);
  Future<void> delete(int id);
}*/