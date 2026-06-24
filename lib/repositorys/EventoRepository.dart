import 'package:bill_manager/models/evento.dart';
import 'package:dio/dio.dart';

class EventoRepository {
  final Dio dio;
  EventoRepository(this.dio);


  Future<void> save(Evento evento) async {
    FormData formData = await criarFormData(evento);
    final response;

    if (evento.idEvento == 0) {
      response = await dio.post('/evento/create', data: formData);
    } else {
      response = await dio.put('/evento/updateEvento/${evento.idEvento}', data: formData);
    }
    print(response);
  }

  Future<FormData> criarFormData(Evento evento) async {
    final Map<String, dynamic> data = {
      "nome": evento.nome,
      "participantes": evento.participantes,
    };

    // Só adiciona a foto se ela for um caminho de arquivo local real
    // Exemplo de verificação simples:
    if (evento.foto != null && evento.foto!.isNotEmpty && !evento.foto!.startsWith('http')) {
      data["foto"] = await MultipartFile.fromFile(
        evento.foto!,
        filename: "imagem.jpg",
      );
    }

    return FormData.fromMap(data);
  }

  Future<void> delete(int id) async {
    await dio.delete('/evento/deleteEvento/$id');
  }

  Future<List<Evento>> fetchAll() async {
    final response = await dio.get('/evento/eventosUser');
    //print(response.data);

    // 2. Extrai os dados (response.data)
    // O Dio já converte automaticamente o JSON para um List ou Map
    final List<dynamic> data = response.data;

    // 3. Converte a lista de JSONs para uma lista de EventoModel
    return data.map((json) => Evento.fromJson(json)).toList();
  }
}