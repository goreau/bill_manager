import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/evento.dart';

class DbHelper {
  static final _databaseName = "bill.db";
  static final _databaseVersion = 3;

  Map registros = Map<String, dynamic>();

  // Uso

  //final dbHelper = DatabaseHelper.instance;

  static final sqlCreate = [
    "CREATE TABLE evento(id_evento INTEGER PRIMARY KEY, nome TEXT, foto TEXT)",
    "CREATE TABLE participante(id_participante INTEGER PRIMARY KEY, id_evento INTEGER, nome TEXT)",
    "CREATE TABLE despesa(id_despesa INTEGER PRIMARY KEY, id_evento INTEGER, id_participante INTEGER, valor REAL, descricao TEXT, observacao TEXT, data TEXT, foto TEXT)",
    "CREATE TABLE rateio(id_rateio INTEGER PRIMARY KEY, id_despesa INTEGER, id_participante INTEGER, valor REAL)",
  ];
  static final tabelas = {
    "evento",
    "participante",
    "despesa",
    "rateio",
  };

  // torna esta classe singleton
  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();
  // tem somente uma referência ao banco de dados
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    // instancia o db na primeira vez que for acessado
    _database = await _initDatabase();
    return _database;
  }

  // abre o banco de dados e o cria se ele não existir
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onUpgrade: _onUpgrade,
      onCreate: _onCreate,
    );
  }

  Future _onUpgrade(Database db, int version, int newVersion) async {
    await _persiste(db);
    for (var e in tabelas) {
      await db.execute("DROP TABLE IF EXISTS $e");
    }
    await _onCreate(db, newVersion);
    _recupera(db);
  }

  // Código SQL para criar o banco de dados e as tabelas
  Future _onCreate(Database db, int version) async {
    //
    Batch batch = db.batch();
    try {
      sqlCreate.forEach((e) {
        batch.execute(e);
      });
      await batch.commit();
    } catch (e) {
      print('Erro criando tabela $e');
    }
  }

  Future<int> insert(Map<String, dynamic> row, String table) async {
    Database? db = await instance.database;
    return await db!.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryRows(
      String table, {
        String? where,
        List<dynamic>? whereArgs, // Lista de argumentos para permitir flexibilidade
      }) async {
    Database? db = await instance.database;

    return await db!.query(
        table,
        where: where,
        whereArgs: whereArgs
    );
  }

  Future<Map<String, dynamic>> queryObj(String table, int id) async {
    Database? db = await instance.database;
    var resultset =
    await db!.query(table, where: 'id_${table} = ?', whereArgs: [id]);
    return resultset[0];
  }

  Future<int?> queryRowCount(String table) async {
    Database? db = await instance.database;
    return Sqflite.firstIntValue(
        await db!.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> update(Map<String, dynamic> row, String table, int id) async {
    Database? db = await instance.database;
    String idField = 'id_$table';
    return await db!.update(table, row, where: '$idField = ?', whereArgs: [id]);
  }

  Future<int> delete(int id, String table) async {
    Database? db = await instance.database;
    String idField = 'id_$table';
    return await db!.delete(table, where: '$idField = ?', whereArgs: [id]);
  }

  Future<int> limpa(String table) async {
    Database? db = await instance.database;
    return await db!.delete(table);
  }

  Future<int> limpaTable(String table, String where) async {
    Database? db = await instance.database;
      return await db!.rawDelete('DELETE FROM ${table} WHERE ${where}');
  }

  Future<void> _persiste(Database db) async {
    //fornecer valor padrão para o campo alterado

    for (var element in tabelas) {
      var lista = [];
      await db.query(element).then((value) {
        for (var row in value) {
          //value.forEach((row) {
          lista.add(row);
        } //);
        registros[element] = lista;
      });
    }
  }

  Future<List<Evento>> consultaEventoMaster() async {
    Database? db = await instance.database;

    // 1. Busca todos os eventos
  //  List<Map<String, dynamic>> eventosMap = await db!.query('evento');

    List<Evento> listaFinal = [];


    return listaFinal;
  }

/*  Future<List<DespesaModel>> consultaDespesaMaster(int id) async {
    Database? db = await instance.database;

    // 1. Busca todas as despesas do evento
    List<Map<String, dynamic>> despesaMap = await db!.rawQuery(
        'SELECT id_despesa, p.nome, descricao, valor, data FROM despesa as d JOIN participante as p '
            'ON p.id_participante=d.id_participante WHERE d.id_evento = ?',
        [id]
    );


    List<DespesaModel> listaFinal = [];

    for (var desp in despesaMap) {
      int idDespesa = desp['id_despesa'];

      // 2. Busca os rateios relacionados a esta despesa específica
      List<Map<String, dynamic>> rateioMap = await db.rawQuery(
          'SELECT id_rateio, p.nome, valor FROM rateio as r JOIN participante as p '
              'ON p.id_participante=r.id_participante WHERE id_despesa = ?',
          [idDespesa]
      );
      print(rateioMap.toString());


      // 3. Converte a lista de mapas para List<RateioModel>
    //  List<RateioModel> rateio = rateioMap.map((p) => RateioModel.fromMap(p)).toList();

      // 4. Cria o objeto DespesaModel passando a lista de rateios
  //    listaFinal.add(DespesaModel.fromMap(desp, rateio));
    }

    return listaFinal;
  }*/

  _recupera(Database db) async {
    for (var element in tabelas) {
      var tab = registros[element];
      for (var reg in tab) {
        db.insert(element, reg);
      }
    }
  }

  Future<List<Map>> qryCombo(String tabela, filtro) async {
    Database? db = await instance.database;
    String sql;

      sql = 'SELECT id_$tabela as id, nome FROM $tabela';

    sql += filtro == '' ? ' ORDER BY id' : ' WHERE $filtro ORDER BY id';
    //print(sql);
    return await db!.rawQuery(sql);
  }
}
