import 'dart:convert';
// import 'dart:html';
import 'package:http/http.dart';
import 'package:mnp1/config/files.dart';
import 'package:mnp1/screens/questionnarie_screen.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart'; // Asegúrate de importar el paquete necesario
import 'dart:math';
// import 'package:http/http.dart';
// import 'package:shared_preferences/shared_preferences.dart';


class DatabaseHelper {
  Database? _database;
  String uniqueId = "";
  Random random = Random();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'mnp.db');

    return await openDatabase(path, version: 2, onCreate: _onCreate);
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
      FRM_titulo TEXT,
      RBF_salto_FK_BCP_id TEXT
    )''');
    await db.execute('''CREATE TABLE agrupador_formularios (
      AGF_id TEXT PRIMARY KEY,
      FK_FRM_id INTEGER,
      FK_USER_id INTEGER,
      AGF_copia INTEGER
      )''');

      /** ARREGLAR ESTA PARTE para evitar la colision de AGF_id **/
    // await db.rawInsert('INSERT INTO agrupador_formularios (AGF_id, FK_FRM_id, FK_USER_id, AGF_copia) VALUES (?, ?, ?, ?)', [7000, null, null, null]);

    await db.execute('''CREATE TABLE respuestas (
      id INTEGER PRIMARY KEY,
      RES_respuesta TEXT,
      RES_complemento TEXT,
      FK_RBF_id INTEGER,
      FK_AGF_id TEXT,
      USER_id INTEGER,
      RES_device_id INTEGER
      )''');
  }

  Future<List<Map<String, dynamic>>> getQuestionarie(int frmId, String agfId) async {
    Database? db = await database;
    List<Map<String, dynamic>> result = await db!.rawQuery('''
      SELECT c.*, r.RES_respuesta, r.RES_complemento, r.id, af.AGF_id, af.FK_USER_id, af.AGF_copia
      FROM agrupador_formularios af
      JOIN cuestionario c ON af.FK_FRM_id = c.FK_FRM_id
      LEFT JOIN respuestas r ON c.RBF_id = r.FK_RBF_id AND r.FK_AGF_id = af.AGF_id
      WHERE af.FK_FRM_id = ? and af.AGF_id = ?
      ORDER BY c.RBF_orden, c.RBF_id
    ''', [frmId, agfId]);
    // for (var item in result) {
    //   print(jsonEncode(item));
    // }
    return result;
  }

  /* CARGA DE DATOS A LA BASE PRINCIPAL */
  Future<void> uploadData() async {
    Database? db = await database;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // List<Map<String, dynamic>> agf = await db!.query('agrupador_formularios');
    List<Map<String, dynamic>> agf = await db!.query('agrupador_formularios');
    List<Map<String, dynamic>> r = await db.query('respuestas', columns: ['RES_respuesta','RES_complemento','FK_RBF_id','FK_AGF_id','USER_id','RES_device_id']);
    
    // Convertir las listas a JSON
    String agfJson = jsonEncode(agf);
    String rJson = jsonEncode(r);


    // print(jsonEncode(<String, dynamic>{
    //         'r': rJson,
    //         'agf': agfJson,
    //       }));
    // URL del web service
    String url = 'https://mnp-bolivia.defensoria.gob.bo/api/api_guardar_respuestas';
      
    try {
        // Realizar la solicitud POST con el token de autorización
        final response = await post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // Agregar el token aquí
          },
          body: jsonEncode(<String, dynamic>{
            'agrupador_formularios': agfJson,
            'respuestas': rJson,
          }));
       
        // Verificar el código de estado de la respuesta
        if (response.statusCode == 200) {
          print('Datos enviados exitosamente');
        } else {
          print('Error al enviar datos: ${response.statusCode}');
        }
      } catch (e) {
        print('Error al enviar datos: $e');
      }
  }


  // Crea una nueva copia del formulario seleccionado 
  Future<int> createNewCopyForm( int frmId, BuildContext context ) async {
    Database? db = await database;
    int count = await db!.query('agrupador_formularios').then((value) => value.length);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    FormGrouperModel newCopyForm;

    // Se obtiene el ID del dispositivo
    // final String uniqueDevideId = await getUniqueId() as String;

    if (userId != null) {
      // Si userId no es nulo, continuar con el resto del código
      newCopyForm = FormGrouperModel(
        // INSERTAR AQUI EL ID DEL DISPOSITIVO
        agfId: '$userId-${count + 1}',
        fkFrmId: frmId,
        fkUserId: userId,
        agfCopia: count + 1,
      );
      // print(newCopyForm.agfId);

      // Insertar en la base de datos
      return await db.insert('agrupador_formularios', newCopyForm.toMap());
    } else {
      // Si userId es nulo, redirigir al usuario a la pantalla de inicio de sesión
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return 0;
    }
  }

  Future<String> getUniqueId() async {
     try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return uniqueId = androidInfo.androidId;
    } catch (e) {
      return uniqueId = ( random.nextInt(9000) + 1000).toString();
    }
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
    deleteData();
    final response = await get(
      Uri.parse(
        'https://mnp-bolivia.defensoria.gob.bo/api/api_lista_tipos_establecimientos'),
        headers: {'Authorization': 'Bearer $token'},
    );

    final responseEstablishments = await get(
      Uri.parse(
        'https://mnp-bolivia.defensoria.gob.bo/api/api_lista_establecimientos'),
        headers: {'Authorization': 'Bearer $token'},
    );

    final responseVisitForms = await get(
      Uri.parse(
        'https://mnp-bolivia.defensoria.gob.bo/api/api_visitas_formularios'),
        headers: {'Authorization': 'Bearer $token'},
    );
    final responseForm = await get(
      Uri.parse(
        'https://mnp-bolivia.defensoria.gob.bo/api/api_formularios_cuestionario'),
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
    await db.execute('delete from agrupador_formularios');
    await db.execute('delete from cuestionario');
    // await db.execute('delete from respuestas');
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
  Future<List<AnswersModel>> getAnswers() async {
    Database? db = await database;
    List<Map<String, dynamic>> q = await db!
        .query('respuestas');
    return List.generate(q.length, (i) {
      return AnswersModel.fromMap(q[i]);
    });
  }
  
  Future<void> delRespuestas() async {
    Database? db = await database;
    await db!.execute('delete from respuestas');
    print('Respuestas eliminadas');
  }

  
  // Verifica si la pregunta a insertar ya existe en la tabla respuestas de la BD local
  Future<List<Map<String, dynamic>>> getExistingAnswer(int fkRbfId, String fkAgfId) async {
    Database? db = await database;
     List<Map<String, dynamic>> checkAnswer = await db!.query('respuestas',
        where: 'FK_RBF_id = ? AND FK_AGF_id = ?',
        whereArgs: [fkRbfId, fkAgfId]);
    return checkAnswer;
  }

  // inserta la nueva respuesta en la BD
  createNewAnswer( dynamic answer) async {
    Database? db = await database;
    await db!.insert('respuestas', answer.toMap());
  }

  // Actualiza la respuesta actual por que ya existe su registro en la BD
  updateActualAnswer( dynamic answer, int fkRbfId, String fkAgfId ) async {
    Database? db = await database;
    Map<String, dynamic> updateValues = {
      'RES_respuesta': answer,
    };
      await db!.update(
        'respuestas',
        updateValues,
        where: 'FK_RBF_id = ? AND FK_AGF_id = ?',
        whereArgs: [fkRbfId, fkAgfId],
      );
  }
  
}
