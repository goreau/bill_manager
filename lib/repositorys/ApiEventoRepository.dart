import 'package:bill_manager/models/auxiliares.dart';
import 'package:bill_manager/models/evento.dart';
import 'package:dio/dio.dart';

class ApiEventRepository implements EventoRepository {
  final Dio dio;
  ApiEventRepository(this.dio);

  @override
  Future<void> save(EventoModel evento) async {
    // Aqui você chama o seu backend Node.js
  /*  if (evento.id == 0) {
      await dio.post('/eventos', data: evento.toJson());
    } else {
      await dio.put('/eventos/${evento.id}', data: evento.toJson());
    }*/
  }

  @override
  Future<void> delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<EventoModel>> fetchAll() {
    // TODO: implement fetchAll
    throw UnimplementedError();
  }

// ... implementação de fetch e delete
}