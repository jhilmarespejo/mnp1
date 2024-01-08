import 'dart:convert';
import 'package:mnp1/config/files.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DatabaseHelper {
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
    await db.execute('''CREATE TABLE visitas_formularios (
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
    await db.execute('''CREATE TABLE cuestionario (
      id INTEGER PRIMARY KEY,
      RBF_id INTEGER,
      FK_FRM_id INTEGER,
      FK_BCP_id INTEGER,
      BCP_id INTEGER,
      RBF_orden INTEGER,
      RBF_estado INTEGER,
      CAT_id INTEGER,
      CAT_subcat_id INTEGER,
      BCP_pregunta TEXT,
      BCP_tipoRespuesta TEXT,
      BCP_opciones TEXT,
      BCP_complemento TEXT,
      CAT_subcategoria TEXT,
      CAT_categoria TEXT,
      FRM_titulo TEXT
    )''');
    await db.execute('''CREATE TABLE agrupador_formularios (
      AGF_id INTEGER PRIMARY KEY,
      FK_FRM_id INTEGER,
      FK_USER_id INTEGER,
      AGF_copia INTEGER
      )''');
    await db.execute('''CREATE TABLE respuestas (
      id INTEGER PRIMARY KEY,
      RES_respuesta TEXT,
      FK_RBF_id INTEGER,
      FK_AGF_id INTEGER,
      USER_id INTEGER
      )''');
  }

  //Busca las preguntas relacionadas formularios seleccionado
  Future<List<QuestionnarieModel>> getQuestionarie(int frmId) async {
    Database? db = await database;
    List<Map<String, dynamic>> questions = await db!.query('cuestionario',
        where: 'FK_FRM_id = ?',
        whereArgs: [frmId],
        orderBy: 'RBF_id, RBF_orden');
    return List.generate(questions.length, (i) {
      return QuestionnarieModel.fromMap(questions[i]);
    });
  }

  // Crea una nueva copia del formulario seleccionado xxx INSERTAR AQUI EL NUMERO USER_ID
  Future<int> createNewCopyForm(int frmId) async {
  Database? db = await database;
  int count = await db!.query('agrupador_formularios', where: 'FK_FRM_id = ?', whereArgs: [frmId]).then((value) => value.length);
  print(count);
  FormGrouperModel newCopyForm = FormGrouperModel(
    fkFrmId: frmId,
    fkUserId: 80,
    agfCopia: count+1,
  );

  return await db.insert('agrupador_formularios', newCopyForm.toMap());
}
  //Busca las preguntas relacionadas formularios seleccionado
  Future<List<FormGrouperModel>> getListForms(int fkFrmId) async {
    Database? db = await database;
    List<Map<String, dynamic>> questions = await db!.query(
        'agrupador_formularios',
        where: 'FK_FRM_id = ?',
        whereArgs: [fkFrmId], orderBy: 'AGF_id DESC');
    return List.generate(questions.length, (i) {
      return FormGrouperModel.fromMap(questions[i]);
    });
  }

//Busca las visitas relacionadas con el establecimiento seleccionado
  Future<List<VisitFormsModel>> getFormsFromVisit(int visId) async {
    Database? db = await database;
    List<Map<String, dynamic>> frm = await db!
        .query('visitas_formularios', where: 'VIS_id = ?', whereArgs: [visId]);
    // print(frm);
    return List.generate(frm.length, (i) {
      return VisitFormsModel.fromMap(frm[i]);
    });
  }

  //Busca las visitas relacionadas con el establecimiento seleccionado
  Future<List<VisitFormsModel>> getVisits(int estId) async {
    Database? db = await database;
    List<Map<String, dynamic>> vis = await db!.query(
      'visitas_formularios',
      where: 'EST_id = ?',
      whereArgs: [estId],
      groupBy: 'VIS_id',
    );

    return List.generate(vis.length, (i) {
      return VisitFormsModel.fromMap(vis[i]);
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

  // Busca informacion de las apis y la inserta en la base de datos local
  Future<void> loadFromApiAndSave() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print(token);
    final response = await get(
      Uri.parse(
        'https://test-mnp.defensoria.gob.bo/api/api_lista_tipos_establecimientos'),
        headers: {'Authorization': 'Bearer $token'},
    );

    final responseEstablishments = await get(
      Uri.parse(
        'https://test-mnp.defensoria.gob.bo/api/api_lista_establecimientos'),
        headers: {'Authorization': 'Bearer $token'},
    );

    final responseVisitForms = await get(
      Uri.parse(
        'https://test-mnp.defensoria.gob.bo/api/api_visitas_formularios'),
        headers: {'Authorization': 'Bearer $token'},
    );
    final responseForm = await get(
      Uri.parse(
        'https://test-mnp.defensoria.gob.bo/api/api_formularios_cuestionario'),
        headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 &&
        responseEstablishments.statusCode == 200 &&
        responseVisitForms.statusCode == 200 &&
        responseForm.statusCode == 200) {
      /* Guarda datos de los tipos de establecimientos */
      List<dynamic> apiData = json.decode(response.body);
      List<EstablishmentTypesModel> tiposEstabs =
          apiData.map((data) => EstablishmentTypesModel.fromMap(data)).toList();

      // insertar los datos en la BD
      for (var tipoEst in tiposEstabs) {
        await insertData(tipoEst);
      }
      print('tipos de establecimientos insertados');

      /* Guarda datos de los establecimientos */
      List<dynamic> apiDataEstablishments =
          json.decode(responseEstablishments.body);
      List<EstablishmentsModel> establishments = apiDataEstablishments
          .map((data) => EstablishmentsModel.fromMap(data))
          .toList();
      for (var ests in establishments) {
        await insertDataEstablishments(ests);
      }
      print('establecimientos insertados');
      /* Guarda las visitas y formularios */
      List<dynamic> apiDataVisits = json.decode(responseVisitForms.body);
      List<VisitFormsModel> visitFormsList =
          apiDataVisits.map((data) => VisitFormsModel.fromMap(data)).toList();
      // insertar los datos en la BD
      for (var visitForms in visitFormsList) {
        await insertDataEstablishmentVisits(visitForms);
      }
      print('visitas y forms insertados');
      /* Guarda las preguntas para el formulario */
      List<dynamic> apiForm = json.decode(responseForm.body);
      List<QuestionnarieModel> questionsList =
          apiForm.map((data) => QuestionnarieModel.fromMap(data)).toList();
      // insertar los datos en la BD
      for (var questions in questionsList) {
        await insertDataQuestions(questions);
      }
      print('cuestionarios insertados');

      print('Datos insertados');
    } else {
      throw Exception('Error al cargar datos desde la API');
    }
  }

  // funciones para la insercion de datos
  Future<int> insertData(EstablishmentTypesModel tipoEst) async {
    Database? db = await database;
    return await db!.insert('tipo_establecimientos', tipoEst.toMap());
  }

  Future<int> insertDataEstablishments(EstablishmentsModel ests) async {
    Database? dbEst = await database;
    return await dbEst!.insert('establecimientos', ests.toMap());
  }

  Future<int> insertDataEstablishmentVisits(VisitFormsModel visitForms) async {
    Database? dbVisForms = await database;
    return await dbVisForms!.insert('visitas_formularios', visitForms.toMap());
  }

  Future<int> insertDataQuestions(QuestionnarieModel questions) async {
    Database? dbForm = await database;
    return await dbForm!.insert('cuestionario', questions.toMap());
  }

  Future<List<EstablishmentTypesModel>> getData() async {
    Database? db = await database;
    List<Map<String, dynamic>> maps = await db!.query('tipo_establecimientos');

    List<Map<String, dynamic>> estabs = await db.query('establecimientos');

    List<Map<String, dynamic>> visits = await db.query('visitas_formularios');
    List<Map<String, dynamic>> questionnarie = await db.query('cuestionario');
    List<Map<String, dynamic>> grouperForms = await db.query('agrupador_formularios');

    print(grouperForms);
    // print(questionnarie);
    // print(visits);
    // print(maps);
    // print(estabs);
    return List.generate(maps.length, (i) {
      return EstablishmentTypesModel.fromMap(maps[i]);
    });
  }

  Future<void> deleteData() async {
    Database? db = await database;
    await db!.execute('delete from tipo_establecimientos');
    await db.execute('delete from establecimientos');
    await db.execute('delete from visitas_formularios');
    await db.execute('delete from cuestionario');
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
  Future<List<AnswersModel>> queryy() async {
    Database? db = await database;

    List<Map<String, dynamic>> q = await db!
        .query('respuestas');

    print(q);
    return List.generate(q.length, (i) {
      return AnswersModel.fromMap(q[i]);
    });
  }
}
