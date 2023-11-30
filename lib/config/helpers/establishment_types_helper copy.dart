import 'dart:convert';
import 'package:mnp1/config/models/establishment_types_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart';

class EstablishmentTypesHelper {
  Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'tipo_establecimientos.db');

    return await openDatabase(path, version: 2, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE tipo_establecimientos (
          id INTEGER PRIMARY KEY,
          TES_id INTEGER, 
          TES_tipo TEXT
          )''');
  }

  Future<void> loadFromApiAndSave() async {
    final response = await get(
      Uri.parse(
          'https://test-mnp.defensoria.gob.bo/api/api_lista_tipos_establecimientos'),
    );

    if (response.statusCode == 200) {
      List<dynamic> apiData = json.decode(response.body);
      List<EstablishmentTypesModel> tiposEstabs =
          apiData.map((data) => EstablishmentTypesModel.fromMap(data)).toList();

      // Guardar los datos en la base de datos
      for (var tipoEst in tiposEstabs) {
        await insertData(tipoEst);
      }
      print('Datos insertados');
    } else {
      throw Exception('Error al cargar datos desde la API');
    }
  }

  Future<int> insertData(EstablishmentTypesModel tipoEst) async {
    Database? db = await database;
    return await db!.insert('tipo_establecimientos', tipoEst.toMap());
  }

  Future<List<EstablishmentTypesModel>> getData() async {
    Database? db = await database;
    List<Map<String, dynamic>> maps = await db!.query('tipo_establecimientos');

    print(maps);
    return List.generate(maps.length, (i) {
      return EstablishmentTypesModel.fromMap(maps[i]);
    });
  }

  Future<int> deleteData() async {
    Database? db = await database;

    print('Datos eliminados');
    return await db!.delete('tipo_establecimientos');
  }
}
