import 'package:dio/dio.dart';

class ResumoRepository {
  final Dio dio;

  ResumoRepository(this.dio);


  Future<ResumoResponse> getResumo(int id) async {
    try {
      final response = await dio.get('/resumo/getResumo/$id');

      // O Dio já converte o JSON em um Map<String, dynamic> automaticamente
      return ResumoResponse.fromJson(response.data);
    } catch (e) {
      print("Erro ao buscar rateio: $e");
      rethrow;
    }
  }


  Future<List<dynamic>> getDetalhes(int id) async {
    try {
      final response = await dio.get('/resumo/getDetalhes/$id');

      // O Dio já converte o JSON em um Map<String, dynamic> automaticamente
      return response.data;
    } catch (e) {
      print("Erro ao buscar rateio: $e");
      rethrow;
    }
  }


  Future<void> getExport(int id, String savePath) async {
    try {
      await dio.download('/resumo/getExport/$id',
        savePath,
      );
    } catch (e) {
      rethrow; // Repassa o erro para o controller tratar
    }
  }
}

class ResumoResponse {
  final List<dynamic> pagadores;
  final List<dynamic> devedores;

  ResumoResponse({required this.pagadores, required this.devedores});

  // Factory para converter o JSON que vem da API
  factory ResumoResponse.fromJson(Map<String, dynamic> json) {
    return ResumoResponse(
      pagadores: json['pagadores'] ?? [],
      devedores: json['devedores'] ?? [],
    );
  }
}