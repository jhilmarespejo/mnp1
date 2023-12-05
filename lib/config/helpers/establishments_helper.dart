import 'dart:convert';
import 'package:mnp1/config/models/establishments_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart';

class EstablishmentsHelper {
  Database? _database;

  Future<Database?> get databaseEstabs async {
    if (_database != null) return _database;

    _database = await initDatabaseEstablishments();
    return _database;
  }

  Future<Database> initDatabaseEstablishments() async {
    String databasesPathEstablishments = await getDatabasesPath();
    String path = join(databasesPathEstablishments, 'establecimientos.db');

    return await openDatabase(path,
        version: 4, onCreate: _onCreateEstablishments);
  }

  Future<void> _onCreateEstablishments(Database dbEst, int version) async {
    await dbEst.execute('''CREATE TABLE establecimientos (
      id INTEGER PRIMARY KEY,
      EST_nombre TEXT,
      TES_tipo TEXT,
      EST_id INTEGER,
      EST_direccion TEXT,
      EST_departamento TEXT,
      EST_provincia TEXT,
      EST_municipio TEXT)''');
  }

  Future<void> loadFromApiAndSaveEstablishments() async {
    final responseEstablishments = await get(
      Uri.parse(
          'https://test-mnp.defensoria.gob.bo/api/api_lista_establecimientos'),
    );

    if (responseEstablishments.statusCode == 200) {
      List<dynamic> apiDataEstablishments =
          json.decode(responseEstablishments.body);
      List<EstablishmentsModel> establishments = apiDataEstablishments
          .map((data) => EstablishmentsModel.fromMap(data))
          .toList();

      // Guardar los datos en la base de datos
      for (var ests in establishments) {
        await insertDataEstablishments(ests);
      }
      print('establecimientos insertados');
    } else {
      throw Exception('Error al cargar datos desde la API');
    }
  }

  Future<int> insertDataEstablishments(EstablishmentsModel ests) async {
    Database? dbEst = await databaseEstabs;
    return await dbEst!.insert('establecimientos', ests.toMap());
  }

  // Future<List<EstablishmentsModel>> getEstablishments() async {
  //   Database? dbEst = await databaseEstabs;
  //   List<Map<String, dynamic>> maps = await dbEst!.query('establecimientos');

  //   print(dbEst);
  //   return List.generate(maps.length, (i) {
  //     return EstablishmentsModel.fromMap(maps[i]);
  //   });
  // }

  // Future<List<EstablishmentsModel>> getEstablishments() async {
  //   Database? dbEst = await databaseEstabs;
  //   List<Map<String, dynamic>> maps = await dbEst!.query('establecimientos');

  //   print(dbEst);
  //   return List.generate(maps.length, (i) {
  //     return EstablishmentsModel.fromMap(maps[i]);
  //   });
  // }

  Future<int> deleteEstablishments() async {
    Database? dbEst = await databaseEstabs;

    print('Establecimientos eliminados');
    return await dbEst!.delete('establecimientos');
  }
}
