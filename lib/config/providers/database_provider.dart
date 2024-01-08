import 'package:flutter/material.dart';
import 'package:mnp1/config/files.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider with ChangeNotifier {
  bool isLoading = false;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<EstablishmentTypesModel> _types = [];
  List<EstablishmentTypesModel> get types => _types;

  List<EstablishmentsModel> _estabs = [];
  List<EstablishmentsModel> get estabs => _estabs;

  List<VisitFormsModel> _visits = [];
  List<VisitFormsModel> get visits => _visits;

  List<VisitFormsModel> _forms = [];
  List<VisitFormsModel> get forms => _forms;

  List<FormGrouperModel> _listForms = [];
  List<FormGrouperModel> get listForms => _listForms;

  List<QuestionnarieModel> _questions = [];
  List<QuestionnarieModel> get questions => _questions;

  Future<void> loadTypes() async {
    isLoading = true;
    _types = await _databaseHelper.getData();
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadEstablishments(tesId) async {
    isLoading = true;
    _estabs = await _databaseHelper.getEstablishmentById(tesId);
    isLoading = false;
    notifyListeners();
  }

// Provider que apunta a la funcion getEstablishmentByName( name, tesId ) establisment_types_helper
  Future<void> filterEstablishments(name, tesId) async {
    isLoading = true;
    _estabs = await _databaseHelper.getEstablishmentByName(name, tesId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadVisitForms(int estId) async {
    isLoading = true;
    _visits = await _databaseHelper.getVisits(estId);
    isLoading = false;
    notifyListeners();
  }

  Future<List<VisitFormsModel>> loadFormsFromVisit(int frmId) async {
    isLoading = true;
    _forms = await _databaseHelper.getFormsFromVisit(frmId);
    isLoading = false;
    notifyListeners();
    return _forms; // Asegúrate de devolver una lista de VisitFormsModel
  }

  Future<List<FormGrouperModel>> loadListForms(int fkFrmId) async {
    isLoading = true;
    _listForms = await _databaseHelper.getListForms(fkFrmId);
    isLoading = false;
    notifyListeners();
    return _listForms;
  }

  Future<void> putNewCopyForm(int frmId) async {
    await _databaseHelper.createNewCopyForm(frmId);
    await loadListForms(frmId);
    notifyListeners();
  }

  Future<List<QuestionnarieModel>> loadFormsQuestionnarie(int frmId) async {
    isLoading = true;
    _questions = await _databaseHelper.getQuestionarie(frmId);
    isLoading = false;
    notifyListeners();
    return _questions; // Asegúrate de devolver una lista de VisitFormsModel
  }

  Future<void> saveAnswer(AnswersModel answer) async {
  try {
    isLoading = true;
    Database? db = await _databaseHelper.database;

    // Insertar la respuesta en la tabla 'respuestas'
    await db!.insert('respuestas', answer.toMap());

    isLoading = false;
    notifyListeners();
  } catch (e) {
    print('Error al guardar la respuesta en la base de datos: $e');
    isLoading = false;
    rethrow; // Lanzar la excepción nuevamente para que pueda ser manejada en el nivel superior si es necesario
  }
}
}
