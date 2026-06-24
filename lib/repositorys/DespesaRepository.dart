import 'package:dio/dio.dart';

import '../models/despesa.dart';

class DespesaRepository {
  final Dio dio;
  DespesaRepository(this.dio);


  Future<void> save(Despesa despesa) async {
    final response;

    if (despesa.idDespesa == 0) {
      response = await dio.post('/despesa/create', data: despesa);
    } else {
      response = await dio.put('/despesa/updateDespesa/${despesa.idDespesa}', data: despesa);
    }
    print(response);
  }


  Future<void> delete(int id) async {
    await dio.delete('/despesa/deleteDespesa/$id');
  }


  Future<List<Despesa>> fetchAll(int id) async {
    final response = await dio.get('/despesa/despesasEvento/$id');
    print(response.data);

    // 2. Extrai os dados (response.data)
    // O Dio já converte automaticamente o JSON para um List ou Map
    final List<dynamic> data = response.data;

    // 3. Converte a lista de JSONs para uma lista de DespesaModel
    return data.map((json) => Despesa.fromJson(json)).toList();
  }


  Future<List<dynamic>> getParticipantes(int id) async {
    final response = await dio.get('/despesa/getParticipantes/$id');
    //print(response.data);

    // 2. Extrai os dados (response.data)
    // O Dio já converte automaticamente o JSON para um List ou Map
    final List<dynamic> data = response.data;


    return data;
  }
}