import 'dart:convert';
import 'package:mnp1/config/files.dart';
import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart';
// import 'dart:io';

class EstablishmentTypesHelper {
  Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'mnp.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE tipo_establecimientos (
      id INTEGER PRIMARY KEY,
      TES_id INTEGER, 
      TES_tipo TEXT
      )''');
    await db.execute('''CREATE TABLE establecimientos (
      id INTEGER PRIMARY KEY,
      TES_id INTEGER,
      TES_tipo TEXT,
      EST_nombre TEXT,
      EST_id INTEGER,
      EST_direccion TEXT,
      EST_departamento TEXT,
      EST_provincia TEXT,
      EST_municipio TEXT)''');
    await db.execute('''CREATE TABLE visitas (
      id INTEGER PRIMARY KEY,
      FRM_id INTEGER,
      VIS_id INTEGER,
      EST_id INTEGER,
      FRM_titulo TEXT,
      FRM_fecha TEXT,
      VIS_titulo TEXT,
      VIS_fechas TEXT,
      VIS_numero TEXT,
      VIS_tipo TEXT,
      EST_nombre TEXT )''');
  }

  //Busca las visitas relacionadas con el establecimiento seleccionado
  Future<List<EstablishmentsModel>> getVisitByEstablishment(
      int estId) async {
    Database? db = await database;

    List<Map<String, dynamic>> vis =
        await db!.query('visitas', where: 'EST_id = ?', whereArgs: [estId]);

    return List.generate(vis.length, (i) {
      return EstablishmentsModel.fromMap(vis[i]);
    });
  }

  //Busca los establecimientos por el tipo EST_id seleccionado en la pantalla de inicio
  Future<List<EstablishmentsModel>> getEstablishmentById(int tesId) async {
    Database? db = await database;

    List<Map<String, dynamic>> q = await db!
        .query('establecimientos', where: 'TES_id = ?', whereArgs: [tesId]);

    return List.generate(q.length, (i) {
      return EstablishmentsModel.fromMap(q[i]);
    });
  }

  //Busca los establecimientos por el tipo EST_id seleccionado en la pantalla de inicio
  Future<List<EstablishmentsModel>> getEstablishmentByName(
      String name, int tesId) async {
    Database? db = await database;

    List<Map<String, dynamic>> q = await db!.query('establecimientos',
        where: 'TES_id = ? AND EST_nombre LIKE ?',
        whereArgs: [tesId, '%$name%']);

    return List.generate(q.length, (i) {
      return EstablishmentsModel.fromMap(q[i]);
    });
  }

  Future<void> loadFromApiAndSave() async {
    final response = await get(
      Uri.parse(
          'https://test-mnp.defensoria.gob.bo/api/api_lista_tipos_establecimientos'),
    );

    final responseEstablishments = await get(
      Uri.parse(
          'https://test-mnp.defensoria.gob.bo/api/api_lista_establecimientos'),
    );

    final responseEstablishmentVisits = await get(
      Uri.parse('https://test-mnp.defensoria.gob.bo/api/api_historial_visitas'),
    );

    if (response.statusCode == 200 &&
        responseEstablishments.statusCode == 200 &&
        responseEstablishmentVisits.statusCode == 200) {
      /* Guarda datos de los tipos de establecimientos */
      List<dynamic> apiData = json.decode(response.body);
      List<EstablishmentTypesModel> tiposEstabs =
          apiData.map((data) => EstablishmentTypesModel.fromMap(data)).toList();
      // insertar los datos en la BD
      for (var tipoEst in tiposEstabs) {
        await insertData(tipoEst);
      }

      /* Guarda datos de los establecimientos */
      List<dynamic> apiDataEstablishments =
          json.decode(responseEstablishments.body);
      List<EstablishmentsModel> establishments = apiDataEstablishments
          .map((data) => EstablishmentsModel.fromMap(data))
          .toList();
      // insertar los datos en la BD
      for (var ests in establishments) {
        await insertDataEstablishments(ests);
      }
      /* Guarda el historial de visitas */
      List<dynamic> apiDataVisits =
          json.decode(responseEstablishmentVisits.body);
      List<EstablishmentsModel> visitList = apiDataVisits
          .map((data) => EstablishmentsModel.fromMap(data))
          .toList();
      // insertar los datos en la BD
      for (var visits in visitList) {
        await insertDataEstablishmentVisits(visits);
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

  Future<int> insertDataEstablishments(EstablishmentsModel ests) async {
    Database? dbEst = await database;
    return await dbEst!.insert('establecimientos', ests.toMap());
  }

  Future<int> insertDataEstablishmentVisits(
      EstablishmentsModel visits) async {
    Database? dbEst = await database;
    return await dbEst!.insert('visitas', visits.toMap());
  }

  Future<List<EstablishmentTypesModel>> getData() async {
    Database? db = await database;
    List<Map<String, dynamic>> maps = await db!.query('tipo_establecimientos');

    List<Map<String, dynamic>> estabs = await db.query('establecimientos');

    List<Map<String, dynamic>> visits = await db.query('visitas');

    print(visits);
    print(maps);
    print(estabs);
    return List.generate(maps.length, (i) {
      return EstablishmentTypesModel.fromMap(maps[i]);
    });
  }

  Future<void> deleteData() async {
    Database? db = await database;
    await db!.execute('delete from tipo_establecimientos');
    await db.execute('delete from establecimientos');
    await db.execute('delete from visitas');
    print('Datos eliminados');
  }

  Future<List<EstablishmentsModel>> queryx(String tesTipo) async {
    Database? db = await database;

    List<Map<String, dynamic>> q = await db!
        .query('establecimientos', where: 'TES_tipo = ?', whereArgs: [tesTipo]);

    // print(q);
    return List.generate(q.length, (i) {
      return EstablishmentsModel.fromMap(q[i]);
    });
  }
}